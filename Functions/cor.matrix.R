#' @title Correlation matrix
#'
#' @description Computes the pairwise correlation between each characters of a matrix.
#'
#' @param matrix A discrete morphological matrix.
#' @param diff.fun A function for computing the difference (must intake at least two arguments \code{X} and \code{Y}).
#' @param verbose A logical value stating whether to be verbose or not (default = \code{FALSE}).
#'
#' @return
#' A pairwise comparison matrix.
#' 
#' @examples
#' ##
#' 
#' @author Thomas Guillerme
#' @export
#' 

cor.matrix <- function(matrix, diff.fun, verbose = FALSE) {

    # Apply function for the loop
    apply.diff.fun <- function(x, matrix, verbose, diff.fun) {
        # Calculates the difference between two characters taken from the combination matrix (x)
        difference <- diff.fun(matrix[,x[1]], matrix[,x[2]])
        if(verbose != FALSE) {cat(".")}
        return(difference)
    }

    if(verbose) {cat("Calculating the pairwise characters differences: ")}
    
    # Get the combination matrix
    comb_matrix <- combn(1:ncol(matrix), 2)

    # Calculating the pairwise differences
    differences <- apply(comb_matrix, 2, apply.diff.fun, matrix = matrix, verbose = verbose, diff.fun = diff.fun)

    if(verbose) {cat("Done.")}

    # Create the empty matrix
    differences_matrix <- matrix(data = NA, ncol = ncol(matrix), nrow = ncol(matrix))
    # Set up the diagonal (no difference)
    diag(differences_matrix) <- diff.fun(matrix[,1], matrix[,1])
    # Fill up the lower triangle
    differences_matrix[lower.tri(differences_matrix, diag = FALSE)] <- differences

    return(differences_matrix)
}