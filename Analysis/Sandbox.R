# Header
library(Claddis)
library(dispRity)
source("functions.R") ; load.functions(test = FALSE)
dyn.load("../Functions/char.diff.so")

## Modify the write.nexus.data function
write.nexus.std <- ape::write.nexus.data
body(write.nexus.std)[[2]] <- substitute(format <- match.arg(toupper(format), c("DNA", "PROTEIN", "STANDARD")))
body(write.nexus.std)[[26]][[3]][[4]] <- substitute(fcat(indent, "FORMAT", " ", DATATYPE, " ", MISSING, " ", GAP, 
    " ", INTERLEAVE, " symbols=\"0123456789\";\n"))


###############
# Parameters for generating the matrix
###############

# Variables that can be changed here are:
# The tree size ?
# The length of the matrix (50, 100, 200, 1000) ?
# The models (Mk or HKYbin)
# The rates (log normal or gamma)

###############
# Loading the matrices
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
# matrices <- list()
# for(matrix in 1:length(files)) {
#     cat(files[[matrix]],"\n")
#     matrices[[matrix]] <- ReadMorphNexus(paste(matrix_path, files[matrix], sep ="/"))$matrix
#     matrices[[matrix]][apply(matrices[[matrix]], c(1,2), find.non.numerics)] <- "?"
# }


###############
# Modifying the matrices
###############


matrices <- list()
for(matrix in 1:10) {
    cat(files[[matrix]],"\n")
    matrices[[matrix]] <- ReadMorphNexus(paste(matrix_path, files[matrix], sep ="/"))$matrix
    matrices[[matrix]][apply(matrices[[matrix]], c(1,2), find.non.numerics)] <- "?"
}


path <- "../Data/Test/"

system(paste("cp ../Functions/set.runs.sh ", path))
system(paste("cp ../Functions/con.tree.sh ", path))


for(run in 1:10) {

    matrices_modified <- list()
    character_differences <- char.diff(matrices[[run]])
    matrices_modified$norm <- matrices[[run]]
    matrices_modified$maxi <- modify.matrix(matrices[[run]], type = "maximise", threshold = 0.25, character_differences)
    matrices_modified$mini <- modify.matrix(matrices[[run]], type = "minimise", threshold = 0.75, character_differences)
    matrices_modified$rand <- modify.matrix(matrices[[run]], type = "randomise", character_differences)

    ###############
    # Modifying the matrices
    ###############
    chain_name <- strsplit(files[[run]], ".nex")[[1]]

    write.nexus.std(matrices_modified$norm, file = paste(path, chain_name, "_norm.nex", sep = ""), format = "standard")
    write.nexus.std(matrices_modified$maxi, file = paste(path, chain_name, "_maxi.nex", sep = ""), format = "standard")
    write.nexus.std(matrices_modified$mini, file = paste(path, chain_name, "_mini.nex", sep = ""), format = "standard")
    write.nexus.std(matrices_modified$rand, file = paste(path, chain_name, "_rand.nex", sep = ""), format = "standard")

    ## Generate the commands
    current_dir <- getwd()
    setwd(path)
    system(paste("sh set.runs.sh ", chain_name, " MrBayes 8", sep = ""))
    ## Run MrBayes
    system(paste("mb ", chain_name, "_norm.cmd", sep = ""))
    system(paste("mb ", chain_name, "_maxi.cmd", sep = ""))
    system(paste("mb ", chain_name, "_mini.cmd", sep = ""))
    system(paste("mb ", chain_name, "_rand.cmd", sep = ""))

    ## Compile the consensus trees
    system(paste("sh con.tree.sh ", chain_name, sep = ""))

    setwd(current_dir)

    trees <- list()
    trees$norm <- read.nexus(paste(path, chain_name, "_norm.con.tre", sep = ""))
    trees$maxi <- read.nexus(paste(path, chain_name, "_maxi.con.tre", sep = ""))
    trees$mini <- read.nexus(paste(path, chain_name, "_mini.con.tre", sep = ""))
    trees$rand <- read.nexus(paste(path, chain_name, "_rand.con.tre", sep = ""))

    ## Plotting the pdf results
    # pdf(paste(chain_name, "pdf", sep = "."), 15.22222, 8.11811)
    # nf<-layout(matrix(c(1,2,3,4,5,6),2,3,byrow = TRUE), c(2,2,2), c(3,2), FALSE)
    # #layout.show(nf)
    # plot(trees$norm, main = paste(chain_name, "-norm", sep = ""), cex = 0.6)
    # plot(trees$maxi, main = paste(chain_name, "-maxi", sep = ""), cex = 0.6)
    # plot(trees$mini, main = paste(chain_name, "-mini", sep = ""), cex = 0.6)
    # plot.char.diff.density(matrices_modified$norm, main = "")
    # plot.char.diff.density(matrices_modified$maxi, main = "")
    # plot.char.diff.density(matrices_modified$mini, main = "")
    # dev.off()
}

