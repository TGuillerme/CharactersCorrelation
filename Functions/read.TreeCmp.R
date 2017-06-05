#' @title Read in the TreeCmp results
#'
#' @description Read in as a list the results from the different tree comparisons
#'
#' @param chain the general name of the chain (e.g. 25t_100c)
#' @param path the path to where the files are stored
#'
#' @return
#' A list of metrics for the comparisons.
#' 
#' @examples
#' ##
#' 
#' @author Thomas Guillerme
#' @export
#' 

#path_alt <- "/Users/TGuillerme/Projects/CharactersCorrelation/Data/Trees_out/Consensus_trees/Parsimony"

read.TreeCmp <- function(chain, path = "/Users/TGuillerme/Projects/CharactersCorrelation/Data/Trees_out/Consensus_trees", type = "Bayesian") {

    path <- paste(path, type, sep = "/")

    ## Sanitizing
    if(class(chain) !='character') {
        stop('No files has been found within the given chain name.')
    }

    ## Get the different files within the path
    files_norm <- list.files(paste(paste(path, chain, sep = "/"), "_cmp_norm/", sep =""))
    if(length(files_norm) == 0) {
        stop('No files for norm has been found within the given chain name.')
    }

    files_rand <- list.files(paste(paste(path, chain, sep = "/"), "_cmp_rand/", sep =""))
    if(length(files_rand) == 0) {
        stop('No files for rand has been found within the given chain name.')
    }


    ## Load all the files
    matrices_norm <- list()
    message("Reading the TreeCmp results (norm):", appendLF = FALSE)
    for(file in 1:length(files_norm)) {
        matrices_norm[[file]] <- as.data.frame(read.table(paste(paste(path, chain, sep = "/"), "_cmp_norm/",files_norm[[file]], sep = ""), header = TRUE, row.names = 1))
        message(".", appendLF = FALSE)
    }
    message("Done.\n", appendLF = FALSE)

    matrices_rand <- list()
    message("Reading the TreeCmp results (rand):", appendLF = FALSE)
    for(file in 1:length(files_rand)) {
        matrices_rand[[file]] <- as.data.frame(read.table(paste(paste(path, chain, sep = "/"), "_cmp_rand/",files_rand[[file]], sep = ""), header = TRUE, row.names = 1))
        message(".", appendLF = FALSE)
    }
    message("Done.\n", appendLF = FALSE)


    ## Set up the list for the combined results
    message("Combining the TreeCmp results (norm):", appendLF = FALSE)
    file = 1
    norm_norm <- as.matrix(lapply(as.list(matrices_norm[[file]]), `[[`, 1))
    maxi_norm <- as.matrix(lapply(as.list(matrices_norm[[file]]), `[[`, 2))
    mini_norm <- as.matrix(lapply(as.list(matrices_norm[[file]]), `[[`, 3))
    rand_norm <- as.matrix(lapply(as.list(matrices_norm[[file]]), `[[`, 4))
    true_norm <- as.matrix(lapply(as.list(matrices_norm[[file]]), `[[`, 5))
    
    message(".", appendLF = FALSE)

    for(file in 2:length(matrices_norm)) {
        norm_norm <- cbind(norm_norm, as.matrix(lapply(as.list(matrices_norm[[file]]), `[[`, 1)))
        maxi_norm <- cbind(maxi_norm, as.matrix(lapply(as.list(matrices_norm[[file]]), `[[`, 2)))
        mini_norm <- cbind(mini_norm, as.matrix(lapply(as.list(matrices_norm[[file]]), `[[`, 3)))
        rand_norm <- cbind(rand_norm, as.matrix(lapply(as.list(matrices_norm[[file]]), `[[`, 4)))
        true_norm <- cbind(true_norm, as.matrix(lapply(as.list(matrices_norm[[file]]), `[[`, 5)))
        message(".", appendLF = FALSE)
    }
    message("Done.\n", appendLF = FALSE)

    ## Set up the list for the combined results
    message("Combining the TreeCmp results (rand):", appendLF = FALSE)
    file = 1
    norm_rand <- as.matrix(lapply(as.list(matrices_rand[[file]]), `[[`, 1))
    maxi_rand <- as.matrix(lapply(as.list(matrices_rand[[file]]), `[[`, 2))
    mini_rand <- as.matrix(lapply(as.list(matrices_rand[[file]]), `[[`, 3))
    rand_rand <- as.matrix(lapply(as.list(matrices_rand[[file]]), `[[`, 4))
    true_rand <- as.matrix(lapply(as.list(matrices_rand[[file]]), `[[`, 5))
    
    message(".", appendLF = FALSE)

    for(file in 2:length(matrices_rand)) {
        norm_rand <- cbind(norm_rand, as.matrix(lapply(as.list(matrices_rand[[file]]), `[[`, 1)))
        maxi_rand <- cbind(maxi_rand, as.matrix(lapply(as.list(matrices_rand[[file]]), `[[`, 2)))
        mini_rand <- cbind(mini_rand, as.matrix(lapply(as.list(matrices_rand[[file]]), `[[`, 3)))
        rand_rand <- cbind(rand_rand, as.matrix(lapply(as.list(matrices_rand[[file]]), `[[`, 4)))
        true_rand <- cbind(true_rand, as.matrix(lapply(as.list(matrices_rand[[file]]), `[[`, 5)))
        message(".", appendLF = FALSE)
    }
    message("Done.\n", appendLF = FALSE)

    return(list("norm" = list("norm" = as.list(t(norm_norm)), "maxi" = as.list(t(maxi_norm)), "mini" = as.list(t(mini_norm)), "rand" = as.list(t(rand_norm)), "true" = as.list(t(true_norm))), "rand" = list("norm" = as.list(t(norm_rand)), "maxi" = as.list(t(maxi_rand)), "mini" = as.list(t(mini_rand)), "norm" = as.list(t(rand_rand)), "true" = as.list(t(true_rand)))))
}
