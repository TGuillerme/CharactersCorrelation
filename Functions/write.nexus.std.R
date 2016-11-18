## Copy the normal write nexus data function
write.nexus.std <- write.nexus.data
## Adds the STANDARD data option
body(write.nexus.std)[[2]] <- substitute(format <- match.arg(toupper(format), c("DNA", "PROTEIN", "STANDARD")))