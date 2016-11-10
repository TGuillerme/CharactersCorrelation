#' @title Plots the correlation matrix
#'
#' @description Plots the correlation matrix.
#'
#' @param matrix A square correlation matrix.
#' @param col Two colors for forming the gradient.
#' @param legend A logical value stating whether to print the legend or not (default = \code{TRUE}).
#' @param legend.title A \code{character} string to be displayed as the title of the legend (default = \code{Difference}).
#' @param axis A logical value stating whether to print the axis or not (default = \code{TRUE}).
#' @param ... Any additional graphical arguments to be passed to \code{image}.
#' 
#' @examples
#' ##
#' 
#' @author Thomas Guillerme
#' @export
#' 

plot.cor.matrix <- function(matrix, col = c("blue", "orange"), legend = TRUE, legend.title = "Difference", axis = TRUE, ...) {

    ## Remove the upper triangle
    matrix[upper.tri(matrix)] <- NA

    ## Setting the colours
    colfunc <- grDevices::colorRampPalette(col)
    colheat <- colfunc(10)

    ## Plotting the heat map
    image(matrix, col = colheat, axes = FALSE, ...)
    if(axis) {
        axis(1, at = seq(from = 0, to = 1, length.out = ncol(matrix)), labels = FALSE, tick = TRUE)
        axis(2, at = seq(from = 0, to = 1, length.out = ncol(matrix)), labels = FALSE, tick = TRUE)
    }

    ## Adding the legend
    if(legend) {
        legend("topleft", legend = c(as.character(round(max(matrix, na.rm = TRUE), 2)), as.character(round(min(matrix, na.rm = TRUE), 2))), title = legend.title, col = col, pch = 19)
    }
}
