## Packages and functions
library(Claddis)
library(dispRity)
library(diversitree)
source("../../Functions/cor.matrix.R")
source("../../Functions/modify.matrix.R")
source("../../Functions/plot.char.diff.density.R")
source("../../Functions/plot.cor.matrix.R")
source("../../Functions/write.nexus.std.R")
source("../../Functions/char.diff.R")
dyn.load("../../Functions/char.diff.so")
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

get.CI <- function(X) {
    return(X[3,])
}

## Testing parameter (CI distribution)
gamma <- list(c(rgamma, rate = 1, shape = 1), c(rgamma, rate = 10, shape = 1), c(rgamma, rate = 100, shape = 1), c(rgamma, rate = 1, shape = 5), c(rgamma, rate = 10, shape = 5), c(rgamma, rate = 100, shape = 5))
runs <- 30

for(param in 1:length(gamma)) {
    t25_c100 <- replicate(runs, morpho.wrapper(25, 100, gamma[[param]]), simplify = FALSE)
    t25_c350 <- replicate(runs, morpho.wrapper(25, 350, gamma[[param]]), simplify = FALSE)
    t25_c1000 <- replicate(runs, morpho.wrapper(25, 1000, gamma[[param]]), simplify = FALSE)
    t75_c100 <- replicate(runs, morpho.wrapper(75, 100, gamma[[param]]), simplify = FALSE)
    t75_c350 <- replicate(runs, morpho.wrapper(75, 350, gamma[[param]]), simplify = FALSE)
    t75_c1000 <- replicate(runs, morpho.wrapper(75, 1000, gamma[[param]]), simplify = FALSE)
    t150_c100 <- replicate(runs, morpho.wrapper(150, 100, gamma[[param]]), simplify = FALSE)
    t150_c350 <- replicate(runs, morpho.wrapper(150, 350, gamma[[param]]), simplify = FALSE)
    t150_c1000 <- replicate(runs, morpho.wrapper(150, 1000, gamma[[param]]), simplify = FALSE)

    pdf(width = 14, height = 14, file = paste("Gamma_", gamma[[param]][[2]], "_", gamma[[param]][[3]], ".pdf", sep = "" ))
    par(mfrow = c(3,3))
    hist(unlist(lapply(t25_c100, get.CI)), breaks = 20, main = "25t_100c", xlab = "Consistency Index", xlim = c(0,1)) ; abline(v = 0.26, lty = 3)
    hist(unlist(lapply(t25_c350, get.CI)), breaks = 20, main = "25t_350c", xlab = "Consistency Index", xlim = c(0,1)) ; abline(v = 0.26, lty = 3)
    hist(unlist(lapply(t25_c1000, get.CI)), breaks = 20, main = "25t_1000c", xlab = "Consistency Index", xlim = c(0,1)) ; abline(v = 0.26, lty = 3)
    hist(unlist(lapply(t75_c100, get.CI)), breaks = 20, main = "75t_100c", xlab = "Consistency Index", xlim = c(0,1)) ; abline(v = 0.26, lty = 3)
    hist(unlist(lapply(t75_c350, get.CI)), breaks = 20, main = "75t_350c", xlab = "Consistency Index", xlim = c(0,1)) ; abline(v = 0.26, lty = 3)
    hist(unlist(lapply(t75_c1000, get.CI)), breaks = 20, main = "75t_1000c", xlab = "Consistency Index", xlim = c(0,1)) ; abline(v = 0.26, lty = 3)
    hist(unlist(lapply(t150_c100, get.CI)), breaks = 20, main = "150t_100c", xlab = "Consistency Index", xlim = c(0,1)) ; abline(v = 0.26, lty = 3)
    hist(unlist(lapply(t150_c350, get.CI)), breaks = 20, main = "150t_350c", xlab = "Consistency Index", xlim = c(0,1)) ; abline(v = 0.26, lty = 3)
    hist(unlist(lapply(t150_c1000, get.CI)), breaks = 20, main = "150t_1000c", xlab = "Consistency Index", xlim = c(0,1)) ; abline(v = 0.26, lty = 3)
    dev.off()
}