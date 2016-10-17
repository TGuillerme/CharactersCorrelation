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