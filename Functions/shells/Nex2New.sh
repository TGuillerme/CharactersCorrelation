##########################
#Transforms a chain of nexus trees into newick trees (or the other way around)
##########################
#SYNTAX :
#sh New2Nex.sh <chain> <format>
#with
#<chain> the chain of trees to convert
#<format> the new output format (either nexus or newick)
##########################
#version: 0.1
Nex2New_version="Nex2New.sh v0.1"
#----
#guillert(at)tcd.ie - 2017/01/09
##########################
#Requirements:
#-R >= 3
#-R package "ape"
##########################

#INPUT
chain=$1
format=$2

#R SETTINGS
echo "library(ape) ; trees<-list.files(pattern='$chain')" > TEM_NexToNew.R
echo "rewrite.fun <- function(chain, fun.in, fun.out) { fun.out(fun.in(chain), file = paste(chain, '.$format', sep='')) ; message('.', appendLF=FALSE) ; return(invisible())}" >> TEM_NexToNew.R

if [ $format == "newick" ]
then
    echo "fun.in <- read.nexus ; fun.out <- write.tree" >> TEM_NexToNew.R
else
    echo "fun.in <- read.tree ; fun.out <- write.nexus" >> TEM_NexToNew.R
fi

echo "lapply(as.list(trees), rewrite.fun, fun.in, fun.out)" >> TEM_NexToNew.R

#CONVERTING THE FILES
length=$(ls *$chain* | wc -l | sed 's/[[:space:]]//g')
echo "Converting $length trees into $format."
R --no-save < TEM_NexToNew.R >/dev/null
rm TEM_NexToNew.R
echo "Done."

#End