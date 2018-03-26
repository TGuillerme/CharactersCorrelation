#' @title Get matrices CD
#'
#' @description Get the matrices character difference of a chain
#'
#' @param chain The chain name (e.g. "25t_100c")
#' @param path The path (e.g. "../Data/Simulations/Matrices")
#' @param verbose whether to be verbose or not.
#' @param length.out optional, how many matrices to analyse
#' @param cent.tend optional, whether to summarise the results directly
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export
get.matrix.CD <- function(chain, path, verbose = FALSE, length.out, cent.tend = NULL) {
    ## Get the chain names
    chain_names <- list.files(path, pattern = chain)

    ## Split per matrix type
    matrix_types <- list("norm", "mini", "maxi", "rand")
    split.per.type <- function(type, chain_names, length.out) {
        if(missing(length.out)) {
            return(as.list(chain_names[grep(type, chain_names)]))
        } else {
            return(as.list(chain_names[grep(type, chain_names)][1:length.out]))
        }
    }
    if(length.out < length(chain_names)) {
        chain_names_type <- lapply(matrix_types, split.per.type, chain_names, length.out)
    } else {
        chain_names_type <- lapply(matrix_types, split.per.type, chain_names)
        warning(paste0("Only ", length(chain_names), " matrices loaded."))
    }

    ## Load one matrix and calculate the CD
    get.one.CD <- function(one_chain, path, verbose = FALSE) {
        matrix_list <- read.nexus.data(paste0(path, "/", one_chain))
        matrix <- matrix(unlist(matrix_list), nrow = length(matrix_list), ncol = length(matrix_list[[1]]), byrow = TRUE)
        char_diff <- char.diff(matrix)
        if(verbose) message(".", appendLF = FALSE)
        return(char_diff)
    }

    if(verbose) message(paste0("Getting character difference for ", chain, ":"))
    character_differences <- lapply(chain_names_type, lapply, get.one.CD, path, verbose = verbose)
    if(verbose) message("Done.\n", appendLF = FALSE)

    ## Name the list
    names(character_differences) <- matrix_types

    ## summarises
    if(!is.null(cent.tend)) {
        character_differences <- lapply(character_differences, lapply, function(X, cent.tend) return(cent.tend(as.numeric(X))), cent.tend)
    }

    return(character_differences)
}


#' @title Get all matrices CD
#'
#' @description Get the matrices character difference of a chain
#'
#' @param path The path (e.g. "../Data/Simulations/Matrices")
#' @param verbose whether to be verbose or not.
#' @param length.out optional, how many matrices to analyse
#' @param cent.tend optional, whether to summarise the results directly
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export
get.all.matrix.CD <- function(path, verbose = FALSE, length.out, cent.tend = NULL) {

    ## Get all the chains
    taxa <- paste0(c(25, 75, 150), "t")
    characters <- paste0(c(100, 350, 1000), "c")
    all_chains <- lapply(as.list(taxa), function(taxa, characters) return(as.list(paste(taxa, characters, sep = "_"))), characters)

    ## Apply get.matrix.CD on all_chains
    all_char_diff <- list()
    for(tax in 1:length(taxa)) {
        all_char_diff[[tax]] <- list()
        for(char in 1:length(characters)) {
            all_char_diff[[tax]][[char]] <- get.matrix.CD(path = path, chain = all_chains[[tax]][[char]], verbose = verbose, length.out = length.out, cent.tend = cent.tend)
        }
        names(all_char_diff[[tax]]) <- characters
    }
    names(all_char_diff) <- taxa

    return(all_char_diff)
}


#' @title Pool results matrix CD
#'
#' @description Pools the results of the difference CD matrices
#'
#' @param list the list of matrices
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export

pool.matrix.cd <- function(list, length.out) {

    ## The results are a list from get.matrix.CDs
    norm <- unlist(lapply(list, lapply, function(X) return(X$norm[1:length.out])))
    mini <- unlist(lapply(list, lapply, function(X) return(X$mini[1:length.out])))
    maxi <- unlist(lapply(list, lapply, function(X) return(X$maxi[1:length.out])))
    rand <- unlist(lapply(list, lapply, function(X) return(X$rand[1:length.out])))

    return(list("norm" = norm, "mini" = mini, "maxi" = maxi, "rand" = rand))
}

#' @title Runs one linear model
#'
#' @description Runs one linear model
#'
#' @param matrix_cd the list of matrices with CD values
#' @param whole_data the list of all the data
#' @param chain the chain name (corresponding to the one used to obtain the matrix_cd). Use "pool" to pool the whole data.
#' @param metric which metric to plot (\code{"RF"} or \code{"Triplets"})
#' @param method which method to plot (\code{"Bayesian"} or \code{"Parsimony"}) 
#' @param cent.tend the central tendency to plot for matrix_cd (\code{default = mean})
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export

