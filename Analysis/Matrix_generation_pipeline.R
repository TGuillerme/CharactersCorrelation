## Pipeline for generating the matrices.
## Refer to Matrix modification vignette for more details.

## Packages
library(Claddis)
library(dispRity)
library(diversitree)

## Load the functions
source("functions.R") ; load.functions(test = FALSE)

## Counting digits in a column
get.digit <- function(column) {
    if(max(nchar(round(column)), na.rm = TRUE) <= 4) {
       return(4-max(nchar(round(column)), na.rm = TRUE))
    } else {
        return(0)
    }
}

## Birth death sampler with birth > death
sample.birth.death <- function() {
    birth <- runif(min = 0, max = 1, 1)
    death <- runif(min = 0, max = birth, 1)
    return(c(birth, death))
}

## Simulation variables
path <- "../Data/Simulations/"
ntaxa_list <- c(25, 75, 150)
ncharacters_list <- c(100, 350, 1000)
n_replicates <- 20

## Seed
set.seed(0)
system(paste0("echo \"\" > ",path, "Parameters/Matrix_generation.log"))

## Making the simulation IDs
simulationID <- seq(1:(length(ntaxa_list)*length(ncharacters_list)*n_replicates))
digits <- apply(matrix(simulationID, nrow = 1), 2, get.digit)
paste.ID <- function(digit, simulation) {
    return(paste(paste(rep(paste("0"), digit), collapse = ""), simulation, sep = ""))
}
simulationID <- unlist(mapply(paste.ID, as.list(digits), as.list(simulationID)))


## Initiating the birth death-table
system(paste0("echo \"ID,birth,death\" > ", path, "Parameters/birth_death_param.csv"))

