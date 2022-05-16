#' @title Plots one correlation results
#'
#' @description Plots one correlation results
#'
#' @param matrices_cd the list of matrices with CD values
#' @param whole_data the list of all the data
#' @param chain the chain name (corresponding to the one used to obtain the matrix_cd)
#' @param metric which metric to plot (\code{"RF"} or \code{"Triplets"})
#' @param method which method to plot (\code{"Bayesian"} or \code{"Parsimony"}) 
#' @param model optional, a linear model
#' @param col a list of colours to differentiate the scenarios
#' @param rounding the number of digits for the plotted values
#' @param cent.tend optional, the central tendency to plot for matrix_cd
#' @param legend whether to plot the legend or not
#' @param xlab the x label
#' @param ylab the y label
#' @param main optional, the title
#' @param additional plot arguments
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export

one.correlation.plot <- function(matrices_cd, whole_data, chain, metric, method, model, col = c("blue", "orange", "green"), rounding = 3, cent.tend = NULL, legend = FALSE, xlab = "mean CD", ylab = "Metric", main, ...) {
    ## Get the metric
    if(metric == "RF") {
        metric_value <- 2
        ylim <- c(0,1)
        y_legend <- c(0.2, 0.15, 0.1, 0.05)
    } else {
        if(metric == "Triplets") {
            metric_value <- 4
            ylim <- c(-0.5,1)
            y_legend <- c(-0.3, -0.35, -0.4, -0.45)
        } else {
            stop("metric must be \"RF\" or \"Triplets\".")
        }
    }

    ## Get the method
    if(method == "Bayesian") {
        method_value <- 1
    } else {
        if(method == "Parsimony") {
            method_value <- 2
        } else {
            stop("metric must be \"Bayesian\" or \"Parsimony\".")
        }
    }

    ## Summarise the model
    if(class(model) == "lm") {
        summary_model <- summary(model)
    } else {
        if(class(model) == "summary.lm") {
            summary_model <- model
        } else {
            stop("model must be of class \"lm\" or \"summary.lm\"")
        }
    }

    ## Length of matrices_cd
    length.out <- length(matrices_cd[[1]])

    ## Get the chain values
    if(chain != "pool") {
        chain_values <- strsplit(chain, split = "_")[[1]]
        taxa_number <- as.numeric(strsplit(chain_values[1], split = "t")[[1]])
        if(!taxa_number %in% c(25, 75, 150)) {
            stop(paste0("In ", chain, " taxa number (#t) must be 25, 75 or 150."))
        }
        if(taxa_number == 25) {
            taxa_value <- 1
        } else {
            taxa_value <- ifelse(taxa_number == 75, 2, 3)
        }
        character_number <- as.numeric(strsplit(chain_values[2], split = "c")[[1]])
        if(!character_number %in% c(100, 350, 1000)) {
            stop(paste0("In ", chain, " character number (#c) must be 100, 350 or 1000."))
        }
        if(character_number == 100) {
            character_value <- 1
        } else {
            character_value <- ifelse(taxa_number == 350, 2, 3)
        }

        ## Double check length.out
        length_whole_data <- length(whole_data[[taxa_value]][[character_value]][[method_value]]$norm$mini[, metric_value])
        if(length.out > length_whole_data) {
            length.out <- length_whole_data
        }
    }

    ## Get the default main
    if(missing(main)) {
        main <- paste0("Correlation between character difference and ", metric, " (", method, ")")
    }


    ## Length of matrices_cd
    plot(NULL, xlab = xlab, ylab = ylab, ylim = ylim, xlim = c(0,1), main = main, ...)


    if(!is.null(cent.tend)) {
        x_mini <- unlist(lapply(matrices_cd$mini, cent.tend))[1:length.out]
        x_maxi <- unlist(lapply(matrices_cd$maxi, cent.tend))[1:length.out]
        x_rand <- unlist(lapply(matrices_cd$rand, cent.tend))[1:length.out]
    } else {
        x_mini <- unlist(matrices_cd$mini)[1:length.out]
        x_maxi <- unlist(matrices_cd$maxi)[1:length.out]
        x_rand <- unlist(matrices_cd$rand)[1:length.out]
    }

    if(chain != "pool") {
        y_mini <- whole_data[[taxa_value]][[character_value]][[method_value]]$norm$mini[, metric_value][1:length.out]
        y_maxi <- whole_data[[taxa_value]][[character_value]][[method_value]]$norm$maxi[, metric_value][1:length.out]
        y_rand <- whole_data[[taxa_value]][[character_value]][[method_value]]$norm$rand[, metric_value][1:length.out]
    } else {
        
        ## TODO change
        length.out <- 35

        y_mini <- unlist(lapply(whole_data, lapply, function(X, method_value, metric_value, length.out) return(X[[method_value]]$norm$mini[1:length.out, metric_value]), method_value, metric_value, length.out))
        y_maxi <- unlist(lapply(whole_data, lapply, function(X, method_value, metric_value, length.out) return(X[[method_value]]$norm$maxi[1:length.out, metric_value]), method_value, metric_value, length.out))
        y_rand <- unlist(lapply(whole_data, lapply, function(X, method_value, metric_value, length.out) return(X[[method_value]]$norm$rand[1:length.out, metric_value]), method_value, metric_value, length.out))
    }


    ## Add the data points
    points(x_mini, y_mini, pch = 19, col = col[1], ...)
    points(x_maxi, y_maxi, pch = 19, col = col[2], ...)
    points(x_rand, y_rand, pch = 19, col = col[3], ...)


    ## Adding the legend
    if(legend) {
        legend("bottomright", pch = 19, col = col, legend = c("mini", "maxi", "rand"), ...)
    }

    ## Adding the model
    if(!missing(model)) {
        ## Adding the model line
        abline(model)
        ## Adding the model values
        text(0, y_legend[1], "Metric ~ Character difference", pos = 4, ...)
        text(0, y_legend[2], paste0("Intercept = ",
                             round(summary_model$coefficients[1,1], digit = rounding),
                             " (p = ",
                             round(summary_model$coefficients[1,4], digit = rounding),
                             ")"), pos = 4, ...)
        text(0, y_legend[3], paste0("Slope = ",
                             round(summary_model$coefficients[2,1], digit = rounding),
                             " (p = ",
                             round(summary_model$coefficients[2,4], digit = rounding),
                             ")"), pos = 4, ...)
        text(0, y_legend[4], paste0("R^2 (adj) = ",
                             round(summary_model$adj.r.squared, digit = rounding)
                             ), pos = 4, ...)
    }
}

