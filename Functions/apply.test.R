#' @title apply test
#'
#' @description applies pairwise tests to the dataset
#'
#' @param data the global dataset
#' @param metric which metric to use
#' @param best which best tree (rand or norm)
#' @param test which test (if NULL, simply summarises the distribution)
#' @param convert.row.names whether to convert the row names into columns data (TRUE) or not (FALSE)
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export

apply.test <- function(data, metric, best, test, convert.row.names = TRUE) {

    ## Combined
    combined <- TRUE

    ## Getting the metric
    if(metric == "RF") metric <- 2
    if(metric == "Triples") metric <- 4

    ## Getting all the data for one metric
    NTS_all <- lapply(data, lapply.get.metric, metric)

    ## Extract the right scenarios (i.e. drop rand/norm and true)
    if(best == "norm") {
        ## Extra the right base (norm and rand)
        NTS_base <- lapply(NTS_all, lapply, lapply, `[[`, 1)
        NTS <- lapply(NTS_base, lapply, lapply, `[`, c(2,3,4))
    } else {
        ## Extra the right base (norm and rand)
        NTS_base <- lapply(NTS_all, lapply, lapply, `[[`, 2)
        NTS <- lapply(NTS_base, lapply, lapply, `[`, c(1,2,3))
    }

    ## Getting the NTS values as a list
    NTS_list <- unlist(unlist(unlist(NTS, recursive = FALSE), recursive = FALSE), recursive = FALSE)

    ## Getting the levels of parameters
    list_names <- names(NTS_list)
    parameter_names <- c("t25.", "t75.", "t150.", "c100.", "c350.", "c1000.", "bayesian", "parsimony")
    if(best == "norm") {
        parameter_names <- c(parameter_names, c("minimised", "maximised", "randomised"))
    } else {
        parameter_names <- c(parameter_names, c("unperturbed", "minimised", "maximised"))
    }
    parameters <- lapply(as.list(parameter_names), grep, list_names, fixed = TRUE)
    names(parameters) <- parameter_names

    ## Selecting the parameters combinations
    combo_matrix <- matrix(c(rep(1, 3), rep(2, 3), rep(3, 3), rep(c(4,5,6), 3)), nrow = 2, byrow = TRUE)
    combo_matrix <- cbind(combo_matrix, combo_matrix)
    combo_matrix <- rbind(combo_matrix, matrix(c(rep(7, 9), rep(8, 9)), nrow = 1, byrow = TRUE))

    ## Select the NTS lists for each combination (18 in total)
    combo_list <- apply(combo_matrix, 2, function(X) Reduce(intersect, parameters[X]))

    ## Summarising the statistics
    if(is.null(test)) {
        ## Get the summary statistics
        summary_mat <- matrix(round(unlist(lapply(NTS_list, summary)), digit = 3), ncol = 6, byrow = TRUE)
        colnames(summary_mat) <- names(summary(rnorm(10)))

        parameter_names <- gsub("\\.", "", parameter_names)
        ## Make the names matrix
        names_matrix <- cbind(rep(parameter_names[1:3], each = 18), # taxa
                              rep(rep(parameter_names[4:6], each = 6), 3),  # character
                              rep(rep(parameter_names[7:8], each = 3), 9),
                              rep(parameter_names[9:11], 18)) # scenario
        ## Combine all that
        if(convert.row.names) {
            ## Remove the t/c
            names_matrix <- gsub("t", "", names_matrix)
            names_matrix <- gsub("c", "", names_matrix)
            ## Sorting in the Method/taxa/character/scenario format
            results_out <- cbind(as.data.frame(names_matrix[,c(3,1,2,4)], stringsAsFactors= FALSE), as.data.frame(summary_mat))
            ## Sorting the rows by method
            results_out <- results_out[c(as.vector(combo_list[,1:9]), as.vector(combo_list[,10:18])),]
            rownames(results_out) <- 1:54
            ## Remove duplicated names
            results_out[-c(1,28), 1] <- "" #method
            results_out[-c(1,10,19,28,37,46), 2] <- "" #taxa
            results_out[-seq(from = 1, to = 52, by = 3), 3] <- "" #characters
            ## Adding the column names
            colnames(results_out)[1:4] <- c("method", "taxa", "characters", "correlation")

            return(results_out)
        } else {
            return(cbind(as.data.frame(names_matrix), as.data.frame(summary_mat)))
        }
    }

    pairwise.test <- function(list, test) {
        ## Apply the bhattacharya to all the pairwise elements of the list
        return(apply(combn(1:length(list), 2), 2, function(X) test(list[[X[[1]]]], list[[X[[2]]]])))
    }

    ## Calculate the pairwise bhattacharrya
    test_results <- apply(combo_list, 2, function(X) pairwise.test(NTS_list[X], test))

    if(class(test_results) == "matrix") {
        ## Get the column names (scenario)
        colnames(test_results) <- apply(combo_matrix, 2, function(X) paste(parameter_names[X], collapse = ""))
    
        ## Get the row names (min:max, etc..)
        rownames(test_results) <- c("minimised-maximised", "minimised-randomised", "maximised-randomised")

        ## Transpose the matrix for aesthetics
        test_results <- t(test_results)
    } else {
        ## Extracting the W and the p.value
        statistic <- lapply(test_results, lapply, `[[`, 1)
        p_value <- lapply(test_results, lapply, `[[`, 3)

        ## Getting the row and column names
        rownames <- apply(combo_matrix, 2, function(X) paste(parameter_names[X], collapse = ""))
        colnames <- c("minimised-maximised", "minimised-randomised", "maximised-randomised")

        ## Transform the results into a table format
        statistic_results <- matrix(data = unlist(statistic), ncol = 3, byrow = TRUE, dimnames = list(rownames, colnames))
        p_value_results <- matrix(data = unlist(p_value), ncol = 3, byrow = TRUE, dimnames = list(rownames, colnames))

        ## Saving the results
        test_results <- cbind(statistic_results[,1], p_value_results[,1], statistic_results[,2], p_value_results[,2], statistic_results[,3], p_value_results[,3])
        colnames(test_results) <- paste(rep(colnames, each = 2), c("W", "p"), sep = ":")
    }

    if(convert.row.names) {
        ## Convert into a data.frame
        test_results <- data.frame(test_results, stringsAsFactors = FALSE)

        ## Convert the row names into factors
        row_names_factors <- as.character(row.names(test_results))
        row_names_matrix <- t(as.data.frame(sapply(row_names_factors, strsplit, split = "\\."), stringsAsFactors = FALSE))

        ## Remove the t/c
        row_names_matrix <- gsub("t", "", row_names_matrix)
        row_names_matrix <- gsub("c", "", row_names_matrix)

        ## Remove the duplicated occurences of parsimony/bayesian
        row_names_matrix[-c(1,10),3] <- ""

        ## Remove the duplicated occurences of taxa numbers
        row_names_matrix[-c(1,4,7,10,13,16),1] <- ""

        ## Reorder columns
        row_names_matrix <- row_names_matrix[,c(3,1,2)]

        ## Combine the data frames
        test_results <- data.frame(row_names_matrix, test_results, stringsAsFactors = FALSE)

        ## Column names
        colnames(test_results)[1:3] <- c("method", "taxa", "characters")
    }



    return(test_results)
}


