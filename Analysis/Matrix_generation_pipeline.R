## Pipeline for generating the matrices.
## Refer to Matrix modification vignette for more details.

## Packages and functions
library(Claddis)
library(dispRity)
source("functions.R") ; load.functions(test = FALSE)
dyn.load("../Functions/char.diff.so")
write.nexus.std <- ape::write.nexus.data
body(write.nexus.std)[[2]] <- substitute(format <- match.arg(toupper(format), c("DNA", "PROTEIN", "STANDARD")))
body(write.nexus.std)[[26]][[3]][[4]] <- substitute(fcat(indent, "FORMAT", " ", DATATYPE, " ", MISSING, " ", GAP, 
    " ", INTERLEAVE, " symbols=\"0123456789\";\n"))
get.digit <- function(column) {
    if(max(nchar(round(column)), na.rm = TRUE) <= 4) {
       return(4-max(nchar(round(column)), na.rm = TRUE))
    } else {
        return(0)
    }
}
sample.birth.death <- function() {
    birth <- runif(min = 0, max = 1, 1)
    death <- runif(min = 0, max = birth, 1)
    return(c(birth, death))
}

## Seed
set.seed(0)

## Variables
path <- "../Data/Simulation/"
ntaxa_list <- c(25, 75, 150)
ncharacters_list <- c(100, 350, 1000)
simulationID <- seq(1:(length(ntaxa)*length(ncharacters)*50))
digits <- apply(matrix(simulationID, nrow = 1), 2, get.digit)
paste.ID <- function(digit, simulation) {
    return(paste(paste(rep(paste("0"), digit), collapse = ""), simulation, sep = ""))
}
simulationID <- unlist(mapply(paste.ID, as.list(digits), as.list(simulationID)))


for(simulation in 1:length(simulationID)) {
    ## Set the variables
    ## Set the variables
    if(ceiling(simulation/150) == 1) {
        ntaxa <- ntaxa_list[1]
    } else {
        if(ceiling(simulation/150) == 2) {
            ntaxa <- ntaxa_list[2]
        } else {
            ntaxa <- ntaxa_list[3]
        }
    }
    if(ceiling(simulation/50) == 1 | ceiling(simulation/50) == 4 | ceiling(simulation/50) == 7) {
        ncharacters <- ncharacters_list[1]
    } else {
        if(ceiling(simulation/50) == 2 | ceiling(simulation/50) == 5 | ceiling(simulation/50) == 8) {
            ncharacters <- ncharacters_list[2]
        } else {
            ncharacters <- ncharacters_list[3]
        }
    }


    ## 1 - Generating the tree:
    tree <- NULL
    birth_death <- sample.birth.death()
    while(is.null(tree)) {
        tree <- tree.bd(birth_death, max.taxa = ntaxa)
    }
    tree$node.label <- NULL
    tree$tip.label[[1]] <- "outgroup"
    tree <- root(tree, "outgroup", resolve.root = TRUE)
    write.nexus(tree, file = paste(paste(path, "Trees/", sep = ""), ntaxa,"t_", ncharacters[@@@], "c_", simulationID[simulation], "_truetree.nex", sep = ""))

    ## 2 - Generating the matrices
    matrix_norm <- sim.morpho(tree, ncharacters, states = c(0.85,0.15), model = "mixed", rates = c(rgamma, rate = 100, shape = 3), invariant = FALSE)
    while(check.morpho(matrix_norm)[2,] < 0.26) {
        matrix_norm <- sim.morpho(tree, ncharacters, states = c(0.85,0.15), model = "mixed", rates = c(rgamma, rate = 100, shape = 3), invariant = FALSE)
    }
    matrix_maxi <- modify.matrix(matrix_norm, type = "maximise", threshold = 0.25)
    matrix_mini <- modify.matrix(matrix_norm, type = "minimise", threshold = 0.75)
    matrix_rand <- modify.matrix(matrix_norm, type = "randomise", threshold = 0.25)
    write.nexus.std(matrix_norm, file = paste(paste(path, "Matrices/", sep = ""), ntaxa,"t_", ncharacters[@@@], "c_", simulationID[simulation], "_norm.nex", sep = ""), format = "standard")
    write.nexus.std(matrix_maxi, file = paste(paste(path, "Matrices/", sep = ""), ntaxa,"t_", ncharacters[@@@], "c_", simulationID[simulation], "_maxi.nex", sep = ""), format = "standard")
    write.nexus.std(matrix_mini, file = paste(paste(path, "Matrices/", sep = ""), ntaxa,"t_", ncharacters[@@@], "c_", simulationID[simulation], "_mini.nex", sep = ""), format = "standard")
    write.nexus.std(matrix_rand, file = paste(paste(path, "Matrices/", sep = ""), ntaxa,"t_", ncharacters[@@@], "c_", simulationID[simulation], "_rand.nex", sep = ""), format = "standard")
}
