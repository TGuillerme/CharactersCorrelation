#' @title Plotting TreeCmp results
#'
#' @description Simple wrapper for plotting the results from TreeCmp
#'
#' @param taxa_list a list of tree metrics from \code{read.TreeCmp} for all the scenario for a number of taxa
#' @param metric a numeric of which metric to use (\code{1} = \code{MatchingCluster}, \code{2} = \code{R.F_Cluster}, \code{3} = \code{NodalSplitted}, \code{4} = \code{Triples})
#' @param what which type of plot? Can be \code{"null"}, \code{"real"}, \code{"true"}, \code{"check"}. See details.
#' @param ylim \code{ylim} parameter from \code{plot} (if missing is automatic)
#' @param legend \code{logical}, whether to display the legend
#' @param NTS \code{logical}, whether NTS was used
#' @param ylab a \code{character} string to be passed to \code{boxplot(..., ylab)}
#' @param xlab a \code{character} string to be passed to \code{boxplot(..., xlab)}
#' @param axislab a \code{character} string to be passed to \code{axis(..., labels)}
#' @param ... any additional argument to be passed to \code{boxplot}
#'
#' @details
#' \code{"null"} = "maxi", "mini", "norm" tree vs. "rand"
#' \code{"best"} = "maxi", "mini", "rand" tree vs. "norm"
#' \code{"true"} = "norm", "rand" tree vs. "true"
#' \code{"check"} = "norm", vs "rand"
#' 
#' @return
#' A list of metrics for the comparisons.
#' 
#' @examples
#' ##
#' 
#' @author Thomas Guillerme
#' @export
#' 


