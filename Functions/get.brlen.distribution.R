#' @title 
#'
#' @description 
#'
#' @param path the path where to find the true trees
#' @param ntaxa the number of taxa per trees (25, 75 or 150)
#' @param internals logical, whether to get all the branches distributions (including internal branches, TRUE) or just the total branch length to the tips (FALSE, default)
#' @param zeros a list of values under which branch lengths are considered as 0.
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export

get.brlen.distribution <- function(path, ntaxa, internals = FALSE, zeros = c(0)) {

    ## Get the tree paths
    trees_in <- list.files(path)
    trees_in <- trees_in[grep(paste0(ntaxa, "t_"), trees_in)]
    trees_in <- paste0(path, trees_in)

    ## Read all the trees
    tree_list <- lapply(as.list(trees_in), function(x) read.nexus(x))

    ## Get the branch lengths
    if(internals == TRUE) {
        ## Get all the branch lengths
        brlengths_list <- lapply(tree_list, function(x) return(x$edge.length[-1]))
    } else {
        ## Get the total branch lengths for each tip
        brlengths_list <- lapply(tree_list, function(x, ntaxa) node.depth.edgelength(x)[1:ntaxa], ntaxa = ntaxa)
    }

    ## Get the density lines
    brlengths_densities <- lapply(brlengths_list, function(x) density(x))
    ## Get the proportion of 0 branch lengths
    zero_list <- list()
    for(zero in 1:length(zeros)) {
        zero_list[[zero]] <- lapply(brlengths_list, function(x) ifelse(any(x < zeros[zero]), which(x < zeros[zero]), 0))
    }
    names(zero_list) <- as.character(zeros)

    return(list(densities = brlengths_densities, zeros = zero_list))
}

plot.brlen.distribution <- function(path, ntaxa, zeros = zeros, cols, ...) {
    ## Get the distributions
    brlengths_int <- get.brlen.distribution(path, ntaxa, internals = TRUE, zeros = zeros)

    ## Get the xlimits
    xlim <- c(0, max(unlist(lapply(brlengths_int$densities, function(x) max(x$x)))))
    ylim <- c(0, max(unlist(lapply(brlengths_int$densities, function(x) max(x$y)))))

    ## Empty plot
    plot(NULL, xlab = "Branch lengths", ylab = "Density", xlim = xlim, ylim = ylim, ...)

    ## Add each density lines
    silent <- lapply(brlengths_int$densities, function(x, cols) lines(x, col = cols[1]), cols = cols)

    ## Add the number of zeros
    n_zeros <- numeric()
    for(zero in 1:length(zeros)) {
        n_zeros[zero] <- sum(unlist(brlengths_int$zeros[[zero]])/brlengths_int$densities[[1]]$n)/length(unlist(brlengths_int$zeros[[zero]]))
    }

    ## Add proportion texts
    text(xlim[2] * 0.7, ylim[2] * 0.9, paste(paste0("Mean proportion of branches < ", as.character(zeros), " : ", round(n_zeros, 2)), collapse = "\n"))
}