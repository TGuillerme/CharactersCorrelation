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
    characters.to.replace <- function(char_diff_matrix, type, threshold) {
        ## Calculate the quantiles
        if(type == "maximise") {
            median_char_diff <- apply(char_diff_matrix, 2, quantile, probs = 0.25, na.rm = TRUE)
            ## Select the characters to replace
            return(which(median_char_diff < threshold))
        } else {
            median_char_diff <- apply(char_diff_matrix, 2, quantile, probs = 0.75, na.rm = TRUE)
            ## Select the characters to replace
            return(which(median_char_diff > threshold))
        }
    }
    
    ## Backup the matrix
    matrix_modified <- matrix

    ## Calculate the character differences
    char_diff_matrix_CD1 <- char.diff(matrix)

    ## Calculate the overall average character difference
    overal_CD1 <- mean(char_diff_matrix_CD1[upper.tri(char_diff_matrix_CD1)])

    select.characters <- function(char_diff_matrix_CD1, type, threshold, matrix_modified) {
 
        if(type != "randomise") {
            ## Get the worst characters
            char_to_replace <- characters.to.replace(char_diff_matrix_CD1, type, threshold)

            ## Set up the resampling values
            if(length(char_to_replace) == 0 | length(char_to_replace) == ncol(matrix_modified)) {

                ## Simulation failed
                return(FALSE)
                # sampling_pool <- seq(1:ncol(matrix_modified))
                # resample <- length(sampling_pool)
                # warning("All characters were below/above the threshold, the matrix as just been randomly reshuffled.")
            } else {
                sampling_pool <- seq(1:ncol(matrix_modified))[-char_to_replace]
                resample <- length(char_to_replace)
            }

            ## Replace the worst characters (randomly)
            char_replace_by <- sample(sampling_pool, resample, replace = TRUE)

        } else {
            ## Randomise the matrix
            char_to_replace_max <- characters.to.replace(char_diff_matrix_CD1, type = "maximise", threshold = 0.25)
            char_to_replace_min <- characters.to.replace(char_diff_matrix_CD1, type = "minimise", threshold = 0.75)
            
            ## Select the number of characters to change
            resample <- mean(length(char_to_replace_max), length(char_to_replace_min))
            if(resample == 0) {
                resample <- ncol(matrix_modified)
            }

            ## Characters to replace
            char_to_replace <- sample(1:ncol(matrix_modified), resample)
            char_replace_by <- sample(1:ncol(matrix_modified), resample, replace = TRUE)
        }

        return(list("to" = char_to_replace, "by" = char_replace_by))
    }

    ## Select the characters to replace
    replace <- select.characters(char_diff_matrix_CD1, type, threshold, matrix_modified)

    ## Simulation failed
    if(class(replace) == "logical") {
        return(FALSE)
    }

    ## Modify the matrix
    matrix_modified[, replace$to] <- matrix_modified[, replace$by]

    ## Calculate the new character differences
    char_diff_matrix_CD2 <- char.diff(matrix_modified)

    ## Calculate the new overall average character difference
    overal_CD2 <- mean(char_diff_matrix_CD2[upper.tri(char_diff_matrix_CD2)])

    ## Check whether the replacement worked
    counter <- 0
    check.work <- function(type, overal_CD1, overal_CD2) {
        if(type == "maximised") {
            ## Maximised imply the new CD is higher
            did_work <- overal_CD2 > overal_CD1
        } else {
            if(type == "minimised") {
                ## Minimised imply the new CD is lower
                did_work <- overal_CD2 < overal_CD1
            } else {
                ## Randomised always work
                did_work <- TRUE
            }
        }
        return(did_work)
    }

    while(counter < 15 && !check.work(type, overal_CD1, overal_CD2)) {
        ## Increment the counter to avoid and infinite loop
        counter <- counter + 1

        ## Re-modify the matrix
        replace <- select.characters(char_diff_matrix_CD1, type, threshold, matrix_modified)

        ## Modify the matrix
        matrix_modified[, replace$to] <- matrix_modified[, replace$by]

        ## Calculate the new character differences
        char_diff_matrix_CD2 <- char.diff(matrix_modified)

        ## Calculate the new overall average character difference
        overal_CD2 <- mean(char_diff_matrix_CD2[upper.tri(char_diff_matrix_CD2)])
    }

    ## Return all the elements
    output <- list("matrix" = matrix_modified, "overall" = c(overal_CD1, overal_CD2), "char_replaced" = replace$to, "replaced_by" = replace$by)

    return(output)
}