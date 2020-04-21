#' @title Character compatibility functions
#'
#' @description 
#'
#' @param 
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export

# This code is modified from https://datadryad.org/stash/dataset/doi:10.5061/dryad.sh8b4 (functions pairCompat and compCount)




set.seed(4)
## A random tree with 15 tips
tree <- rcoal(15)
## Setting up the parameters
my_rates = c(rgamma, rate = 10, shape = 5)
## Mk matrix (15*50) (for Mkv models)
matrix <- sim.morpho(tree, characters = 50, model = "ER", rates = my_rates,invariant = FALSE) 


pair.compat <- function(i, j)    {

    ## Get the tokens
    tokens <- unique(c(i, j))

    ## The number of possible pairwise combinations
    n_tokens <- length(tokens)
    expect_combn <- ncol(combn(1:n_tokens, 2))*2 + n_tokens

    ## Intersection for any token
    get.tokens <- function(token, character) return(which(character == token))
    tokens_i <- unlist(sapply(tokens, get.tokens, character = i, simplify = FALSE))
    tokens_j <- unlist(sapply(tokens, get.tokens, character = j, simplify = FALSE))
    keeps <- intersect(tokens_i, tokens_j)

    ## Get the observed combinations:
    obs_combn <- unique(paste0(i[keeps], j[keeps]))

    ## Measure compatibility
    ## If the number of observed combinations is lower than the expected combinations, the characters are compatible
    return(ifelse(length(obs_combn) < expect_combn, 0, 1))
}
comp.count <- function(matrix, pairwise)   {
    compatibilities <- apply(pairwise, 2, function(x) pair.compat(matrix[,x[1]], matrix[,x[2]]))
    return(sum(compatibilities))
}
pair.comp <- function(matrix, type = "compatible") {
    pairwise_comparisons <- combn(1:ncol(matrix), 2)
    incompatibilities <- comp.count(matrix, pairwise_comparisons)

    if(type == "incompatible"){
        return(incompatibilities)
    } else {
        return(ncol(pairwise_comparisons - incompatibilities))
    }
}


pair.comp(matrix, "incompatible")


### Workhorse function. This function takes two main arguments: a data matrix, and a matrix of character pairs. It then compares each set of character pairs and determines if they are compatible or not. It then returns the *total number of incompatibilities*. 
# compCount.orig <- function(Matrix, pairwiseComp, Count=4, Type="conflict")   {
#     calcComp <- apply(pairwiseComp, 2, function(x) pairCompat.orig(Matrix[,x[1]], Matrix[,x[2]], count=Count, type=Type))
#     nIncomps <- sum(calcComp)
#     return(nIncomps)
# }


intersect(c(which(i == "0"), which(i=="1")), c(which(j == "0"), which(j=="1")))
paste(i)

pairCompat <- function(i, j, maximum.pairs = 2) {
    Keeps <- intersect(c(which(i == "0"), which(i=="1")), c(which(j == "0"), which(j=="1"))) #TG: This line basically removes NAs (making sure not comparing NAs, won't intersect)
    Combns <- paste(i[Keeps], j[Keeps]) #TG: This line combines both characters
    Pairs <- unique(Combns) #TG: This line counts the unique number of comparison pairs
    Incompatibility <- ifelse(length(Pairs) < maximum.pairs, 0, 1) #TG: If there are less pairs than the maximum (count), character is compatible
    return(Incompatibility)
}