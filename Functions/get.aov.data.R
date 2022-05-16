#' @title Runs an anova on the results of the analysis
#'
#' @description Runs an anova on the results of the analysis
#'
#' @param data the global dataset (as a list)
#' @param metric which metric to use
#' @param best which best tree (rand or norm)
#' @param combined whether to combine all the scenarios together (for posthoc TuckeyHSD)
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export

get.aov.data <- function(data, metric, best, combined = FALSE) {

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

    ## Getting the formula
    # if(combined) {
    #     formula <- NTS ~ taxa + character + method + scenario
    # } else {
    #     if(best == "norm") {
    #         formula <- NTS ~ taxa + character + method + maximised + minimised + randomised
    #     } else {
    #         formula <- NTS ~ taxa + character + method + normal + maximised + minimised
    #     }
    # }

    ## Create the common aov table
    aov_data <- data.frame("taxa" = count.taxa(NTS),
                           "character" = count.character(NTS),
                           "method" = count.method(NTS),
                           "NTS" = as.vector(unlist(NTS)))

    ## Add the scenarios
    if(combined) {
        if(best == "norm") {
            aov_data <- cbind(aov_data, data.frame("scenario" = count.scenario(NTS, 1, combined = TRUE, best = "norm")))
        } else {
            aov_data <- cbind(aov_data, data.frame("scenario" = count.scenario(NTS, 1, combined = TRUE, best = "null")))
        }
    } else {
        if(best == "norm") {
            aov_data <- cbind(aov_data, data.frame("maximised" = count.scenario(NTS, 1, combined = FALSE),
                                                   "minimised" = count.scenario(NTS, 2, combined = FALSE),
                                                   "randomised" = count.scenario(NTS, 3, combined = FALSE)))
        } else {
            aov_data <- cbind(aov_data, data.frame("normal" = count.scenario(NTS, 1, combined = FALSE),
                                                   "maximised" = count.scenario(NTS, 2, combined = FALSE),
                                                   "minimised" = count.scenario(NTS, 3, combined = FALSE)))
        }
    }
    return(aov_data)
}

## Return the right metric from a table
get.metric <- function(list, metric) {
    return(list[,metric])
}

## Lapply get.metric in a recursive way
lapply.get.metric <- function(data, metric) {
    return(lapply(data, lapply, lapply, lapply, get.metric, metric))
}

count.scenario <- function(NTS, which, combined, best) {
    ## Getting the number of counts for each methods
    counts <- lapply(unlist(unlist(unlist(lapply(NTS, lapply, lapply, `[`, c(1,2,3)), recursive = FALSE), recursive = FALSE), recursive = FALSE), length)

    ## Initialise the scenario selector (binary)
    if(combined) {
        if(best == "norm") {
            names <- rep(c("max","min","rand"))
        } else {
            names <- rep(c("norm","max","min"))
        }
    } else {
        names <- rep(0,length(NTS[[1]][[1]][[1]]))
        names[which] <- 1
    }

    ## Replicate the scenario for the number of counts
    return(as.factor(unlist(mapply(rep, as.list(rep(names, 18)), counts))))
}

count.method <- function(NTS) {
    ## Getting the number of counts for each methods
    counts <- lapply(unlist(unlist(lapply(NTS, lapply, lapply, unlist), recursive = FALSE), recursive = FALSE), length)
    ## Replicate the method for the number of counts
    return(as.factor(unlist(mapply(rep, as.list(rep(names(NTS[[1]][[1]]), 18)), counts))))
}

count.character <- function(NTS) {
    ## Getting the number of counts for each character
    counts <- lapply(unlist(lapply(NTS, lapply, unlist), recursive = FALSE), length)
    ## Replicate the character number for the number of counts
    return(as.factor(unlist(mapply(rep, as.list(rep(names(NTS[[1]]), 3)), counts))))
}

count.taxa <- function(NTS) {
    ## Getting the number of counts for each taxa
    counts <- lapply(lapply(NTS, unlist), length)
    ## Replicate the taxa number for the number of counts
    return(as.factor(unlist(mapply(rep, as.list(names(NTS)), counts))))
}