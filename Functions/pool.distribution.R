#' @title Pool a distribution for one parameter
#'
#' @description Pool a distribution for one parameter
#'
#' @param data the whole data
#' @param param which parameter
#' @param metric which metric
#' @param best which comparison
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export

pool.distribution <- function(data, param, metric, best) {

    ## Get the data for the right metric and best

    ## Getting the metric
    if(metric == "RF") metric <- 2
    if(metric == "Tr") metric <- 4

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

    ## Extracting the right distribution

    ## Checking if the parameter is at the first level (number of taxa)
    param_level1 <- match(param, names(NTS))
    if(!is.na(param_level1)) {
        ## Extracting the distribution
        return(as.vector(unlist(NTS[[param_level1]])))
    } else {
        ## Checking if the parameter is at the second level (number of characters)
        param_level2 <- match(param, names(NTS[[1]]))
        if(!is.na(param_level2)) {
            ## Extracting the distribution
            distribution <- sapply(NTS, function(x, param_level2) x[[param_level2]], param_level2, simplify = FALSE)
            return(as.vector(unlist(distribution)))
        } else {
            ## Checking if the parameter is at the third level (method)
            param_level3 <- match(param, names(NTS[[1]][[1]]))
            if(!is.na(param_level3)) {
                ## Extracting the distribution
                distribution <- lapply(NTS, lapply, `[[`, param_level3)
                return(as.vector(unlist(distribution)))
            } else {
                ## Checking if the parameter is at the fourth level (scenario)
                param_level4 <- match(param, names(NTS[[1]][[1]][[1]]))
                if(!is.na(param_level4)) {
                    ## Extracting the distribution
                    distribution <- lapply(NTS, lapply, lapply, `[[`, param_level4)
                    return(as.vector(unlist(distribution)))
                } else {
                    stop("Parameter not found.")
                }
            }
        }
    }
}