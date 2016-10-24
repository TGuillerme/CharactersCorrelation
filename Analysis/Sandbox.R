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