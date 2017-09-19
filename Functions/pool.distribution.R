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

#' @title Pool multiple distributions for multiple parameters
#'
#' @description Pool multiple distributions for multiple parameters
#'
#' @param data the whole data
#' @param param which parameters
#' @param metric which metrics
#' @param best which comparison
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export
#' 
multi.pool <- function(data, param, metric, best) {
    ## Get the distributions for multiple parameters
    distributions <- list()
    for(one_param in 1:length(param)) {
        distributions[[one_param]] <- pool.distribution(data, param = param[[one_param]], metric = metric, best = best)
    }
    ## Transform it into a dataframe
    return(matrix(data = unlist(distributions), ncol = length(param), dimnames = list(c(), param)))
}

#' @title Pooled distribution summary table
#'
#' @description Pooled distribution summary table
#'
#' @param distributions a list of distribution tables
#' @param digit how many digits to display
#' @param metric.label the metrics labels (can be missing)
#' @param comp.label the comparisons labels (can be missing)
#' @param label.param the label of the parameter pooled
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export
#' 
pool.table <- function(distributions, digit = 3, metric.label, comp.label, label.param) {

    ## Summarising the data for each distribution
    scenarios <- do.call(rbind, lapply(distributions, function(x) t(apply(x, 2, summary))))
    ## Rounding
    scenarios <- round(scenarios, digit = digit)

    ## Adding the metrics and comp (if not missing)
    if(!missing(metric.label) && !missing(comp.label)) {
        labels <- data.frame("comp" = comp.label, "metric" = metric.label, unlist(lapply(distributions, colnames)))
        colnames(labels)[length(labels)] <- label.param
        scenarios_table <- cbind(labels, as.data.frame(scenarios))
    }

    ## Adding the metrics (if not missing)
    if(!missing(metric.label) && missing(comp.label)) {
        labels <- data.frame("metric" = metric.label, unlist(lapply(distributions, colnames)))
        colnames(labels)[length(labels)] <- label.param
        scenarios_table <- cbind(labels, as.data.frame(scenarios))
    }

    ## Adding the comp (if not missing)
    if(missing(metric.label) && !missing(comp.label)) {
        labels <- data.frame("comp" = comp.label, unlist(lapply(distributions, colnames)))
        colnames(labels)[length(labels)] <- label.param
        scenarios_table <- cbind(labels, as.data.frame(scenarios))
    }

    if(missing(metric.label) && missing(comp.label)) {
        scenarios_table <- scenarios
    }

    return(scenarios_table)
}