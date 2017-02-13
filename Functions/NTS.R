#' @title Normalised Tree Similarity
#'
#' @description Calculates the normalised tree similarity function of the number of taxa
#'
#' @param data A list of tree difference metrics
#' @param taxa The number of taxa (25, 75 or 150).
#' 
#' @examples
#' ##
#' 
#' @author Thomas Guillerme
#' @export
#' 

get.NTS <- function(obs, rand) {
    return( (rand - obs)/rand )
}

apply.NTS <- function(matrix, rand) {
    mat_out <- matrix
    for(col in 1:4) {
        mat_out[,col] <- get.NTS(unlist(matrix[,col]), rand[col])
    }
    return(mat_out)
}


NTS <- function(data, taxa) {
    ## Sanitizing
    ## TODO!
    # if(class(data) != "list") {
    #     stop("Data must be a list of metric score tables")
    # }

    ## Load the random data
    load("../Data/NTS/matrix.nts.Rda")
    rand <- matrix_nts[which(rownames(matrix_nts) == taxa), ]

    ## Calculate the NTS
    return(lapply(data, apply.NTS, rand))
}