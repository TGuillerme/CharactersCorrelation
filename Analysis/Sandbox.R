## Packages and functions
library(Claddis)
library(dispRity)
library(diversitree)
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

tree.wrapper <- function(ntaxa) {
    tree <- NULL
    birth_death <- sample.birth.death()
    while(is.null(tree)) {
        tree <- tree.bd(birth_death, max.taxa = ntaxa)
    }
    tree$node.label <- NULL
    tree$tip.label[[1]] <- "outgroup"
    tree <- root(tree, "outgroup", resolve.root = TRUE)

    return(tree)
}

morpho.wrapper <- function(ntaxa, ncharacters, gamma) {
    tree <- tree.wrapper(ntaxa)
    cat(".")
    return(check.morpho(sim.morpho(tree, ncharacters, states = c(0.85,0.15), model = "mixed", rates = gamma, invariant = FALSE), tree))
}

## Testing parameter (CI distribution)
gamma <- c(rgamma, rate = 100, shape = 3)
runs = 20

cat("25t_100c:")
t25_c100 <- replicate(runs, morpho.wrapper(25, 100, gamma), simplify = FALSE)
cat("Done.\n")
cat("25t_350c:")
t25_c350 <- replicate(runs, morpho.wrapper(25, 350, gamma), simplify = FALSE)
cat("Done.\n")
cat("25t_1000c:")
t25_c1000 <- replicate(runs, morpho.wrapper(25, 1000, gamma), simplify = FALSE)
cat("Done.\n")
cat("75t_100c:")
t75_c100 <- replicate(runs, morpho.wrapper(75, 100, gamma), simplify = FALSE)
cat("Done.\n")
cat("75t_350c:")
t75_c350 <- replicate(runs, morpho.wrapper(75, 350, gamma), simplify = FALSE)
cat("Done.\n")
cat("75t_1000c:")
t75_c1000 <- replicate(runs, morpho.wrapper(75, 1000, gamma), simplify = FALSE)
cat("Done.\n")
cat("150t_100c:")
t150_c100 <- replicate(runs, morpho.wrapper(150, 100, gamma), simplify = FALSE)
cat("Done.\n")
cat("150t_350c:")
t150_c350 <- replicate(runs, morpho.wrapper(150, 350, gamma), simplify = FALSE)
cat("Done.\n")
cat("150t_1000c:")
t150_c1000 <- replicate(runs, morpho.wrapper(150, 1000, gamma), simplify = FALSE)
cat("Done.\n")

get.CI <- function(X) {
    return(X[3,])
}

pdf(width = 14, height = 14, file = "Gamma_100_3.pdf")
par(mfrow = c(3,3))
hist(unlist(lapply(t25_c100, get.CI)), breaks = 10, main = "25t_100c")
hist(unlist(lapply(t25_c350, get.CI)), breaks = 10, main = "25t_350c")
hist(unlist(lapply(t25_c1000, get.CI)), breaks = 10, main = "25t_1000c")
hist(unlist(lapply(t75_c100, get.CI)), breaks = 10, main = "75t_100c")
hist(unlist(lapply(t75_c350, get.CI)), breaks = 10, main = "75t_350c")
hist(unlist(lapply(t75_c1000, get.CI)), breaks = 10, main = "75t_1000c")
hist(unlist(lapply(t150_c100, get.CI)), breaks = 10, main = "150t_100c")
hist(unlist(lapply(t150_c350, get.CI)), breaks = 10, main = "150t_350c")
hist(unlist(lapply(t150_c1000, get.CI)), breaks = 10, main = "150t_1000c")
dev.off()