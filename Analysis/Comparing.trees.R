## Analysis for comparing the trees

## Load the functions
source("functions.R") ; load.functions(test = FALSE)
dyn.load("../Functions/char.diff.so")

############
## Load the tree comparisons
###########

## Bayesian
current <- getwd()
setwd("../Data/Trees_out/Single_trees/Bayesian/Consensus_trees/")
bay_25t_100c <- read.TreeCmp("25t_100c")
bay_25t_350c <- read.TreeCmp("25t_350c")
bay_25t_1000c <- read.TreeCmp("25t_1000c")

# bay_75t_100c <- read.TreeCmp("75t_100c")
# bay_75t_350c <- read.TreeCmp("75t_350c")
# bay_75t_1000c <- read.TreeCmp("75t_1000c")

# bay_150t_100c <- read.TreeCmp("150t_100c")
# bay_150t_350c <- read.TreeCmp("150t_350c")
# bay_150t_1000c <- read.TreeCmp("150t_1000c")
setwd(current)

## Parsimony
setwd("../Data/Trees_out/Single_trees/Parsimony/Consensus_trees/")
par_25t_100c <- read.TreeCmp("25t_100c")
par_25t_350c <- read.TreeCmp("25t_350c")
par_25t_1000c <- read.TreeCmp("25t_1000c")

# par_75t_100c <- read.TreeCmp("75t_100c")
# par_75t_350c <- read.TreeCmp("75t_350c")
# par_75t_1000c <- read.TreeCmp("75t_1000c")

# par_150t_100c <- read.TreeCmp("150t_100c")
# par_150t_350c <- read.TreeCmp("150t_350c")
# par_150t_1000c <- read.TreeCmp("150t_1000c")
setwd(current)

## Apply NTS
bay_25t_100c <- NTS(bay_25t_100c, 25)
bay_25t_350c <- NTS(bay_25t_350c, 25)
bay_25t_1000c <- NTS(bay_25t_1000c, 25)
par_25t_100c <- NTS(par_25t_100c, 25)
par_25t_350c <- NTS(par_25t_350c, 25)
par_25t_1000c <- NTS(par_25t_1000c, 25)

# bay_75t_100c <- NTS(bay_75t_100c, 75)
# bay_75t_350c <- NTS(bay_75t_350c, 75)
# bay_75t_1000c <- NTS(bay_75t_1000c, 75)
# par_75t_100c <- NTS(par_75t_100c, 75)
# par_75t_350c <- NTS(par_75t_350c, 75)
# par_75t_1000c <- NTS(par_75t_1000c, 75)

# bay_150t_100c <- NTS(bay_150t_100c, 150)
# bay_150t_350c <- NTS(bay_150t_350c, 150)
# bay_150t_1000c <- NTS(bay_150t_1000c, 150)
# par_150t_100c <- NTS(par_150t_100c, 150)
# par_150t_350c <- NTS(par_150t_350c, 150)
# par_150t_1000c <- NTS(par_150t_1000c, 150)

## Setting as a list for plotting
res_bay_25t <- list(bay_25t_100c, bay_25t_350c, bay_25t_1000c)
res_par_25t <- list(par_25t_100c, par_25t_350c, par_25t_1000c)
res_25t <- list(res_bay_25t, res_par_25t)
# res_bay_75t <- list(bay_75t_100c, bay_75t_350c, bay_75t_1000c)
# res_par_75t <- list(par_75t_100c, par_75t_350c, par_75t_1000c)
# res_75t <- list(res_bay_75t, res_par_75t)
# res_bay_150t <- list(bay_150t_100c, bay_150t_350c, bay_150t_1000c)
# res_par_150t <- list(par_150t_100c, par_150t_350c, par_150t_1000c)
# res_150t <- list(res_bay_150t, res_par_150t)

## Plot the results
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

par(mfrow = c(2,2))
plot.results.single(res_25t, 2, main = "25 taxa", legend = TRUE)
plot.results.single(res_25t, 4, main = "25 taxa", legend = TRUE)

