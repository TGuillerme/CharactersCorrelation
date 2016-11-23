#' @title Modify matrix
#'
#' @description Modifies a matrix to minimise/maximise differences among characters
#'
#' @param matrix A discrete morphological matrix.
#' @param type Whether to \code{"maximise"}, \code{"minimise"} or \code{"randomise"} character differences.
#' @param threshold The threshold value beyond/above which to maximise/minimise.
#' @param character.differences Optional, a pre-calculated character difference matrix (if missing, the matrix is calculated from \code{matrix}).
#'
#' @return
#' A modified matrix.
#' 
#' @examples
#' ##
#' 
#' @author Thomas Guillerme
#' @export
#' 

modify.matrix <- function(matrix, type = "maximise", threshold = 0.25, character.differences) {
    ## Backup the matrix
    matrix_modified <- matrix

    if(missing(character.differences)) {
        ## Calculate the character differences
        character_differences <- char.diff(matrix)
    } else {
        character_differences <- character.differences
    }

    ## Get the worst characters
    get.worst.characters <- function(matrix, type, threshold, character.differences = character_differences) {

        ## Set up the quantile threshold (i.e. for maximising difference, remove characters that have 5% of their differences lower than the threshold; for minimising, remove characters that have 95% of their differences higher than the threshold).
        if(type == "maximise") {
            quantile.threshold = 0.05
        } else {
            quantile.threshold = 0.75
        }

        ## Calculate the quantiles
        quantiles <- apply(character_differences, 2, quantile, probs = c(quantile.threshold), na.rm = TRUE)

        ## Select the worst characters
        if(type == "maximise") {
            worst_characters <- which(quantiles < threshold)
        } else {
            worst_characters <- which(quantiles > threshold)
        }
    }
    

    if(type != "randomise") {
        ## Get the worst characters
        worst_characters <- get.worst.characters(matrix_modified, type, threshold)
        ## Replace the worst characters (randomly)
        if(length(worst_characters) !=  ncol(matrix)) {
            ## If any characters are left to be replace
            matrix_modified[,worst_characters] <- matrix_modified[,sample(seq(1:ncol(matrix_modified))[-worst_characters], length(worst_characters), replace = TRUE)]
        } else {
            ## Randomly reshuffle the matrix for consistency
            matrix_modified <- matrix_modified[,sample(seq(1:ncol(matrix_modified)), ncol(matrix_modified), replace = TRUE)]
            if(type == "maximise") {
                warning("All characters were below the threshold, the matrix as just been randomly reshuffled.")
            } else {
                warning("All characters were above the threshold, the matrix as just been randomly reshuffled.")
            }

        }
    } else {
        ## Randomise the matrix
        worst_characters_max <- get.worst.characters(matrix_modified, "maximise", 0.25)
        worst_characters_min <- get.worst.characters(matrix_modified, "minimise", 0.75)
        ## Select the number of characters to change
        if(length(worst_characters_max) > 0 & length(worst_characters_min) > 0) {
            ## Select the average number of characters randomly
            worst_characters <- sample(1:ncol(matrix_modified), c(length(worst_characters_max)+length(worst_characters_min))/2)
            matrix_modified[,worst_characters] <- matrix_modified[,sample(seq(1:ncol(matrix_modified))[-worst_characters], length(worst_characters), replace = TRUE)]
        } else {
            if(length(worst_characters_max) != 0) {
                ## Select just the number of max
                worst_characters <- sample(1:ncol(matrix_modified), length(worst_characters_max))
                matrix_modified[,worst_characters] <- matrix_modified[,sample(seq(1:ncol(matrix_modified))[-worst_characters], length(worst_characters), replace = TRUE)]                
            } else {
                if(length(worst_characters_min) != 0) {
                    ## Select just the number of min
                    worst_characters <- sample(1:ncol(matrix_modified), length(worst_characters_min))
                    matrix_modified[,worst_characters] <- matrix_modified[,sample(seq(1:ncol(matrix_modified))[-worst_characters], length(worst_characters), replace = TRUE)]       
                } else {
                    ## Randomly reshuffle the matrix for consistency
                    matrix_modified <- matrix_modified[,sample(seq(1:ncol(matrix_modified)), ncol(matrix_modified), replace = TRUE)]                    
                }
            }
        }

    }

    return(matrix_modified)
}