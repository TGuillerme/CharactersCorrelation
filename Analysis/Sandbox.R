library(dispRity)

#Creating the matrix
###############
set.seed(123)
# Random tree (coalescent) # Use proper birth-death trees!
tree <- rcoal(15)
# Matrix (Mk model)
matrix <- sim.morpho(tree, 50, states = c(0.85, 0.15), rates = c(rgamma, rate = 10, shape = 5), invariant = FALSE)
# Checking matrix
check.morpho(matrix, tree) # This produces a fairly good matrix

# Variables that can be changed here are:
# The tree size ?
# The length of the matrix (50, 100, 200, 1000) ?
# The models (Mk or HKYbin)
# The rates (log normal or gamma)

#Creating the correlation
###############
# Should correlation be measured as statistical correlation (e.g pearson, kendall, spearman, ...) or as scaled euclidean distance (i.e. the proportion of differences).
# Maybe correlation should be calculated by just duplicating some number of characters (up to 100%) rather than recreating characters?

#Or just use classic cor (pearson)

cor(as.numeric(matrix[,1]), as.numeric(matrix[,2])) #Is whatever value
cor(as.numeric(matrix[,1]), as.numeric(matrix[,1])) #Is 1

mat <- apply(matrix, 2, as.numeric)
cor(mat)

#' @title Generate correlated characters
#'
#' @description Generates correlated characters in a morphological matrix
#'
#' @param matrix A discrete morphological data matrix.
#' @param nchar The number of characters to correlate.
#' @param cor.dis The distribution to be sampled from that is the strength of the correlation.
#' 
#' @author Thomas Guillerme

set.correlation <- function(matrix, nchar, cor.dis) {
    #sampling from a distribution
    ## n is the number of samples
    ## distribution is the distribution as in c(fun, arg1, arg...)
    sample.distribution <- function(n, distribution) {
        fun <- distribution[[1]]
        distribution[[1]] <- n
        return(do.call(fun, distribution))
    }

    #Get the number of states per characters
    get.states <- function(character) {
        return(length(levels(as.factor(character))))
    }

    #Randomly changes a character state
    change.state <- function(character, distance) {
    }


    return(NULL)
}

char.diff <- function(X,Y, type = "Fitch") {

    differences <- X-Y

    if(type == "Fitch") {
        #Making the differences binary
        differences <- ifelse(differences == 0, 0, 1) 

    #    return(1 - ( (sum((X-Y)/(X-Y)) / length(X) - 0.5) / 0.5 ))
    }

    return(1 - ( abs(sum(abs(differences))/length(X)-0.5)/0.5 ))

    # if(type == "Wagner") {
    #     return(1 - ( abs(sum(abs(X-Y))/length(X)-0.5)/0.5 ))
    # }
}

# Testing characters correlation
library(testthat)
context("Measuring characters difference")

A <- c(1,0,0,0,0)
B <- c(0,1,1,1,1)

#Correlation is 1
expect_equal(abs(cor(A,B)), 1)
#Correlation is triangular
expect_equal(abs(cor(A,B)), abs(cor(B,A)))
#Difference is 0
expect_equal(char.diff(A,B), 0)
#Difference is triangular
expect_equal(char.diff(A,B), char.diff(B,A))

C <- c(1,1,0,0,0)

#Correlation is 0.6
expect_equal(round(abs(cor(A,C)), digit = 5), 0.61237)
#Correlation is triangular
expect_equal(abs(cor(A,C)), abs(cor(C,A)))
#Difference is 0.4
expect_equal(char.diff(A,C), 0.4)
#Difference is triangular
expect_equal(char.diff(A,C), char.diff(C,A))

D <- c(0,1,1,0,0)

#Correlation is 0.6
expect_equal(round(abs(cor(A,D)), digit = 5), 0.40825)
#Correlation is triangular
expect_equal(abs(cor(A,D)), abs(cor(D,A)))
#Difference is 0.4
expect_equal(char.diff(A,D), 0.8)
#Difference is triangular
expect_equal(char.diff(A,D), char.diff(D,A))

