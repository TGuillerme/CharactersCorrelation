#' @title Plots the character difference density
#'
#' @description Plots the character difference density profile
#'
#' @param matrix A square correlation matrix.
#' @param legend The text of the legend. Default is \code{c("Combined", "Individual")}.
#' @param col Two colors for the different densities: the first color is used for cumulative density and the second for individual characters' ones. Default is \code{col = c("black", "grey")}.
#' @param legend.pos The position of the legend. Can be two \code{numeric}. Default is \code{"topleft"}.
#' @param ... Any additional graphical arguments to be passed to \code{plot}. See details.
#' 
#' @details
#' Note that \code{main} will use \code{"Character differences profile"} as default; \code{xlab} uses \code{"Character differences"} and \code{ylab} uses \code{"Density"}.
#' 
#' @examples
#' ##
#' 
#' @author Thomas Guillerme
#' @export
#' 


plot.char.diff.density <- function(matrix, main, legend, col, xlim, ylim, legend.pos, xlab, ylab) {

    ## Functions for getting the the density plot limits
    get.max.x <- function(density) return(max(density$x))
    get.max.y <- function(density) return(max(density$y))
    get.min.x <- function(density) return(min(density$x))
    get.min.y <- function(density) return(min(density$y))

    ## Default options:
    if(missing(main)) {
        main = "Character differences profile"
    }
    if(missing(legend)) {
        legend = c("Combined", "Individual")
    }
    if(missing(col)) {
        col = c("black", "grey")
    }
    if(missing(xlab)) {
        xlab = "Character differences"
    }
    if(missing(ylab)) {
        ylab = "Density"
    }
    if(missing(legend.pos)) {
        legend.pos = "topleft"
    }
    ## Calculating the character difference matrix
    chara_diff <- char.diff(matrix)

    ## Measuring the densities
    densities <- apply(chara_diff, 2, density, na.rm = TRUE)

    if(missing(xlim)) {
        xlim = c(min(unlist(lapply(densities, get.min.x))), max(unlist(lapply(densities, get.max.x))))
    }
    if(missing(ylim)) {
        ylim = c(min(unlist(lapply(densities, get.min.y))), max(unlist(lapply(densities, get.max.y))))
    }

    ## Measuring the cumulated density
    cum_density <- density(as.numeric(chara_diff), na.rm = TRUE)

    ## Empty plot
    plot(1,1, col = "white", xlim = xlim, ylim = ylim, main = main, xlab = xlab, ylab = ylab, bty = "n")

    ## Adding the densities
    silent <- lapply(densities, lines, col = col[2])

    ## Adding the cumulative density
    lines(cum_density, col = col[1])

    ## Adding the legend
    legend(legend.pos, legend = legend, lty = 1, col = col)
}