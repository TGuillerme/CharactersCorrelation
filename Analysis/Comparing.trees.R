## Analysis for comparing the trees

## Load the functions
source("functions.R") ; load.functions(test = FALSE)
dyn.load("../Functions/char.diff.so")



## Load the tree comparisons
current <- getwd()
setwd("../Data/Trees_out/Single_trees/Consensus_trees/")
res_25t_100c <- read.TreeCmp("25t_100c")
res_25t_350c <- read.TreeCmp("25t_350c")
res_25t_1000c <- read.TreeCmp("25t_1000c")

res_75t_100c <- read.TreeCmp("75t_100c")
res_75t_350c <- read.TreeCmp("75t_350c")
res_75t_1000c <- read.TreeCmp("75t_1000c")

res_150t_100c <- read.TreeCmp("150t_100c")
res_150t_350c <- read.TreeCmp("150t_350c")
res_150t_1000c <- read.TreeCmp("150t_1000c")
setwd(current)


## Apply NTS

## Plot the results
metric <- 4

# get_ylim <- function(X, metric) {
#     return(c(min(unlist(X[,metric])), max(unlist(X[,metric]))))
# }

# ylim_tmp <- lapply(res_25t_100c, get_ylim, metric)
# ylim <-c(min(unlist(lapply(ylim_tmp, `[[`, 1))), max(unlist(lapply(ylim_tmp, `[[`, 2))))

cols <- palette()[2:4]

ylab <- ifelse(metric == 2, "RF", "Triplet")

par(bty = "n")

boxplot(xlab = "Characters", ylab = ylab, xaxt = "n", main = "25 taxa",
    unlist(res_25t_100c$maxi[,metric]), unlist(res_25t_100c$mini[,metric]), unlist(res_25t_100c$rand[,metric]),
    unlist(res_25t_350c$maxi[,metric]), unlist(res_25t_350c$mini[,metric]), unlist(res_25t_350c$rand[,metric]),
    unlist(res_25t_1000c$maxi[,metric]), unlist(res_25t_1000c$mini[,metric]), unlist(res_25t_1000c$rand[,metric]),
    col = rep(cols, 3)
    )
axis(1, 1:9, c("", 100, "", "", 350, "", "", 1000, ""))
legend("topleft", legend = c("Maximised", "Minimised", "Randomised"), col = cols, pch = 19, bty = "n", title = "Character differences:", cex = 0.8)