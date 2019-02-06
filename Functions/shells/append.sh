#!/bin/sh

##########################
#Shell script for appending an MCMC
##########################
#SYNTAX:
#sh append.sh <chain>
#with:
#<chain> the chain to append
##########################
#----
#guillert(at)tcd.ie - 2019/02/06
##########################

## Input
chain=$1

## Append the mbcmd file
sed 's/mcmc nruns=2/mcmc append=yes nruns=2/' ${chain}.mbcmd > chain.tmp
mv mbcmd.tmp ${chain}.mbcmd

## Append the first tree file
tail_end=$(tail -1 ${chain}.run1.t)
if echo ${tail_end} | grep -q "end;"
then
    run1_finished="TRUE"
else
    run1_finished="FALSE"
    echo "end;" >> ${chain}.run1.t
fi

## Append the second tree file
tail_end=$(tail -1 ${chain}.run2.t)
if echo ${tail_end} | grep -q "end;"
then
    run1_finished="TRUE"
else
    run1_finished="FALSE"
    echo "end;" >> ${chain}.run2.t
fi

## Remove old outputs
rm ${chain}.o*
rm ${chain}.e*

## Rerun the job
qsub ${chain}.mbjob

#End