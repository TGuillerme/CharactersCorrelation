#' @title run a Bhattacharrya Coefficient test on the data
#'
#' @description run a Bhattacharrya Coefficient test on the data
#'
#' @param data the global dataset
#' @param metric which metric to use
#' @param best which best tree (rand or norm)
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export

run.bhatt.coeff <- function(data, metric, best) {

    ## Combined
    combined <- TRUE

    ## Getting the metric
    if(metric == "RF") metric <- 2
    if(metric == "Triples") metric <- 4

    ## Getting all the data for one metric
    NTS_all <- lapply(data, lapply.get.metric, metric)

    ## Extract the right scenarios (i.e. drop rand/norm and true)
    if(best == "norm") {
        ## Extra the right base (norm and rand)
        NTS_base <- lapply(NTS_all, lapply, lapply, `[[`, 1)
        NTS <- lapply(NTS_base, lapply, lapply, `[`, c(2,3,4))
    } else {
        ## Extra the right base (norm and rand)
        NTS_base <- lapply(NTS_all, lapply, lapply, `[[`, 2)
        NTS <- lapply(NTS_base, lapply, lapply, `[`, c(1,2,3))
    }

    ## Getting the NTS values as a list
    NTS_list <- unlist(unlist(unlist(NTS, recursive = FALSE), recursive = FALSE), recursive = FALSE)

    ## Getting the levels of parameters
    list_names <- names(NTS_list)
    parameter_names <- c("t25.", "t75.", "t150.", "c100.", "c350.", "c1000.", "bayesian.", "parsimony.")
    if(best == "norm") {
        parameter_names <- c(parameter_names, c("maxi", "mini", "rand"))
    } else {
        parameter_names <- c(parameter_names, c("norm", "maxi", "mini"))
    }
    parameters <- lapply(as.list(parameter_names), grep, list_names, fixed = TRUE)
    names(parameters) <- parameter_names

    ## Selecting the parameters combinations
    combo_matrix <- matrix(c(rep(1, 3), rep(2, 3), rep(3, 3), rep(c(4,5,6), 3)), nrow = 2, byrow = TRUE)
    combo_matrix <- cbind(combo_matrix, combo_matrix)
    combo_matrix <- rbind(combo_matrix, matrix(c(rep(7, 9), rep(8, 9)), nrow = 1, byrow = TRUE))

    ## Select the NTS lists for each combination (18 in total)
    combo_list <- apply(combo_matrix, 2, function(X) Reduce(intersect, parameters[X]))


    pairwise.bhatt.coeff <- function(list) {
        ## Apply the bhattacharya to all the pairwise elements of the list
        return(apply(combn(1:length(list), 2), 2, function(X) bhatt.coeff(list[[X[[1]]]], list[[X[[2]]]])))
    }

    ## Calculate the pairwise bhattacharrya
    bhatt_coeffs <- apply(combo_list, 2, function(X) pairwise.bhatt.coeff(NTS_list[X]))

    ## Get the column names (scenario)
    
    ## Get the row names (min:max, etc..)

    return(t(bhatt_coeffs))
}