#' @title Plots all correlation results
#'
#' @description Plots all correlation results
#'
#' @param all_matrices_cd the list of matrices with CD values
#' @param whole_data the list of all the data
#' @param metric which metric to plot (\code{"RF"} or \code{"Triplets"})
#' @param method which method to plot (\code{"Bayesian"} or \code{"Parsimony"}) 
#' @param models optional, a linear model
#' @param col a list of colours to differentiate the scenarios
#' @param rounding the number of digits for the plotted values
#' @param cent.tend the central tendency to plot for matrix_cd
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export
#' 

all.correlation.plot <- function(all_matrices_cd, whole_data, metric, method, models, col = c("blue", "orange", "green"), rounding = 3, cent.tend = NULL, ...) {
    
    ## Chain names
    taxa <- paste0(c(25, 75, 150), "t")
    characters <- paste0(c(100, 350, 1000), "c")
    all_chains <- lapply(as.list(taxa), function(taxa, characters) return(as.list(paste(taxa, characters, sep = "_"))), characters)


    par(bty = "n", mfrow = c(3, 3))
    ## First row
    one.correlation.plot(all_matrices_cd[[1]][[1]], whole_data, chain = all_chains[[1]][[1]], metric = metric, method = method, model = models[[1]][[1]], col = col, rounding = rounding, cent.tend = cent.tend, legend = TRUE, xlab = "", ylab = paste0("25t - ", metric), main = "", ...)
    one.correlation.plot(all_matrices_cd[[1]][[2]], whole_data, chain = all_chains[[1]][[2]], metric = metric, method = method, model = models[[1]][[2]], col = col, rounding = rounding, cent.tend = cent.tend, legend = FALSE, xlab = "", ylab = "", main = "Bayesian", ...)
    one.correlation.plot(all_matrices_cd[[1]][[3]], whole_data, chain = all_chains[[1]][[3]], metric = metric, method = method, model = models[[1]][[3]], col = col, rounding = rounding, cent.tend = cent.tend, legend = FALSE, xlab = "", ylab = "", main = "", ...)

    ## Second row
    one.correlation.plot(all_matrices_cd[[2]][[1]], whole_data, chain = all_chains[[2]][[1]], metric = metric, method = method, model = models[[2]][[1]], col = col, rounding = rounding, cent.tend = cent.tend, legend = FALSE, xlab = "", ylab = paste0("75t - ", metric), main = "", ...)
    one.correlation.plot(all_matrices_cd[[2]][[2]], whole_data, chain = all_chains[[2]][[2]], metric = metric, method = method, model = models[[2]][[2]], col = col, rounding = rounding, cent.tend = cent.tend, legend = FALSE, xlab = "", ylab = "", main = "", ...)
    one.correlation.plot(all_matrices_cd[[2]][[3]], whole_data, chain = all_chains[[2]][[3]], metric = metric, method = method, model = models[[2]][[3]], col = col, rounding = rounding, cent.tend = cent.tend, legend = FALSE, xlab = "", ylab = "", main = "", ...)

    ## Third row
    one.correlation.plot(all_matrices_cd[[3]][[1]], whole_data, chain = all_chains[[3]][[1]], metric = metric, method = method, model = models[[3]][[1]], col = col, rounding = rounding, cent.tend = cent.tend, legend = FALSE, xlab = "100c - CD", ylab = paste0("150t - ", metric), main = "", ...)
    one.correlation.plot(all_matrices_cd[[3]][[2]], whole_data, chain = all_chains[[3]][[2]], metric = metric, method = method, model = models[[3]][[2]], col = col, rounding = rounding, cent.tend = cent.tend, legend = FALSE, xlab = "350c - CD", ylab = "", main = "", ...)
    one.correlation.plot(all_matrices_cd[[3]][[3]], whole_data, chain = all_chains[[3]][[3]], metric = metric, method = method, model = models[[3]][[3]], col = col, rounding = rounding, cent.tend = cent.tend, legend = FALSE, xlab = "1000c - CD", ylab = "", main = "", ...)

}

