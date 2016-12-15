#' @title Modify matrix
#'
#' @description Modifies a matrix to minimise/maximise differences among characters
#'
#' @param matrix A discrete morphological matrix.
#' @param type Whether to \code{"maximise"}, \code{"minimise"} or \code{"randomise"} character differences.
#' @param threshold The threshold value beyond/above which to maximise/minimise.
##' @param character.differences Optional, a pre-calculated character difference matrix (if missing, the matrix is calculated from \code{matrix}).
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

modify.matrix <- function(matrix, type = "maximise", threshold = 0.25) {#, character.differences) {

    ## Get the worst characters
    get.worst.characters <- function(matrix, type, threshold) {

        ## Calculate the median character difference
        #median_char_diff <- apply(char.diff(matrix), 2, median, na.rm = TRUE)

        ## Calculate the quantiles
        if(type == "maximise") {
            median_char_diff <- apply(char.diff(matrix), 2, quantile, probs = 0.25, na.rm = TRUE)
        } else {
            median_char_diff <- apply(char.diff(matrix), 2, quantile, probs = 0.75, na.rm = TRUE)
        }

        ## Select the worst characters
        if(type == "maximise") {
            return(which(median_char_diff < threshold))
        } else {
            return(which(median_char_diff > threshold))
        }
    }
    
    ## Backup the matrix
    matrix_modified <- matrix

    if(type != "randomise") {
        ## Get the worst characters
        worst_characters <- get.worst.characters(matrix_modified, type, threshold)

        ## Set up the resampling values
        if(length(worst_characters) == 0 | length(worst_characters) == ncol(matrix_modified)) {
            sampling_pool <- seq(1:ncol(matrix_modified))
            resample <- length(sampling_pool)
            warning("All characters were below/above the threshold, the matrix as just been randomly reshuffled.")
        } else {
            sampling_pool <- seq(1:ncol(matrix_modified))[-worst_characters]
            resample <- length(worst_characters)
        }

        ## Replace the worst characters (randomly)
        matrix_modified[, worst_characters] <- matrix_modified[, sample(sampling_pool, resample, replace = TRUE)]

        #length(get.worst.characters(new_matrix, type, threshold))

    } else {
        ## Randomise the matrix
        worst_characters_max <- get.worst.characters(matrix_modified, "maximise", 0.25)
        worst_characters_min <- get.worst.characters(matrix_modified, "minimise", 0.75)
        
        ## Select the number of characters to change
        resample <- mean(length(worst_characters_max), length(worst_characters_min))
        if(resample == 0) {
            resample <- ncol(matrix_modified)
        }

        matrix_modified[, sample(1:ncol(matrix_modified), resample)] <- matrix_modified[, sample(1:ncol(matrix_modified), resample, replace = TRUE)]
    }

    return(matrix_modified)
}