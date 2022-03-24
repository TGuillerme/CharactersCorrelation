
### dropNames and dropBlanks are utility functions for read.wilkdat
dropNames <- function(x)		{
	out <- x[-1]
	return(out)
}
dropBlanks <- function(x)	{
	Keeps <- which(x != "")
	return(x[Keeps])
}

### read.wilkdat reads in a file in the format used by MATRIX.EXE and converts it into an actual matrix in R (i.e., it removes all the fluff and reformats the character strings)
read.wilkdat <- function(xstring)	{
	x <- read.table(xstring, sep="^", stringsAsFactors=FALSE)
	Stop <- which(x=="codes") - 1
	dataLines <- 2:Stop
	x <- x[dataLines,]
	Pieces <- sapply(x, function(i) strsplit(i, " ")[[1]])
	Names <- sapply(Pieces, function(i) i[1])
	NoNames <- lapply(Pieces, dropNames)
	NoBlanks <- lapply(NoNames, dropBlanks)
	Collapsed <- lapply(NoBlanks, paste, collapse="")
	CharSplit <- lapply(Collapsed, function(j) unlist(strsplit(j, split="")))
	Matrix <- do.call(rbind, CharSplit)
	rownames(Matrix) <- Names
	return(Matrix)
}

### Core function for character compatibility. Given a data matrix and a pair of characters (i & j), this computes whether they conflict (1) or are compatible (0)
pairCompat <- function(i, j, count, type="conflict")	{
	Keeps <- intersect(c(which(i == "0"), which(i=="1")), c(which(j == "0"), which(j=="1")))
	Combns <- paste(i[Keeps], j[Keeps])
	Pairs <- unique(Combns)
	if (type=="conflict")	{
		Incompatibility <- ifelse(length(Pairs) < count, 0, 1)
		return(Incompatibility)
	}
	if (type=="nesting")		{
		count <- 3
		iDerived <- which(i[Keeps]=="1")
		jDerived <- which(j[Keeps]=="1")
		derLen <- c(length(iDerived), length(jDerived))
		Nested <- length(intersect(iDerived, jDerived))
		isNested <- ifelse(min(derLen)==Nested, 1, 0)
		return(isNested)
	}
}

### Workhorse function. This function takes two main arguments: a data matrix, and a matrix of character pairs. It then compares each set of character pairs and determines if they are compatible or not. It then returns the *total number of incompatibilities*. 
compCount <- function(Matrix, pairwiseComp, Count=4, Type="conflict")	{
	calcComp <- apply(pairwiseComp, 2, function(x) pairCompat(Matrix[,x[1]], Matrix[,x[2]], count=Count, type=Type))
	nIncomps <- sum(calcComp)
	return(nIncomps)
}

### For calculating the IER statistics, this function permutes the elements of a character while maintaining the position of all unknown values. So if a specific taxon has a ? score before permutation, that same taxon will *still* have a ? score *after* permutation, while all of taxa will have their scores scrambled. It also does not permute the first taxon's values if holdFirst==TRUE. The reason for both of these is that they are the defaults in MATRIX.EXE, and I saw no reason to change them.
permuteColumn <- function(x, holdFirst=TRUE, leaveUnk=TRUE)	{
	if (length(which(x=="?")) == 0)	{
		leaveUnk <- FALSE
	}
	if (holdFirst == TRUE)	{
		first <- x[1]
		x <- x[2:length(x)]
	}
	if (leaveUnk == TRUE)	{
		unks <- which(x=="?")
		x2 <- x[which(x!="?")]
		x3 <- sample(x2)
		x4 <- x3
		for (count in 1:length(unks))	{
			x4 <- append(x4, "?", unks[count]-1)
		}
		x <- x4
	}
	if (leaveUnk == FALSE)	{
		x <- sample(x)
	}
	if (holdFirst == TRUE)	{
		x <- c(first, x)
	}
	return(x)
}

### This function permutes every column in a character matrix a certain number (Nruns) of times.
permuteMatrix <- function(Matrix, Nruns=1e3, HoldFirst=TRUE, LeaveUnk=TRUE)	{
	Matrix_new <- replicate(Nruns, apply(Matrix, 2, permuteColumn, holdFirst=HoldFirst, leaveUnk=LeaveUnk), simplify=FALSE)
	return(Matrix_new)
}

### calcIER is the primary function in this set. It takes a character matrix, computes all of the incompatibilities, then scrambles the matrix Nruns times and computes the incompatibilities for all the permuted matrices to compare them.
calcIER <- function(Matrix, Nruns=1e3, Count=4, plot=FALSE, Type="conflict")	{
	Pairs <- combn(ncol(Matrix), 2)
	O <- compCount(Matrix, Pairs, Count=Count, Type=Type)

	Matrices <- permuteMatrix(Matrix, Nruns)
	O_perms <- sapply(Matrices, function(x) compCount(x, pairwiseComp=Pairs, Count=Count, Type=Type))

	R <- mean(O_perms)
	N <- quantile(O_perms, probs=0.05)
	IER1 <- (R - O) / R
	IER2 <- (N - O) / N

	if (plot == TRUE)	{
		hist(O_perms, col='black', border='white', main="", xlab="Permuted N incompatibilities", ylab="Frequency", las=1, xlim=range(c(O, O_perms)))
		abline(v=O, col='red')
	}
	return(c(incompt=O, meanRandom=mean(O_perms), IER1=IER1, IER2=IER2))
}

### partIER is a wrapper function that allows character partitions and runs calcIER on each character partition
partIER <- function(Matrix, Nruns=1e3, Count=4, parts=NULL, Type="conflict")	{
	if (is.null(parts))	{
		parts <- rep(1, ncol(Matrix))
	}
	UniParts <- unique(parts)
	Runs <- sapply(UniParts, function(x) calcIER(Matrix[,which(parts==x)], Nruns, Count, plot=FALSE, Type=Type))
	return(Runs)
}