#' @title Applies a pairwise test to a (pooled) table or a list
#'
#' @description Applies a pairwise test to a (pooled) table or a list
#'
#' @param table a table or a list
#' @param test the test to apply
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export

apply.pair.test <- function(table, test) {
    ## Check if table is a table or a list
    if(class(table) == "matrix" || class(table) == "data.frame") {
        data_list <- unlist(apply(table, 2, list), recursive = FALSE)
    } else {
        data_list <- table
    }

    ## Get the pairwise combinations
    combinations <- combn(1:length(data_list), 2)
    combo_names <- apply(combinations, 2, function(X, data_list) return(paste(names(data_list)[X[1]], names(data_list)[X[2]], sep = ":")), data_list)

    ## Run the pairwise test
    apply.test <- function(combn_col, data_list, test) {
        return(test(data_list[[combn_col[1]]], data_list[[combn_col[2]]]))
    }
    results <- apply(combinations, 2, apply.test, data_list, test)

    ## Output the results
    if(class(results) == "numeric") {
        names(results) <- combo_names
        return(results)
    } else {
        remove.names <- function(X) {names(X) <- NULL; return(X)}
        results <- lapply(results, lapply, remove.names)
        names(results) <- combo_names
        return(list("statistic" = unlist(lapply(results, `[[`, 1)), "p.value" = unlist(lapply(results, `[[`, 3))))
    }
}


