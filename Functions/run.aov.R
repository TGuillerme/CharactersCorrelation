#' @title Runs an anova on the results of the analysis
#'
#' @description Runs an anova on the results of the analysis
#'
#' @param data the global dataset (as a list)
#' @param metric which metric to use
#' @param best which best tree (rand or norm)
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export

run.aov <- function(data, metric, best) {

    get.metric <- function(list, metric) {
        return(list[,metric])
    }

    lapply.recursive <- function(data, metric) {
        return(lapply(data, lapply, lapply, lapply, get.metric, metric))
    }

    ## Set up which scenario to use
    best <- ifelse(best == "norm", 1, 2)
    if(best == 1) {
        scenarios <- c(2,3,4)
    } else {
        scenarios <- c(1,2,3)
    }

    ## Getting the metric
    if(metric == "RF") metric <- 2
    if(metric == "Triples") metric <- 4

    ## Getting all the data for one metric
    NTS_all <- lapply(data, lapply.recursive, metric)

    ## Extra the right base (norm and rand)
    NTS_base <- lapply(NTS_all, lapply, lapply, `[[`, best)

    ## Extra the right scenarios (i.e. drop rand/norm and true)
    NTS <- lapply(NTS_base, lapply, lapply, `[`, scenarios)

    return(NTS)
}