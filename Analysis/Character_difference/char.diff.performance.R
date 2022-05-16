library(Claddis) ; library(dispRity)
source("functions.R") ; load.functions(test = FALSE)

## Load the C libraries
dyn.load("../Functions/char.diff.so")


## Some performance testing for char.diff function
                                #A,B,C,D,E
matrix_binary <- matrix(data = c(1,0,1,0,1,
                                 0,1,1,1,0,
                                 0,1,0,1,0,
                                 0,1,0,0,1,
                                 0,1,0,0,1), ncol = 5, byrow = TRUE)
colnames(matrix_binary) <- LETTERS[1:5]
                               #A,B,C,D,E,F,G
matrix_multi <- matrix(data = c(1,2,0,0,1,2,1,
                                2,3,1,2,2,0,2,
                                0,4,2,1,1,2,2,
                                0,4,0,0,0,1,0,
                                0,4,0,0,0,1,0), ncol = 7, byrow = TRUE)
colnames(matrix_multi) <- LETTERS[1:7]



matrix_simple <- matrix(data = c(1,NA,3,NA,
                                 7,7,2,2,
                                 1,1,1,0), ncol = 3, byrow = FALSE)
colnames(matrix_simple) <- LETTERS[1:3]

bin_R <- cor.matrix(matrix_simple, char.diff)
bin_C <- as.matrix(char.diff.C(matrix_simple))

bin_R == bin_C


bin_R <- cor.matrix(matrix_binary, char.diff)
bin_C <- as.matrix(char.diff.C(matrix_binary))

bin_R == bin_C

mul_R <- cor.matrix(matrix_multi, char.diff)
mul_C <- as.matrix(char.diff.C(matrix_multi))

mul_C == mul_R

matrix <- sim.morpho(rtree(200), 800, states = c(0.85, 0.15), rates = c(rgamma, 10, 5), invariant = FALSE)

time_R <- system.time(results_R <- cor.matrix(matrix, char.diff))
time_C <- system.time(results_C <- as.matrix(char.diff.C(matrix)))

all(na.omit(results_C == results_R))
time_R / time_C


#### Missing data
matrix_simple_missing <- matrix_simple
matrix_simple_missing[c(3,4),1] <- NA
matrix_simple_missing[c(4),2] <- NA
matrix_simple_missing[c(1),3] <- NA

matrix_binary_missing <- matrix_binary
matrix_binary_missing[c(4,5),2] <- NA
matrix_binary_missing[c(1,3),3] <- NA
matrix_binary_missing[c(1,3),4] <- NA
matrix_binary_missing[c(4,5),5] <- NA

matrix_multi_missing <- matrix_multi
matrix_multi_missing[c(2,3), 2] <- NA
matrix_multi_missing[c(1), 5] <- NA
matrix_multi_missing[c(1,2), 6] <- NA
matrix_multi_missing[c(1,2), 7] <- NA



bin_R <- cor.matrix(matrix_simple_missing, char.diff)
bin_C <- as.matrix(char.diff.C(matrix_simple_missing))

bin_R == bin_C

bin_R <- cor.matrix(matrix_binary_missing, char.diff)
bin_C <- as.matrix(char.diff.C(matrix_binary_missing))

bin_R == bin_C

mul_R <- cor.matrix(matrix_multi_missing, char.diff)
mul_C <- as.matrix(char.diff.C(matrix_multi_missing))

mul_C == mul_R