## Modified write.nexus.data function to cope with standard data
write.nexus.std <- ape::write.nexus.data
body(write.nexus.std)[[2]] <- substitute(format <- match.arg(toupper(format), c("DNA", "PROTEIN", "STANDARD")))
body(write.nexus.std)[[26]][[3]][[4]] <- substitute(fcat(indent, "FORMAT", " ", DATATYPE, " ", MISSING, " ", GAP, 
    " ", INTERLEAVE, " symbols=\"0123456789\";\n"))