run.lm <- function(matrices_cd, whole_data, chain, metric, method, cent.tend = NULL) {

    ## Get the metric
    if(metric == "RF") {
        metric_value <- 2
    } else {
        if(metric == "Triplets") {
            metric_value <- 4
        } else {
            stop("metric must be \"RF\" or \"Triplets\".")
        }
    }

    ## Get the method
    if(method == "Bayesian") {
        method_value <- 1
    } else {
        if(method == "Parsimony") {
            method_value <- 2
        } else {
            stop("method must be \"Bayesian\" or \"Parsimony\".")
        }
    }

    ## Length of matrices_cd
    length.out <- length(matrices_cd[[1]])
    # if(chain == "pool") {
    #     length.out <- length(matrices_cd[[1]])
    # }

    ## Get the chain values
    if(chain != "pool") {
        chain_values <- strsplit(chain, split = "_")[[1]]
        taxa_number <- as.numeric(strsplit(chain_values[1], split = "t")[[1]])
        if(!taxa_number %in% c(25, 75, 150)) {
            stop(paste0("In ", chain, " taxa number (#t) must be 25, 75 or 150."))
        }
        if(taxa_number == 25) {
            taxa_value <- 1
        } else {
            taxa_value <- ifelse(taxa_number == 75, 2, 3)
        }
        character_number <- as.numeric(strsplit(chain_values[2], split = "c")[[1]])
        if(!character_number %in% c(100, 350, 1000)) {
            stop(paste0("In ", chain, " character number (#c) must be 100, 350 or 1000."))
        }
        if(character_number == 100) {
            character_value <- 1
        } else {
            character_value <- ifelse(taxa_number == 350, 2, 3)
        }

        ## Double check length.out
        length_whole_data <- length(whole_data[[taxa_value]][[character_value]][[method_value]]$norm$mini[, metric_value])
        if(length.out > length_whole_data) {
            length.out <- length_whole_data
        }
    }


    if(chain != "pool") {
        data_metric <- data.frame(
            "Metric" = c(whole_data[[taxa_value]][[character_value]][[method_value]]$norm$mini[, metric_value][1:length.out],
                         whole_data[[taxa_value]][[character_value]][[method_value]]$norm$maxi[, metric_value][1:length.out],
                         whole_data[[taxa_value]][[character_value]][[method_value]]$norm$rand[, metric_value][1:length.out]
                        )
                    )
    } else {
        warning("DEBUG: Change length.out value in run.lm and one.correlation.plot")
        length.out <- 28
        data_metric <- data.frame(
            "Metric" = c(
                unlist(lapply(whole_data, lapply, function(X, method_value, metric_value, length.out) return(X[[method_value]]$norm$mini[1:length.out, metric_value]), method_value, metric_value, length.out)),
                unlist(lapply(whole_data, lapply, function(X, method_value, metric_value, length.out) return(X[[method_value]]$norm$maxi[1:length.out, metric_value]), method_value, metric_value, length.out)),
                unlist(lapply(whole_data, lapply, function(X, method_value, metric_value, length.out) return(X[[method_value]]$norm$rand[1:length.out, metric_value]), method_value, metric_value, length.out))
                )
            )
    }

    ## Getting the data table ready
    if(!is.null(cent.tend)) {
        data_CD <- data.frame(
                "CD" = c(unlist(lapply(matrices_cd$mini, cent.tend))[1:length.out],
                         unlist(lapply(matrices_cd$maxi, cent.tend))[1:length.out],
                         unlist(lapply(matrices_cd$rand, cent.tend))[1:length.out])
        )
    } else {
        data_CD <- data.frame(
            "CD" = c(unlist(matrices_cd$mini)[1:length.out],
                     unlist(matrices_cd$maxi)[1:length.out],
                     unlist(matrices_cd$rand)[1:length.out])
        )
    }

    data_table <- cbind(data_metric, data_CD)


    ## Running the model
    return(lm(Metric ~ CD, data = data_table))
}


#' @title Runs all linear model
#'
#' @description Runs all linear model
#'
#' @param all_matrix_cd the list of matrices with CD values
#' @param whole_data the list of all the data
#' @param metric which metric to plot (\code{"RF"} or \code{"Triplets"})
#' @param method which method to plot (\code{"Bayesian"} or \code{"Parsimony"}) 
#' @param cent.tend optional, the central tendency to plot for matrix_cd (\code{default = mean})
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export

run.all.lm <- function(all_matrices_cd, whole_data, metric, method, cent.tend = NULL) {

    ## Get all the chains
    taxa <- paste0(c(25, 75, 150), "t")
    characters <- paste0(c(100, 350, 1000), "c")
    all_chains <- lapply(as.list(taxa), function(taxa, characters) return(as.list(paste(taxa, characters, sep = "_"))), characters)

    ## Run all the lms
    all_models_out <- list()
    for(tax in 1:length(all_matrices_cd)) {
        all_models_out[[tax]] <- list()
        for(char in 1:length(all_matrices_cd[[1]])) {
            all_models_out[[tax]][[char]] <- run.lm(all_matrices_cd[[tax]][[char]], whole_data, chain = all_chains[[tax]][[char]], method = method, metric = metric, cent.tend = cent.tend)
        }
        names(all_models_out[[tax]]) <- characters
    }
    names(all_models_out) <- taxa

    return(all_models_out)
}
