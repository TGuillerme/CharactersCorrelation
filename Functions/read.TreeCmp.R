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
    if(class(chain) != 'character') {
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

    flip.list <- function(matrices_list, ncol, nrow) {
        splitted_matrices <- lapply(matrices_list, function (X) split(t(X), rep(1:ncol, each = nrow)))
        names <- colnames(matrices_list[[1]])
            
        flipidy.flop <- function(element, splitted_matrices, nrow, names) {
            return(matrix(unlist(lapply(splitted_matrices, `[[`, element)), byrow = TRUE, ncol = nrow, dimnames = list(c(),names)))
        }

        return(lapply(as.list(1:5), flipidy.flop, splitted_matrices, nrow, names))

    }

    flipped_matrices_norm <- flip.list(matrices_norm, 5, 4)
    flipped_matrices_rand <- flip.list(matrices_rand, 5, 4)
    names(flipped_matrices_norm) <- names(flipped_matrices_rand) <- c("norm", "maxi", "mini", "rand", "true")

    return(list("norm" = flipped_matrices_norm, "rand" = flipped_matrices_rand))
}
