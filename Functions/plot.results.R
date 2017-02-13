plot.results.single <- function(data_list, metric, main, legend = FALSE) {
    
    ## Graphic parameters
    cols <- c("red", "orange", "green3", "lightgreen", "blue", "lightblue")
    ylab <- ifelse(metric == 2, "Similarity (Robinson-Foulds)", "Similarity (Triplets)")
    ylim <- c(0,1)
    ylim[1] <- ifelse(metric == 2, 0, -0.5)
    line <- ifelse(metric == 2, -1, 0)
    par(bty = "n")

    ## Boxplots
    boxplot(xlab = "Characters", ylab = ylab, xaxt = "n", main = main, ylim = ylim,
        ## 100c
        unlist(data_list[[1]][[1]]$maxi[,metric]), unlist(data_list[[2]][[1]]$maxi[,metric]),
        unlist(data_list[[1]][[1]]$mini[,metric]), unlist(data_list[[2]][[1]]$mini[,metric]),
        unlist(data_list[[1]][[1]]$rand[,metric]), unlist(data_list[[2]][[1]]$rand[,metric]),
        ## 350c
        unlist(data_list[[1]][[2]]$maxi[,metric]), unlist(data_list[[2]][[2]]$maxi[,metric]),
        unlist(data_list[[1]][[2]]$mini[,metric]), unlist(data_list[[2]][[2]]$mini[,metric]),
        unlist(data_list[[1]][[2]]$rand[,metric]), unlist(data_list[[2]][[2]]$rand[,metric]),
        ## 1000c
        unlist(data_list[[1]][[3]]$maxi[,metric]), unlist(data_list[[2]][[3]]$maxi[,metric]),
        unlist(data_list[[1]][[3]]$mini[,metric]), unlist(data_list[[2]][[3]]$mini[,metric]),
        unlist(data_list[[1]][[3]]$rand[,metric]), unlist(data_list[[2]][[3]]$rand[,metric]),
        col = rep(cols, 3)
        )

    ## X axis
    axis(1, 1:18, labels = FALSE, tick = FALSE) # ticks = FALSE?
    axis(1, c(3.5, 9.5, 15.5), tick = FALSE, labels = c("100", "350", "1000"))

    ## Lines
    abline(v = 6.5) ; abline(v = 12.5)
    abline(h = line, col = "grey", lty = 2)
    if(legend) {
        legend("bottomleft", legend = c("Maximised (Bayesian)", "Maximised (Parsimony)", "Minimised (Bayesian)", "Minimised (Parsimony)", "Randomised (Bayesian)", "Randomised (Parsimony)"), col = cols, pch = 19, bty = "n", title = "Character differences:", cex = 0.8)
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