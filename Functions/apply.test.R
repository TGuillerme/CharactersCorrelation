#' @title apply test
#'
#' @description applies pairwise tests to the dataset
#'
#' @param data the global dataset
#' @param metric which metric to use
#' @param best which best tree (rand or norm)
#' @param test which test (if NULL, simply summarises the distribution)
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export

apply.test <- function(data, metric, best, test) {

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
        parameter_names <- c(parameter_names, c("maxi", "mini", "rand"))
    } else {
        parameter_names <- c(parameter_names, c("norm", "maxi", "mini"))
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
                              rep(parameter_names[7:8], 27),
                              rep(parameter_names[9:11], 18)) # method
        ## Combine all that
        return(cbind(as.data.frame(names_matrix), as.data.frame(summary_mat)))
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
        rownames(test_results) <- c("max-min", "max-rand", "min-rand")

        ## Transpose the matrix for aesthetics
        test_results <- t(test_results)
    } else {
        ## Extracting the W and the p.value
        statistic <- lapply(test_results, lapply, `[[`, 1)
        p_value <- lapply(test_results, lapply, `[[`, 3)

        ## Getting the row and column names
        rownames <- apply(combo_matrix, 2, function(X) paste(parameter_names[X], collapse = ""))
        colnames <- c("max-min", "max-rand", "min-rand")

        ## Transform the results into a table format
        statistic_results <- matrix(data = unlist(statistic), ncol = 3, byrow = TRUE, dimnames = list(rownames, colnames))
        p_value_results <- matrix(data = unlist(p_value), ncol = 3, byrow = TRUE, dimnames = list(rownames, colnames))

        ## Saving the results
        test_results <- cbind(statistic_results[,1], p_value_results[,1], statistic_results[,2], p_value_results[,2], statistic_results[,3], p_value_results[,3])
        colnames(test_results) <- paste(rep(colnames, each = 2), c("W", "p"), sep = ":")
    }

    return(test_results)
}