plot.results.single <- function(taxa_list, metric, what, ylim, legend = FALSE, NTS = TRUE, ylab, xlab, axislab, ...) {
    
    ## Graphic parameters
    ## Colours
    cols <- c("red", "orange", "green3", "lightgreen", "blue", "lightblue")
    
    ## Y lab
    if(missing(ylab)) {
        if(metric == 1) ylab <- "Similarity (Matching Cluster)"
        if(metric == 2) ylab <- "Similarity (Robinson-Foulds)"
        if(metric == 3) ylab <- "Similarity (Nodal Split)"
        if(metric == 4) ylab <- "Similarity (Triplets)"
    }

    ## Y lim
    get.min.list <- function(X, metric) {
        return(min(unlist(X[,metric])))
    }

    min <- min(unlist(lapply(unlist(unlist(unlist(taxa_list, recursive = FALSE), recursive = FALSE), recursive = FALSE), get.min.list, metric)))
    if(min < 0) {
        ylim <- c(min,1)
    } else {
        ylim <- c(0,1)
    }

    ## X lab
    if(missing(xlab)) {
        xlab <- "Characters"
    }

    ## axis lab
    if(missing(axislab)) {
        axislab <- c("100", "350", "1000")
    }

    ## Horizontal line
    line <- 0
    

    if(what == "null") {
        boxplot(xlab = xlab, ylab = ylab, xaxt = "n", ylim = ylim, col = rep(cols, 3), ...,
            ## c100
            unlist(taxa_list$c100$bayesian$rand$maxi[,metric]), unlist(taxa_list$c100$parsimony$rand$maxi[,metric]),
            unlist(taxa_list$c100$bayesian$rand$mini[,metric]), unlist(taxa_list$c100$parsimony$rand$mini[,metric]),
            unlist(taxa_list$c100$bayesian$rand$norm[,metric]), unlist(taxa_list$c100$parsimony$rand$norm[,metric]),
            ## c350
            unlist(taxa_list$c350$bayesian$rand$maxi[,metric]), unlist(taxa_list$c350$parsimony$rand$maxi[,metric]),
            unlist(taxa_list$c350$bayesian$rand$mini[,metric]), unlist(taxa_list$c350$parsimony$rand$mini[,metric]),
            unlist(taxa_list$c350$bayesian$rand$norm[,metric]), unlist(taxa_list$c350$parsimony$rand$norm[,metric]),
            ## c1000
            unlist(taxa_list$c1000$bayesian$rand$maxi[,metric]), unlist(taxa_list$c1000$parsimony$rand$maxi[,metric]),
            unlist(taxa_list$c1000$bayesian$rand$mini[,metric]), unlist(taxa_list$c1000$parsimony$rand$mini[,metric]),
            unlist(taxa_list$c1000$bayesian$rand$norm[,metric]), unlist(taxa_list$c1000$parsimony$rand$norm[,metric])
            )

        ## X axis
        axis(1, 1:18, labels = FALSE, tick = FALSE)
        axis(1, c(3.5, 9.5, 15.5), tick = FALSE, labels = axislab)
        ## Lines
        abline(v = 6.5) ; abline(v = 12.5)
        abline(h = line, col = "grey", lty = 2)
        ## Legend
        if(legend) {
            legend("bottomleft", col = cols, pch = 19, bty = "n", title = "Character differences:", cex = 0.8,
                legend = c("Maximised (Bayesian)", "Maximised (Parsimony)",
                           "Minimised (Bayesian)", "Minimised (Parsimony)",
                           "Normal (Bayesian)", "Normal (Parsimony)")
                )
        }
    }

    if(what == "best") {
        boxplot(xlab = xlab, ylab = ylab, xaxt = "n", ylim = ylim, col = rep(cols, 3), ...,
            ## c100
            unlist(taxa_list$c100$bayesian$norm$maxi[,metric]), unlist(taxa_list$c100$parsimony$norm$maxi[,metric]),
            unlist(taxa_list$c100$bayesian$norm$mini[,metric]), unlist(taxa_list$c100$parsimony$norm$mini[,metric]),
            unlist(taxa_list$c100$bayesian$norm$rand[,metric]), unlist(taxa_list$c100$parsimony$norm$rand[,metric]),
            ## c350
            unlist(taxa_list$c350$bayesian$norm$maxi[,metric]), unlist(taxa_list$c350$parsimony$norm$maxi[,metric]),
            unlist(taxa_list$c350$bayesian$norm$mini[,metric]), unlist(taxa_list$c350$parsimony$norm$mini[,metric]),
            unlist(taxa_list$c350$bayesian$norm$rand[,metric]), unlist(taxa_list$c350$parsimony$norm$rand[,metric]),
            ## c1000
            unlist(taxa_list$c1000$bayesian$norm$maxi[,metric]), unlist(taxa_list$c1000$parsimony$norm$maxi[,metric]),
            unlist(taxa_list$c1000$bayesian$norm$mini[,metric]), unlist(taxa_list$c1000$parsimony$norm$mini[,metric]),
            unlist(taxa_list$c1000$bayesian$norm$rand[,metric]), unlist(taxa_list$c1000$parsimony$norm$rand[,metric])
            )

        ## X axis
        axis(1, 1:18, labels = FALSE, tick = FALSE)
        axis(1, c(3.5, 9.5, 15.5), tick = FALSE, labels = axislab)
        ## Lines
        abline(v = 6.5) ; abline(v = 12.5)
        abline(h = line, col = "grey", lty = 2)
        ## Legend
        if(legend) {
            legend("bottomleft", col = cols, pch = 19, bty = "n", title = "Character differences:", cex = 0.8,
                legend = c("Maximised (Bayesian)", "Maximised (Parsimony)",
                           "Minimised (Bayesian)", "Minimised (Parsimony)",
                           "Randomised (Bayesian)", "Randomised (Parsimony)")
                )
        }
    }

    if(what == "true") {
        boxplot(xlab = xlab, ylab = ylab, xaxt = "n", ylim = ylim, col = rep(cols[1:4], 3), ...,
            ## c100
            unlist(taxa_list$c100$bayesian$norm$true[,metric]), unlist(taxa_list$c100$parsimony$norm$true[,metric]),
            unlist(taxa_list$c100$bayesian$rand$true[,metric]), unlist(taxa_list$c100$parsimony$rand$true[,metric]),
            ## c350
            unlist(taxa_list$c350$bayesian$norm$true[,metric]), unlist(taxa_list$c350$parsimony$norm$true[,metric]),
            unlist(taxa_list$c350$bayesian$rand$true[,metric]), unlist(taxa_list$c350$parsimony$rand$true[,metric]),
            ## c1000
            unlist(taxa_list$c1000$bayesian$norm$true[,metric]), unlist(taxa_list$c1000$parsimony$norm$true[,metric]),
            unlist(taxa_list$c1000$bayesian$rand$true[,metric]), unlist(taxa_list$c1000$parsimony$rand$true[,metric])
            )

        ## X axis
        axis(1, 1:12, labels = FALSE, tick = FALSE)
        axis(1, c(2.5, 6.5, 10.5), tick = FALSE, labels = axislab)
        ## Lines
        abline(v = 4.5) ; abline(v = 8.5)
        abline(h = line, col = "grey", lty = 2)
        ## Legend
        if(legend) {
            legend("bottomleft", col = cols[1:4], pch = 19, bty = "n", title = "Character differences:", cex = 0.8,
                legend = c("Normal (Bayesian)", "Normal (Parsimony)",
                           "Randomised (Bayesian)", "Randomised (Parsimony)")
                )
        }
    }

    if(what == "check") {
        boxplot(xlab = xlab, ylab = ylab, xaxt = "n", ylim = ylim, col = rep(cols[1:4], 3), ...,
            ## c100
            unlist(taxa_list$c100$bayesian$norm$rand[,metric]), unlist(taxa_list$c100$parsimony$norm$rand[,metric]),
            unlist(taxa_list$c100$bayesian$rand$norm[,metric]), unlist(taxa_list$c100$parsimony$rand$norm[,metric]),
            ## c350
            unlist(taxa_list$c350$bayesian$norm$rand[,metric]), unlist(taxa_list$c350$parsimony$norm$rand[,metric]),
            unlist(taxa_list$c350$bayesian$rand$norm[,metric]), unlist(taxa_list$c350$parsimony$rand$norm[,metric]),
            ## c1000
            unlist(taxa_list$c1000$bayesian$norm$rand[,metric]), unlist(taxa_list$c1000$parsimony$norm$rand[,metric]),
            unlist(taxa_list$c1000$bayesian$rand$norm[,metric]), unlist(taxa_list$c1000$parsimony$rand$norm[,metric])
            )

        ## X axis
        axis(1, 1:12, labels = FALSE, tick = FALSE)
        axis(1, c(2.5, 6.5, 10.5), tick = FALSE, labels = axislab)
        ## Lines
        abline(v = 4.5) ; abline(v = 8.5)
        abline(h = line, col = "grey", lty = 2)
        ## Legend
        if(legend) {
            legend("bottomleft", col = cols[1:4], pch = 19, bty = "n", title = "Character differences:", cex = 0.8,
                legend = c("Normal (Bayesian)", "Normal (Parsimony)",
                           "Randomised (Bayesian)", "Randomised (Parsimony)")
                )
        }
    }
}