E <- c(1,0,0,1,1)

#Correlation is equal to D
expect_equal(abs(cor(D,E)), 1)
#Correlation is triangular (with D)
expect_equal(abs(cor(A,E)), abs(cor(A,D)))
#Difference is equal to D
expect_equal(char.diff(D,E), 0)
#Difference is triangular (with D)
expect_equal(char.diff(A,E), char.diff(A,D))

# Plotting the characters differences (depending on the metric)
## Graphical parameters 
op <- par(mfrow = c(2,2), bty = "n")

character_differences <- unlist(lapply(list(B,C,D,E), char.diff, A))
character_correlations <- abs(unlist(lapply(list(B,C,D,E), cor, A)))
plot(character_differences, type = "l", col = "blue", ylim = c(0,1), xaxt = "n", xlab = "", ylab = "", main = "characters comparison (5x5)")
axis(1, at = 1:4, labels = c("A:B", "A:C", "A:D", "A:E"))
lines(1-character_correlations, col = "orange")
legend("topleft", legend = c("Difference", "1-Correlation"), lty = 1, xjust = 1, yjust = 1, col = c("blue", "orange"))

plot(density(character_differences - (1-character_correlations)), main = "residuals")

# Plotting the characters differences for 50 "random" characters
library(dispRity) ; #set.seed(0)
# Creating the characters
tree <- rcoal(100)
matrix <- sim.morpho(tree, 500, rates = c(rgamma, rate = 10, shape = 5), invariant = FALSE)
matrix <- apply(matrix, 2, as.numeric)

character_differences <- apply(matrix[,-1], 2, char.diff, matrix[,1])
character_correlations <- abs(apply(matrix[,-1], 2, cor, matrix[,1]))

#Sort the values
sorting <- sort(character_differences, index.return = TRUE)[[2]]

plot(character_differences[sorting], type = "l", col = "blue", ylim = c(0,1), xlab = "", ylab = "", main = "characters comparison (100x500)")
lines(1-character_correlations[sorting], col = "orange")
legend("topleft", legend = c("Difference", "1-Correlation"), lty = 1, xjust = 1, yjust = 1, col = c("blue", "orange"))

plot(density(character_differences[sorting] - (1-character_correlations[sorting])), main = "residuals")

par(op)


# Correlation profiles
correlation.matrix <- function(matrix, diff.fun, verbose = TRUE) {

    apply.diff.fun <- function(x, verbose, diff.fun) {
        diff.fun(matrix[,x[1]], matrix[,x[2]])
        if(verbose != FALSE) {
            cat(".")
        }
    }

    if(verbose) {
        cat("Calculating the pairwise characters differences: ")
    }
    #Get the combination matrix
    comb_matrix <- combn(1:ncol(matrix), 2)

    #calculating the pairwise differences
    differences <- apply(comb_matrix, 2, apply.diff.fun, verbose = verbose, diff.fun = diff.fun)

    if(verbose) {
        cat("Done.")
    }

    # Create the empty matrix
    differences_matrix <- matrix(data = NA, ncol = ncol(matrix), nrow = ncol(matrix))
    # Set up the diagonal (no difference)
    diag(differences_matrix) <- diff.fun(matrix[,1], matrix[,1])
    # Fill up the lower triangle
    differences_matrix[lower.tri(differences_matrix, diag = FALSE)] <- differences

    return(differences_matrix)
}

pairwise_matrix <- correlation.matrix(matrix, char.diff, verbose = TRUE)

