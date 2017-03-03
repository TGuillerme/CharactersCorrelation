#' @title Export a matrix as a network
#'
#' @description Transforms a nexus matrix into an exportable character difference network
#'
#' @param matrix_path The path to a nexus matrix.
#' @param file The name of the output file (if missing, uses <matrix_name>.ntw)
#'
#' @return
#' Generates a .ntw file
#' 
#' @examples
#' ##
#' 
#' @author Thomas Guillerme
#' @export
#' 

export.ntw <- function(matrix_path, file) {
    
    ## Sanitizing
    if(missing(file)) {
        ## split the path
        file <- strsplit(matrix_path, "/")[[1]]
        ## select the last element
        file <- file[length(file)]
        ## at the suffix
        file <- strsplit(file, ".nex")[[1]][1]
        file <- paste(file, ".ntw", sep = "")
    }

    ## Read the matrix
    matrix <- Claddis::ReadMorphNexus(matrix_path)$matrix

    ## Calculate the differences
    diff_matrix <- char.diff(matrix)

    ## Transform the table
    diff_table <- reshape2::melt(diff_matrix)[,c(2,1,3)]
    diff_table[,3] <- diff_table[,3]

    ## Export as csv
    utils::write.csv(diff_table, file = file, row.names = FALSE)

    return(invisible())
}