plot.results.true.tree <- function(data_list, metric, main, legend = FALSE) {
    
    ## Graphic parameters
    cols <- c("darkgrey", "lightgrey")
    ylab <- ifelse(metric == 2, "Similarity (Robinson-Foulds)", "Similarity (Triplets)")
    ylim <- c(0,1)
    ylim[1] <- ifelse(metric == 2, 0, -0.5)
    line <- ifelse(metric == 2, -1, 0)
    par(bty = "n")

    ## Boxplots
    boxplot(xlab = "Characters", ylab = ylab, xaxt = "n", main = main, ylim = ylim,
        ## 100c
        unlist(data_list[[1]][[1]]$norm[,metric]), unlist(data_list[[2]][[1]]$norm[,metric]),
        ## 350c
        unlist(data_list[[1]][[2]]$norm[,metric]), unlist(data_list[[2]][[2]]$norm[,metric]),
        ## 1000c
        unlist(data_list[[1]][[3]]$norm[,metric]), unlist(data_list[[2]][[3]]$norm[,metric]),
        col = rep(cols, 3)
        )

    ## X axis
    axis(1, 1:6, labels = FALSE, tick = FALSE) # ticks = FALSE?
    axis(1, c(1.5, 3.5, 5.5), tick = FALSE, labels = c("100", "350", "1000"))

    ## Lines
    abline(v = 2.5) ; abline(v = 4.5)
    abline(h = line, col = "grey", lty = 2)
    if(legend) {
        legend("bottomleft", legend = c("Normal (Bayesian)", "Normal (Parsimony)"), col = cols, pch = 19, bty = "n", title = "Character differences:", cex = 0.8)
    }
}