#' @title Correlation tables
#'
#' @description Correlation tables
#'
#' @param models optional, a linear model
#' @param metric which metric to plot (\code{"RF"} or \code{"Triplets"})
#' @param method which method to plot (\code{"Bayesian"} or \code{"Parsimony"}) 
#' @param rounding the number of digits for the plotted values
#'
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export

correlation.table <- function(models) {

    ## Summarising all models
    summary_models <- lapply(models, lapply, summary)

    ## Organise as a table
    intercepts <- unlist(lapply(summary_models, lapply, function(X) return(X$coefficients[1,1])))
    p_intercepts <- unlist(lapply(summary_models, lapply, function(X) return(X$coefficients[1,4])))
    slopes <- unlist(lapply(summary_models, lapply, function(X) return(X$coefficients[2,1])))
    p_slopes <- unlist(lapply(summary_models, lapply, function(X) return(X$coefficients[2,4])))
    r_squares <- unlist(lapply(summary_models, lapply, function(X) return(X$adj.r.squared)))

    ## Get the significance tokens
    get.token <- function(p) {
        if(p > 0.05) {
            return("")
        }
        if(p < 0.05 && p > 0.01) {
            return(".")
        }
        if(p < 0.01 && p > 0.001) {
            return("*")
        }
        if(p < 0.001) {
            return("**")
        }
    }

    ## Summarise the results
    results_out <- data.frame("Intercepts" = intercepts, "Int(p)" = p_intercepts, "Int(sig)" = sapply(p_intercepts, get.token),
                              "Slope" = slopes, "Slo(p)" = p_slopes, "Slo(sig)" = sapply(p_slopes, get.token),
                              "R^2 (adj)" = r_squares)


    return(results_out)
}