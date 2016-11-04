# Header
library(Claddis)
library(dispRity)
source("functions.R") ; load.functions(test = FALSE)

###############
# Parameters for generating the matrix
###############

# Variables that can be changed here are:
# The tree size ?
# The length of the matrix (50, 100, 200, 1000) ?
# The models (Mk or HKYbin)
# The rates (log normal or gamma)

###############
# Looking at distribution of the correlation among empirical matrices
###############

matrix_path = "../Data/100_Matrices"
files <- list.files(path = matrix_path, pattern = ".nex")

## Function for finding non-numeric values
find.non.numerics <- function(x) {
    options(warn = -1)
    if(is.na(as.numeric(x))) {
        return(TRUE)
    } else {
        return(FALSE)
    }
}

## Read the matrices
matrices <- list()
for(matrix in 1:length(files)) {
    cat(files[[matrix]],"\n")
    matrices[[matrix]] <- ReadMorphNexus(paste(matrix_path, files[matrix], sep ="/"))$matrix
    # Change NAs to question marks
    # matrices[[matrix]] <- ifelse(is.na(matrices[[matrix]]), "?", matrices[[matrix]])
    # # Change &s to question marks
    # <- ifelse(find.non.numerics(matrices[[matrix]]), "?", matrices[[matrix]])
    matrices[[matrix]][apply(matrices[[matrix]], c(1,2), find.non.numerics)] <- "?"
}

## Calculate the differences
differences <- lapply(matrices, cor.matrix, char.diff)

## Visualise a single matrix:
# plot.cor.matrix(differences[[1]])

## Estimate the distributions densities
densities <- lapply(differences, density, na.rm = TRUE)

## Plot the the densities distribution
plot(1,1, col = white, xlim = c(0,1), ylim = c(0,1), main = "Observed characters differences in 100 matrices", xlab = "Character differences", ylab = "Density")
lapply(densities, lines, col = "grey")
lines(density(na.omit(unlist(differences))), col = "black")
legend("topleft", legend = c("Cumulative", "Individual"), lty = 1, col = c("black", "grey"))

