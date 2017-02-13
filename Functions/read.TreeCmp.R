#' @title Read in the TreeCmp results
#'
#' @description Read in as a list the results from the different tree comparisons
#'
#' @param chain the general name of the chain (e.g. 25t_100c)
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

read.TreeCmp <- function(chain, true = FALSE) {
    ## Sanitizing
    if(class(chain) !='character') {
        stop('No files has been found within the given chain name.')
    }

    ## Get the different files within the path
    files <- list.files(paste(chain, "_cmp/", sep =""))
    if(length(files) == 0) {
        stop('No files has been found within the given chain name.')
    }

    ## Load all the files
    matrices <- list()
    message("Reading the TreeCmp results:", appendLF = FALSE)
    for(file in 1:length(files)) {
        matrices[[file]] <- as.data.frame(read.table(paste(chain, "_cmp/",files[[file]], sep = ""), header = TRUE, row.names = 1))
        message(".", appendLF = FALSE)
    }
    message("Done.\n", appendLF = FALSE)

    ## Set up the list for the combined results
    message("Combining the TreeCmp results:", appendLF = FALSE)
    file = 1
    if(!true) {
        maxi <- as.matrix(lapply(as.list(matrices[[file]]), `[[`, 1))
        mini <- as.matrix(lapply(as.list(matrices[[file]]), `[[`, 2))
        rand <- as.matrix(lapply(as.list(matrices[[file]]), `[[`, 3))
    } else {
        norm <- as.matrix(lapply(as.list(matrices[[file]]), `[[`, 1))
    }
    message(".", appendLF = FALSE)

    for(file in 2:length(matrices)) {
        if(!true) {
            maxi <- cbind(maxi, as.matrix(lapply(as.list(matrices[[file]]), `[[`, 1)))
            mini <- cbind(mini, as.matrix(lapply(as.list(matrices[[file]]), `[[`, 2)))
            rand <- cbind(rand, as.matrix(lapply(as.list(matrices[[file]]), `[[`, 3)))
        } else {
            norm <- cbind(norm, as.matrix(lapply(as.list(matrices[[file]]), `[[`, 1)))
        }
        message(".", appendLF = FALSE)
    }
    message("Done.\n", appendLF = FALSE)

    if(!true) {
        return(list("maxi" = as.list(t(maxi)), "mini" = as.list(t(mini)), "rand" = as.list(t(rand))))
    } else {
        return(list("norm" = as.list(t(norm))))
    }
}