plot.pairwise.matrix <- function(matrix, col = c("blue", "orange"), legend = TRUE, legend.title = "Difference", axis = TRUE, ...) {

    #Setting the colours
    colfunc<-colorRampPalette(col)
    colheat<-colfunc(10)

    #Plotting the heat map
    image(pairwise_matrix, col = colheat, axes = FALSE, ...)
    if(axis) {
        axis(1, at = seq(from = 0, to = 1, length.out = ncol(matrix)), labels = FALSE, tick = TRUE)
        axis(2, at = seq(from = 0, to = 1, length.out = ncol(matrix)), labels = FALSE, tick = TRUE)
    }

    #Adding the legend
    if(legend) {
    legend("topleft", legend = c(as.character(round(max(pairwise_matrix, na.rm = TRUE), 2)), as.character(round(min(pairwise_matrix, na.rm = TRUE), 2))), title = legend.title, col = col, pch = 19)
    }
}

plot.pairwise.matrix(pairwise_matrix)


# Loop that!
library(dispRity) ; #set.seed(0)

matrix_details <- list()
characters_differences <- list()
characters_correlations <- list()
replicates <- 500
for(replicate in 1:replicates) {
    tree <- rcoal(100)
    try(matrix <- sim.morpho(tree, 500, rates = c(rgamma, rate = 10, shape = 5), invariant = FALSE, verbose = TRUE), silent = TRUE)
    matrix_details[[replicate]] <- c(check.morpho(matrix, tree))

    matrix <- apply(matrix, 2, as.numeric)
    character_differences <- apply(matrix[,-1], 2, char.diff, matrix[,1])
    character_correlations <- abs(apply(matrix[,-1], 2, cor, matrix[,1]))

    sorting <- sort(character_differences, index.return = TRUE)[[2]]
    characters_differences[[replicate]] <- character_differences[sorting]
    characters_correlations[[replicate]] <- 1-character_correlations[sorting]
}

#Store the results
results_differences <- matrix(ncol = replicates, nrow = 499)
results_correlations <- matrix(ncol = replicates, nrow = 499)
for (replicate in 1:replicates) {
    results_differences[,replicate] <- characters_differences[[replicate]]
    results_correlations[,replicate] <- characters_correlations[[replicate]]
}

median_differences <- apply(results_differences, 1, median)
median_correlations <- apply(results_correlations, 1, median)

plot(characters_differences[[1]], type = "l", col = "lightblue", ylim = c(0,1), xlab = "", ylab = "", main = "characters comparison (100x500)")
lines(characters_correlations[[1]], col = "yellow")
for(replicate in 2:replicates) {
    lines(characters_differences[[replicate]], col = "lightblue")
    lines(characters_correlations[[replicate]], col = "yellow")
}

lines(median_differences, col = "blue")
lines(median_correlations, col = "orange")
legend("topleft", legend = c("Difference", "1-Correlation"), lty = 1, xjust = 1, yjust = 1, col = c("blue", "orange"))


# Testing characters correlation (multistate)
A <- c(1,2,0,0,0)
B <- c(2,3,4,4,4)
C <- c(0,1,2,0,0)
D <- c(0,2,1,0,0)
E <- c(1,2,1,0,0)
F <- c(2,0,2,1,1)
G <- c(1,2,2,0,0)

#AB are the same
expect_equal(char.diff(A,B), 0)
#EF are the same
expect_equal(char.diff(E,F), 0)
#So AE must be equal to AF
expect_equal(char.diff(A,E), char.diff(A,F))


char.diff <- function(X,Y, type = "Fitch") {

    #Needs to reorder the character to have the first token being 1, second being 2, etc...

    #Transform states into similar values
    normalise.character <- function(X) {
        #Get the states of X
        states <- as.numeric(levels(as.factor(X)))
        #Modify the original states 
        for(state in 1:length(states)) {
            X <- as.numeric(gsub(states[state], state-1, X))
        }
        return(X)
    }

    X <- normalise.character(X)
    Y <- normalise.character(Y)

    #Calculate the differences
    differences <- X-Y

    if(type == "Fitch") {
        #Make the differences binary (i.e. if the difference is != 0, set to 1)
        differences <- ifelse(differences != 0, 1, 0)
    }

    #Calculate the difference
    return(1 - ( abs(sum(abs(differences))/length(X)-0.5)/0.5 ))
}