## Loop through the simulations
for(simulation in 1:length(simulationID)) {
    ## Set the variables
    if(ceiling(simulation/(3*n_replicates)) == 1) {
        ntaxa <- ntaxa_list[1]
    } else {
        if(ceiling(simulation/(3*n_replicates)) == 2) {
            ntaxa <- ntaxa_list[2]
        } else {
            ntaxa <- ntaxa_list[3]
        }
    }
    if(ceiling(simulation/n_replicates) == 1 | ceiling(simulation/n_replicates) == 4 | ceiling(simulation/n_replicates) == 7) {
        ncharacters <- ncharacters_list[1]
    } else {
        if(ceiling(simulation/n_replicates) == 2 | ceiling(simulation/n_replicates) == 5 | ceiling(simulation/n_replicates) == 8) {
            ncharacters <- ncharacters_list[2]
        } else {
            ncharacters <- ncharacters_list[3]
        }
    }

    ## Verbose
    cat(paste("RUN: ", ntaxa,"t_", ncharacters, "c_", simulationID[simulation], " - ", sep = ""))
    system(paste0("printf \"RUN: ", ntaxa,"t_", ncharacters, "c_", simulationID[simulation], " - \" >> ", path, "Parameters/Matrix_generation.log"))

    ## Start the run
    do_RUN <- TRUE

    while(do_RUN) {
        ## 1 - Generating the tree:
        tree <- NULL
        birth_death <- sample.birth.death()
        cat("Tree:")
        system(paste0("printf \"Tree:\" >> ", path, "Parameters/Matrix_generation.log"))
        while(is.null(tree)) {
            ## Resample the birth death parameters
            birth_death <- sample.birth.death()
            tree <- tree.bd(birth_death, max.taxa = ntaxa)
            cat(".")
            system(paste0("printf \".\" >> ", path, "Parameters/Matrix_generation.log"))
        }
        cat("Done - ")
        system(paste0("printf \"Done - \" >> ", path, "Parameters/Matrix_generation.log"))

        ## Save the tree
        tree$node.label <- NULL
        tree$tip.label[[1]] <- "outgroup"
        tree <- root(tree, "outgroup", resolve.root = TRUE)
        write.nexus(tree, file = paste(paste(path, "Trees/", sep = ""), ntaxa,"t_", ncharacters, "c_", simulationID[simulation], "_truetree.nex", sep = ""))

        ## 2 - Generating the matrices
        cat("Matrix:")
        system(paste0("printf \"Matrix:\" >> ", path, "Parameters/Matrix_generation.log"))
        matrix_norm <- NULL
        counter <- 0 
        matrix_norm <- sim.morpho(tree, ncharacters, states = c(0.85,0.15), model = "mixed", rates = c(rgamma, rate = 100, shape = 5), invariant = FALSE)        
        cat(".")
        system(paste0("printf \".\" >> ", path, "Parameters/Matrix_generation.log"))
        
        ## Save the best matrix (to limit to 15 trials anyways)
        best_matrix <- matrix_norm

        while(counter < 15 & check.morpho(matrix_norm)[2,] < 0.26) {
            matrix_norm <- sim.morpho(tree, ncharacters, states = c(0.85,0.15), model = "mixed", rates = c(rgamma, rate = 100, shape = 5), invariant = FALSE)
            counter <- counter + 1

            ## Replace the best matrix (if the consistency index is bigger in the new matrix)
            if(check.morpho(matrix_norm)[2,] > check.morpho(best_matrix)[2,]) {
                best_matrix <- matrix_norm
            }

            cat(".")
            system(paste0("printf \".\" >> ", path, "Parameters/Matrix_generation.log"))
        }

        ## Select only the best matrix from the 15 trials
        matrix_norm <- best_matrix

        cat("Done - ")
        system(paste0("printf \"Done - \" >> ", path, "Parameters/Matrix_generation.log"))

        ## Modifying the matrix
        transform_maxi <- modify.matrix(matrix_norm, type = "maximise", threshold = 0.25)
        transform_mini <- modify.matrix(matrix_norm, type = "minimise", threshold = 0.75)
        transform_rand <- modify.matrix(matrix_norm, type = "randomise", threshold = 0.25)

        ## Check if the transformation worked (no FALSE returned)
        if(all(c(class(transform_maxi), class(transform_mini), class(transform_rand)) != "logical")) {

            ## Save the matrices
            write.nexus.data(matrix_norm, file = paste(paste(path, "Matrices/", sep = ""), ntaxa,"t_", ncharacters, "c_", simulationID[simulation], "_norm.nex", sep = ""), format = "standard")
            write.nexus.data(transform_maxi$matrix, file = paste(paste(path, "Matrices/", sep = ""), ntaxa,"t_", ncharacters, "c_", simulationID[simulation], "_maxi.nex", sep = ""), format = "standard")
            write.nexus.data(transform_mini$matrix, file = paste(paste(path, "Matrices/", sep = ""), ntaxa,"t_", ncharacters, "c_", simulationID[simulation], "_mini.nex", sep = ""), format = "standard")
            write.nexus.data(transform_rand$matrix, file = paste(paste(path, "Matrices/", sep = ""), ntaxa,"t_", ncharacters, "c_", simulationID[simulation], "_rand.nex", sep = ""), format = "standard")

            ## Save the parameters
            table.changes <- function(transform_list) {
                table_out <- rbind(transform_list$overall, cbind(transform_list$char_replaced, transform_list$replaced_by))
                rownames(table_out) <- NULL
                return(table_out)
            }
            write.csv(table.changes(transform_maxi), file = paste0(path, "Parameters/", ntaxa, "t_", ncharacters, "c_", simulationID[simulation], "_changes_maxi.csv"))
            write.csv(table.changes(transform_mini), file = paste0(path, "Parameters/", ntaxa, "t_", ncharacters, "c_", simulationID[simulation], "_changes_mini.csv"))
            write.csv(table.changes(transform_rand), file = paste0(path, "Parameters/", ntaxa, "t_", ncharacters, "c_", simulationID[simulation], "_changes_rand.csv"))

            cat("All save... OK.\n")
            system(paste0("printf \"All save... OK.\n\" >> ", path, "Parameters/Matrix_generation.log"))
    
            ## Save the birth death parameters
            system(paste0("echo \"", simulationID[simulation], ",", birth_death[1], ",", birth_death[2], "\" >> ", path, "Parameters/birth_death_param.csv"))

            ## Run finished
            do_RUN <- FALSE
        }
    }
}