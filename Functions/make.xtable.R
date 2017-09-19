#' @title Making the xtable for publication
#'
#' @description Making the xtable for publication
#'
#' @param table the table to print
#' @param digit the digit rounding
#' @param caption the caption
#' @param label the label (in LaTeX: \ref{label})
#' @param longtable whether to use longtable
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export

make.xtable <- function(table, digit = 3, caption, label, longtable = FALSE) {
  
  table <- xtable(table, digit = digit, caption = caption, label = label)

  if(longtable == TRUE) {
    print(table, tabular.environment = 'longtable', floating = FALSE, include.rownames = FALSE)
  } else {
    print(table, include.rownames = FALSE)
  }
}