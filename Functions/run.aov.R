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

    ## Return the right metric from a table
    get.metric <- function(list, metric) {
        return(list[,metric])
    }

    ## Lapply get.metric in a recursive way
    lapply.get.metric <- function(data, metric) {
        return(lapply(data, lapply, lapply, lapply, get.metric, metric))
    }

    count.scenario <- function(NTS, which) {
        ## Getting the number of counts for each methods
        counts <- lapply(unlist(unlist(unlist(lapply(NTS, lapply, lapply, `[`, c(1,2,3)), recursive = FALSE), recursive = FALSE), recursive = FALSE), length)

        ## Initialise the scenario selector (binary)
        names <- rep(0,length(NTS[[1]][[1]][[1]]))
        names[which] <- 1

        ## Replicate the scenario for the number of counts
        return(unlist(mapply(rep, as.list(rep(names, 18)), counts)))
    }

    count.method <- function(NTS) {
        ## Getting the number of counts for each methods
        counts <- lapply(unlist(unlist(lapply(NTS, lapply, lapply, unlist), recursive = FALSE), recursive = FALSE), length)
        ## Replicate the method for the number of counts
        return(unlist(mapply(rep, as.list(rep(names(NTS[[1]][[1]]), 18)), counts)))
    }

    count.character <- function(NTS) {
        ## Getting the number of counts for each character
        counts <- lapply(unlist(lapply(NTS, lapply, unlist), recursive = FALSE), length)
        ## Replicate the character number for the number of counts
        return(unlist(mapply(rep, as.list(rep(names(NTS[[1]]), 3)), counts)))
    }

    count.taxa <- function(NTS) {
        ## Getting the number of counts for each taxa
        counts <- lapply(lapply(NTS, unlist), length)
        ## Replicate the taxa number for the number of counts
        return(unlist(mapply(rep, as.list(names(NTS)), counts)))
    }

    ## Getting the metric
    if(metric == "RF") metric <- 2
    if(metric == "Triples") metric <- 4

    ## Getting all the data for one metric
    NTS_all <- lapply(data, lapply.get.metric, metric)

    ## Extra the right base (norm and rand)
    NTS_base <- lapply(NTS_all, lapply, lapply, `[[`, best)

    ## Create the aov data.frame
    if(best == "norm") {
        ## Extra the right scenarios (i.e. drop rand/norm and true)
        NTS <- lapply(NTS_base, lapply, lapply, `[`, c(2,3,4))
        ## Make the aov data.frame
        aov_data <- data.frame("taxa" = count.taxa(NTS),
                               "character" = count.character(NTS),
                               "method" = count.method(NTS),
                               "maximised" = count.scenario(NTS, 1),
                               "minimised" = count.scenario(NTS, 2),
                               "randomised" = count.scenario(NTS, 3),
                               "NTS" = as.vector(unlist(NTS)))

        ## Running the anova
        anova <- lm(NTS ~ taxa + character + method + maximised + minimised + randomised, data = aov_data)

    } else {
        ## Extra the right scenarios (i.e. drop rand/norm and true)
        NTS <- lapply(NTS_base, lapply, lapply, `[`, c(1,2,3))
        ## Make the aov data.frame
        aov_data <- data.frame("taxa" = count.taxa(NTS),
                               "character" = count.character(NTS),
                               "method" = count.method(NTS),
                               "normal" = count.scenario(NTS, 1),
                               "maximised" = count.scenario(NTS, 2),
                               "minimised" = count.scenario(NTS, 3),
                               "NTS" = as.vector(unlist(NTS)))

        ## Running the anova
        anova <- aov(NTS ~ taxa * character + method + normal + maximised + minimised + minimised, data = aov_data)

    }

    return(anova)
}