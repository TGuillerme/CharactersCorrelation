#' @title Making the xtable for publication
#'
#' @description Making the xtable for publication
#'
#' @param table the table to print
#' @param digit the digit rounding
#' @param caption the caption
#' @param label the label (in LaTeX: \ref{label})
#' @param longtable whether to use longtable
#' @param path optional, a path for saving the table
#' @param include.rownames logical, whether to include the rownames (default = FALSE)
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export

make.xtable <- function(table, digit = 3, caption, label, longtable = FALSE, path, include.rownames = FALSE) {

    ## Rounding
    table[,which(unlist(lapply(table, class)) == "numeric")] <- round(table[,which(unlist(lapply(table, class)) == "numeric")], digits = digit)

    ## Add significance values
    if(all(!is.na(match(colnames(table), c("bhatt.coeff", "statistic", "p.value"))))){
        for(row in 1:nrow(table)) {
            if(as.numeric(table$bhatt.coeff[row]) >= 0.95 || as.numeric(table$bhatt.coeff[row]) <= 0.05) {
                table$bhatt.coeff[row] <- paste0("BOLD",table$bhatt.coeff[row])
            }
            if(as.numeric(table$p.value[row]) <= 0.05) {
                table$p.value[row] <- paste0("BOLD",table$p.value[row])
            }
        }
    }

    ## Bold cells function
    bold.cells <- function(x) gsub('BOLD(.*)', paste0('\\\\textbf{\\1', '}'), x)

    ## convert into xtable format
    textable <- xtable(table, digit = digit, caption = caption, label = label)

    ## Change attributes
    if(all(colnames(table) == c("metric", "test", "bhatt.coeff", "statistic", "p.value"))){
        ## Add a horizontal line
        attr(textable, "align")[4] <- "r|"
    }


    if(!missing(path)) {
        if(longtable == TRUE) {
            cat(print(textable, tabular.environment = 'longtable', floating = FALSE, include.rownames = include.rownames, sanitize.text.function = bold.cells), file = paste0(path, label, ".tex"))
        } else {
            cat(print(textable, include.rownames = include.rownames, sanitize.text.function = bold.cells), file = paste0(path, label, ".tex"))
        }
    }

    if(longtable == TRUE) {
        print(textable, tabular.environment = 'longtable', floating = FALSE, include.rownames = include.rownames, sanitize.text.function = bold.cells)
    } else {
        print(textable, include.rownames = include.rownames, sanitize.text.function = bold.cells)
    }
}