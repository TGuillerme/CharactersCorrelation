#' @title Tree resolution
#'
#' @description Get tree resolution
#'
#' @param 
#' 
#' @examples
#'
#' @seealso
#' 
#' @author Thomas Guillerme
#' @export

# path = "../Data/Trees_out/Consensus_trees/Bayesian/Done/25t_100c/"
# suffix = "con.tre"

tree.resolution <- function(path, suffix) {

    ## Read the tree files
    trees <- list.files(path = path, pattern = suffix)

    ## Get the tree format
    type <- scan(paste0(path,trees[1]), what = "character", quiet = TRUE, n = 1)
    if(type == "#NEXUS") {
        read.tree.fun <- ape::read.nexus
    } else {
        read.tree.fun <- ape::read.tree
    }

    ## Categories
    categories <- unique(unlist(lapply(lapply(strsplit(trees, split = "_"), function(X) return(X[4])), function(X) return(strsplit(X, split = paste0(".", suffix))[[1]]))))

    ## Read the trees per categories
    read.one.category <- function(category, path, suffix, read.tree.fun) {
        return(unlist(lapply(as.list(list.files(path = path, pattern = paste0(category, ".", suffix))), function(X, read.tree.fun, path) return(ape::Nnode(read.tree.fun(paste0(path, X)))), read.tree.fun, path)))
    }

    ## Get the resolution per categories
    resolutions <- lapply(as.list(categories), read.one.category, path, suffix, read.tree.fun)

    ## Reorder the categories (norm, max, min, rand)
    resolutions <- resolutions[c(3, 1, 2, 4)]
    names(resolutions) <- categories[c(3, 1, 2, 4)]

    return(resolutions)
}

# col <- c("darkgrey", "red", "green3", "blue", "grey", "orange", "lightgreen", "lightblue")

# plot.tree.resolution("../Data/Trees_out/Consensus_trees/", ntaxa = 25, col = c("darkgrey", "red", "green3", "blue", "grey", "orange", "lightgreen", "lightblue"))

plot.tree.resolution <- function(path, ntaxa, col, type = "line") {

    ## placeholder lists
    bayesian_path <- parsimon_path <- list()

    ## Get the full path for both methods
    bayesian_path[[1]] <- paste0(path, "Bayesian/Done/", ntaxa, "t_100c/")
    parsimon_path[[1]] <- paste0(path, "Parsimony/Done/", ntaxa, "t_100c/")
    bayesian_path[[2]] <- paste0(path, "Bayesian/Done/", ntaxa, "t_350c/")
    parsimon_path[[2]] <- paste0(path, "Parsimony/Done/", ntaxa, "t_350c/")
    bayesian_path[[3]] <- paste0(path, "Bayesian/Done/", ntaxa, "t_1000c/")
    parsimon_path[[3]] <- paste0(path, "Parsimony/Done/", ntaxa, "t_1000c/")


    ## Get the trees
    suffix = "con.tre"
    bayesian_nodes <- lapply(bayesian_path, tree.resolution, suffix)
    parsimon_nodes <- lapply(parsimon_path, tree.resolution, suffix)

    ## Plot the results
    plot(NULL, xaxt = "n", xlim = c(1, 12), ylim = c(1, ntaxa-1), xlab = "", ylab = "Nodes")
    for(character in 1:length(bayesian_nodes)) {
        plot.CI(bayesian_nodes[[character]], type = type, col = col[1:4], shift = 4*(character-1) + 0, point.col = "black", width = 0.1, cent.tend = median, lwd = 3)
        plot.CI(parsimon_nodes[[character]], type = type, col = col[5:8], shift = 4*(character-1) + 0.3, point.col = "black", width = 0.1, cent.tend = median, lwd = 3)
    }

    ## X axis
    axislab <- c("100c", "350c", "1000c")
    axis(1, 1:12, labels = FALSE, tick = FALSE)
    axis(1, c(2.5, 6.6, 10.5), tick = FALSE, labels = axislab)
    ## Lines
    abline(v = 4.66) ; abline(v = 8.66)

    ## Legend
    y_positions <- seq(from = 1, to = 0.2, length.out = 4)
    legend_lab <- paste(names(bayesian_nodes[[1]]), "(bay/par)")
    for(legend in 1:4) {

        ## Get the y position
        y_pos <- (ntaxa/5) * y_positions[legend]

        ## Plot the legend
        points(y = rep(y_pos, 2), x = c(0.7,0.85), pch = 19, col = col[c(legend,legend+4)])
        text(y = y_pos, x = 0.85, legend_lab[legend], cex = 0.6, pos = 4)
    }
}