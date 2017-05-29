## Analysis for comparing the trees

## Load the functions
source("../functions.R") ; load.functions(test = FALSE)
dyn.load("../../Functions/char.diff.so")

## Loading the tree comparisons
current <- getwd()
setwd("../../Data/NTS/Comparisons/")
nts_25t <- read.table("25t_NTS.Cmp", sep = "\t", header = TRUE)
nts_75t <- read.table("75t_NTS.Cmp", sep = "\t", header = TRUE)
nts_150t <- read.table("150t_NTS.Cmp", sep = "\t", header = TRUE)
setwd(current)

## Calculating the means for each metric and for each taxa
mean_25t <- apply(nts_25t[,4:7], 2, mean)
mean_75t <- apply(nts_75t[,4:7], 2, mean)
mean_150t <- apply(nts_150t[,4:7], 2, mean)

## Saving the NTS data as a table
matrix_nts <- matrix(c(mean_25t, mean_75t, mean_150t), ncol = 4, byrow = TRUE, dimnames = list(c(25, 75, 150), names(mean_25t)))
save(matrix_nts, file = "../../Data/NTS/matrix.nts.Rda")