#' @title Applies a bhatt.coeff and a wilcox.test to a list of distributions and outputs a table
#'
#' @description Applies bhatt.coeff and a wilcox.test to a list of distributions and outputs a table
#'
#' @param distributions a list of distribution tables
#' @param digit how many digits to display
#' @param metric.label the metrics labels (can be missing)
#' @param comp.label the comparisons labels (can be missing)
#' @param correction which correction to apply
#' @param translate whether to translate the param names to the latest publication (maxi -> minimised, mini -> maximised, norm -> unperturbed, rand -> randomised)
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export
#' 
pair.test.table <- function(distributions, digit = 3, metric.label, comp.label, correction = "bonferroni", translate = TRUE) {

    tests <- c(bhatt.coeff, wilcox.test)

    ## Applying the tests
    results <- list()
    for(one_test in 1:length(tests)) {
        results[[one_test]] <- lapply(distributions, apply.pair.test, tests[[one_test]])
    }

    ## Summarizing the results
    table <- matrix(unlist(results[[1]]), ncol = 1)
    table <- cbind(table, matrix(c(unlist(sapply(results[[2]], function(X) X[[1]], simplify = FALSE)), unlist(sapply(results[[2]], function(X) X[[2]], simplify = FALSE))), ncol = 2))

    ## Adding the col/row names
    rownames(table) <- unlist(lapply(results[[1]], names))
    colnames(table) <- c("bhatt.coeff", "statistic", "p.value")

    ## Correcting the p.value
    table[,3] <- p.adjust(table[,3], method = correction)

    ## Rounding
    table <- round(table, digit = digit)

    ## Adding the metrics and comp (if not missing)
    if(!missing(metric.label) && !missing(comp.label)) {
        labels <- data.frame("comp" = comp.label, "metric" = metric.label, rownames(table))
        colnames(labels)[length(labels)] <- "test"
        table_out <- cbind(labels, as.data.frame(table))
    }

    ## Adding the metrics (if not missing)
    if(!missing(metric.label) && missing(comp.label)) {
        labels <- data.frame("metric" = metric.label, rownames(table))
        colnames(labels)[length(labels)] <- "test"
        table_out <- cbind(labels, as.data.frame(table))
    }

    ## Adding the comp (if not missing)
    if(missing(metric.label) && !missing(comp.label)) {
        labels <- data.frame("comp" = comp.label, rownames(table))
        colnames(labels)[length(labels)] <- "test"
        table_out <- cbind(labels, as.data.frame(table))
    }

    if(missing(metric.label) && missing(comp.label)) {
        table_out <- table
    }







        # ## Translate the param names
        # if(length(change <- which(param == "maxi")) > 0) {
        #     param[change] <- "minimised"
        #     change <- integer()
        # }
        # if(length(change <- which(param == "mini")) > 0) {
        #     param[change] <- "maximised"
        #     change <- integer()
        # }
        # if(length(change <- which(param == "rand")) > 0) {
        #     param[change] <- "randomised"
        #     change <- integer()
        # }
        # if(length(change <- which(param == "norm")) > 0) {
        #     param[change] <- "unperturbed"
        #     c









    return(table_out)
}