for(run in 1:10) {
    matrices_modified <- list()
    character_differences <- char.diff(matrices[[run]])
    matrices_modified$norm <- matrices[[run]]
    matrices_modified$maxi <- modify.matrix(matrices[[run]], type = "maximise", threshold = 0.25, character_differences)
    matrices_modified$mini <- modify.matrix(matrices[[run]], type = "minimise", threshold = 0.75, character_differences)
    matrices_modified$rand <- modify.matrix(matrices[[run]], type = "randomise", character_differences)

    par(mfrow = c(2,2), bty = "n")
    plot.char.diff.density(matrices_modified$norm, main = paste("Normal", run))
    plot.char.diff.density(matrices_modified$maxi, main = paste("Maximise", run))
    plot.char.diff.density(matrices_modified$mini, main = paste("Minimise", run))
    plot.char.diff.density(matrices_modified$rand, main = paste("Randomise", run))
    Sys.sleep(1)
}





## Pipeline for generating and modifying simulated matrices
library(diversitree)
## 0 - Parameters
## Number of taxa
set.seed(0)
ntaxa <- 25
ncharacters <- 100
#simulationID <- "0001"

## 1 - Generating the tree:
## Get the birth/death parameters
sample.birth.death <- function() {
    birth <- runif(min = 0, max = 1, 1)
    death <- runif(min = 0, max = birth, 1)
    return(c(birth, death))
}

## Get the tree
tree <- NULL
birth_death <- sample.birth.death()
while(is.null(tree)) {
    tree <- tree.bd(birth_death, max.taxa = ntaxa)
}

## Remove the $node labels (bugging for some reason)
tree$node.label <- NULL

## Make the first taxa (arbitrarily) the outgroup
tree$tip.label[[1]] <- "outgroup"
tree <- root(tree, "outgroup", resolve.root = TRUE)

## Save the "True tree"
#write.nexus(tree, file = paste(ntaxa,"t_", ncharacters, "c_", simulationID, "_truetree.nex", sep = ""))

## 2 - Generating the matrix
matrix_norm <- sim.morpho(tree, ncharacters, states = c(0.85,0.15), model = "mixed", rates = c(rgamma, rate = 100, shape = 3), invariant = FALSE)

## Testing Consistency
while(check.morpho(matrix_norm)[2,] < 0.26) {
    matrix_norm <- sim.morpho(tree, ncharacters, states = c(0.85,0.15), model = "mixed", rates = c(rgamma, rate = 100, shape = 3), invariant = FALSE)
}

## 3 - modify the matrix
character_differences <- char.diff(matrix_norm)

matrix_maxi <- modify.matrix(matrix_norm, type = "maximise", threshold = 0.25)
matrix_mini <- modify.matrix(matrix_norm, type = "minimise", threshold = 0.75)
matrix_rand <- modify.matrix(matrix_norm, type = "randomise", threshold = 0.25)

par(mfrow = c(2, 4))
plot.char.diff.density(char.diff(matrix_norm), "Normal")
plot.char.diff.density(char.diff(matrix_maxi), "Maximised", legend = FALSE)
plot.char.diff.density(char.diff(matrix_mini), "Minimised", legend = FALSE)
plot.char.diff.density(char.diff(matrix_rand), "Randomised", legend = FALSE)
plot.cor.matrix(char.diff(matrix_norm), main = "Normal")
plot.cor.matrix(char.diff(matrix_maxi), main = "Maximised", legend = FALSE)
plot.cor.matrix(char.diff(matrix_mini), main = "Minimised", legend = FALSE)
plot.cor.matrix(char.diff(matrix_rand), main ="Randomised", legend = FALSE)
