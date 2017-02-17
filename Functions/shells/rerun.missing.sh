#!/bin/sh

##########################
#Shell script for re-runing jobs with missing trees
##########################
#SYNTAX:
#sh rerun.missing.sh <chain> <broken> <missing>
#with:
#<chain> being the chain name
#<broken> the number of the chain to be continued from checkpoint (0 = none, 1 = norm, 2 = maxi, etc...)
#<missing> being the number of trees to rerun.
##########################
#----
#guillert(at)tcd.ie - 2017/02/16
##########################

## Input values
chain=$1
broken=$2
missing=$3

## Creating the bis job
cp ${chain}.mbjob ${chain}.mbjob-bis


## Comment out norm
if echo $missing | grep '3' > /dev/null
then
    sed -i -e '20,23 s/^/#/' ${chain}.mbjob-bis
fi

## Comment out maxi
if echo $missing | grep '2' > /dev/null
then
    sed -i -e '20,23 s/^/#/' ${chain}.mbjob-bis
    sed -i -e '26,29 s/^/#/' ${chain}.mbjob-bis
fi

## Comment out mini
if echo $missing | grep '1' > /dev/null
then
    sed -i -e '20,23 s/^/#/' ${chain}.mbjob-bis
    sed -i -e '26,29 s/^/#/' ${chain}.mbjob-bis
    sed -i -e '32,35 s/^/#/' ${chain}.mbjob-bis
fi



## Append checkpoints

## Append norm
# if echo $broken | grep '1' > /dev/null
# then
#     ## Modify the mb command file
#     cp ${chain}_norm.mbcmd ${chain}_norm.append
#     sed -i -e 's/outgroup outgroup ;/[outgroup outgroup ;]/' ${chain}_norm.append
#     sed -i -e 's/lset nst=1 rates=gamma Ngammacat=4;/[lset nst=1 rates=gamma Ngammacat=4;]/' ${chain}_norm.append
#     sed -i -e 's/prset ratepr=variable Shapepr=Exponential(0.5);/[prset ratepr=variable Shapepr=Exponential(0.5);]/' ${chain}_norm.append
#     sed -i -e 's/mcmc nruns=2 Nchains=6 ngen=100000000 samplefreq=200 printfreq=2000 diagnfreq=10000 Stoprule=YES stopval=0.01 mcmcdiagn=YES file='"${chain}"'_norm;/mcmc append=yes;/' ${chain}_norm.append

#     ## Modify the job file
#     sed -i -e 's/## norm/blabalbal/' ${chain}.mbjob-bis
#     sed -i -e "/## norm/aline1\nline2\nline3\nline4" ${chain}.mbjob-bis
#     #cp $HOME\/CharSim\/Bayesian\/'"${chain}"'_norm.append $WORK\/CharSim/Bayesian\/'"${chain}"'\/ ; mv '"${chain}"'_norm.append '"${chain}"'_norm/
#     sed -i -e 's/pbsexec mpiexec mb \$HOME\/CharSim\/Bayesian\/'"${chain}"'_norm.mbcmd/pbsexec mpiexec mb $WORK/CharSim/Bayesian/'"${chain}"'_norm/' ${chain}.mbjob-bis
# fi

rm *.mbjob-bis-e