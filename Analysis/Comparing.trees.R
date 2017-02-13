## Analysis for comparing the trees

## Load the functions
source("functions.R") ; load.functions(test = FALSE)
dyn.load("../Functions/char.diff.so")

############
## Load the tree comparisons
###########
current <- getwd()

## ~~~~
## Bayesian
## ~~~~

## Normal trees
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

## True trees
setwd("../Data/Trees_out/True_trees/Bayesian/")
bay_true_25t_100c <- read.TreeCmp("25t_100c", true = TRUE)
bay_true_25t_350c <- read.TreeCmp("25t_350c", true = TRUE)
bay_true_25t_1000c <- read.TreeCmp("25t_1000c", true = TRUE)

# bay_true_75t_100c <- read.TreeCmp("75t_100c", true = TRUE)
# bay_true_75t_350c <- read.TreeCmp("75t_350c", true = TRUE)
# bay_true_75t_1000c <- read.TreeCmp("75t_1000c", true = TRUE)

# bay_true_150t_100c <- read.TreeCmp("150t_100c", true = TRUE)
# bay_true_150t_350c <- read.TreeCmp("150t_350c", true = TRUE)
# bay_true_150t_1000c <- read.TreeCmp("150t_1000c", true = TRUE)
setwd(current)

## ~~~~
## Parsimony
## ~~~~

## Normal trees
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

## True trees
setwd("../Data/Trees_out/True_trees/Parsimony/")
par_true_25t_100c <- read.TreeCmp("25t_100c", true = TRUE)
par_true_25t_350c <- read.TreeCmp("25t_350c", true = TRUE)
par_true_25t_1000c <- read.TreeCmp("25t_1000c", true = TRUE)

# par_true_75t_100c <- read.TreeCmp("75t_100c", true = TRUE)
# par_true_75t_350c <- read.TreeCmp("75t_350c", true = TRUE)
# par_true_75t_1000c <- read.TreeCmp("75t_1000c", true = TRUE)

# par_true_150t_100c <- read.TreeCmp("150t_100c", true = TRUE)
# par_true_150t_350c <- read.TreeCmp("150t_350c", true = TRUE)
# par_true_150t_1000c <- read.TreeCmp("150t_1000c", true = TRUE)
setwd(current)

## ~~~~
## Apply NTS
## ~~~~

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

bay_true_25t_100c <- NTS(bay_true_25t_100c, 25)
bay_true_25t_350c <- NTS(bay_true_25t_350c, 25)
bay_true_25t_1000c <- NTS(bay_true_25t_1000c, 25)
par_true_25t_100c <- NTS(par_true_25t_100c, 25)
par_true_25t_350c <- NTS(par_true_25t_350c, 25)
par_true_25t_1000c <- NTS(par_true_25t_1000c, 25)

# bay_true_75t_100c <- NTS(bay_true_75t_100c, 75)
# bay_true_75t_350c <- NTS(bay_true_75t_350c, 75)
# bay_true_75t_1000c <- NTS(bay_true_75t_1000c, 75)
# par_true_75t_100c <- NTS(par_true_75t_100c, 75)
# par_true_75t_350c <- NTS(par_true_75t_350c, 75)
# par_true_75t_1000c <- NTS(par_true_75t_1000c, 75)

# bay_true_150t_100c <- NTS(bay_true_150t_100c, 150)
# bay_true_150t_350c <- NTS(bay_true_150t_350c, 150)
# bay_true_150t_1000c <- NTS(bay_true_150t_1000c, 150)
# par_true_150t_100c <- NTS(par_true_150t_100c, 150)
# par_true_150t_350c <- NTS(par_true_150t_350c, 150)
# par_true_150t_1000c <- NTS(par_true_150t_1000c, 150)

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

res_bay_true_25t <- list(bay_true_25t_100c, bay_true_25t_350c, bay_true_25t_1000c)
res_par_true_25t <- list(par_true_25t_100c, par_true_25t_350c, par_true_25t_1000c)
res_true_25t <- list(res_bay_true_25t, res_par_true_25t)
# res_bay_true_75t <- list(bay_true_75t_100c, bay_true_75t_350c, bay_true_75t_1000c)
# res_par_true_75t <- list(par_true_75t_100c, par_true_75t_350c, par_true_75t_1000c)
# res_true_75t <- list(res_bay_true_75t, res_par_true_75t)
# res_bay_true_150t <- list(bay_true_150t_100c, bay_true_150t_350c, bay_true_150t_1000c)
# res_par_true_150t <- list(par_true_150t_100c, par_true_150t_350c, par_true_150t_1000c)
# res_true_150t <- list(res_bay_true_150t, res_par_true_150t)

############
## Plot the results
###########

par(mfrow = c(2,1))
plot.results.single(res_25t, 2, main = "25 taxa", legend = TRUE)
plot.results.single(res_25t, 4, main = "25 taxa", legend = TRUE)

par(mfrow = c(2,1))
plot.results.true.tree(res_true_25t, 2, main = "25 taxa", legend = TRUE)
plot.results.true.tree(res_true_25t, 4, main = "25 taxa", legend = TRUE)