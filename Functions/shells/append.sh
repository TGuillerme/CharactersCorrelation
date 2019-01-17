#!/bin/sh

##########################
#Shell script for appending an MCMC
##########################
#SYNTAX:
#sh append.sh <mbcmd>
#with:
#<mbcmd> the .mbcmd file to append
##########################
#----
#guillert(at)tcd.ie - 2019/01/17
##########################

## Input
mbcmd=$1

sed 's/mcmc nruns=2/mcmc append=yes nruns=2/' ${mbcmd} > mbcmd.tmp
mv mbcmd.tmp ${mbcmd}

#End