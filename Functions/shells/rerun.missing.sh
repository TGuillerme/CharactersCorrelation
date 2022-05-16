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
    sed -i -e '15,18 s/^/#/' ${chain}.mbjob-bis
fi

## Comment out maxi
if echo $missing | grep '2' > /dev/null
then
    sed -i -e '15,18 s/^/#/' ${chain}.mbjob-bis
    sed -i -e '21,24 s/^/#/' ${chain}.mbjob-bis
fi

## Comment out mini
if echo $missing | grep '1' > /dev/null
then
    sed -i -e '15,18 s/^/#/' ${chain}.mbjob-bis
    sed -i -e '21,24 s/^/#/' ${chain}.mbjob-bis
    sed -i -e '27,30 s/^/#/' ${chain}.mbjob-bis
fi

## Append checkpoints

## Append norm
if echo $broken | grep '1' > /dev/null
then
    ## Modify the mb command file
    cp ${chain}_norm.mbcmd ${chain}_norm
    sed -i -e 's/mcmc nruns=2/mcmc append=yes nruns=2/' ${chain}_norm

    ## Modify the job file
    sed -i -e 's/mpiexec mb  $HOME\/CharSim\/'"${chain}"'_norm.mbcmd/mpiexec mb  $HOME\/CharSim\/'"${chain}"'_norm/' ${chain}.mbjob-bis

fi

if echo $broken | grep '2' > /dev/null
then
    ## Modify the mb command file
    cp ${chain}_maxi.mbcmd ${chain}_maxi
    sed -i -e 's/mcmc nruns=2/mcmc append=yes nruns=2/' ${chain}_maxi

    ## Modify the job file
    sed -i -e 's/mpiexec mb  $HOME\/CharSim\/'"${chain}"'_maxi.mbcmd/mpiexec mb  $HOME\/CharSim\/'"${chain}"'_maxi/' ${chain}.mbjob-bis

fi

if echo $broken | grep '3' > /dev/null
then
    ## Modify the mb command file
    cp ${chain}_mini.mbcmd ${chain}_mini
    sed -i -e 's/mcmc nruns=2/mcmc append=yes nruns=2/' ${chain}_mini

    ## Modify the job file
    sed -i -e 's/mpiexec mb  $HOME\/CharSim\/'"${chain}"'_mini.mbcmd/mpiexec mb  $HOME\/CharSim\/'"${chain}"'_mini/' ${chain}.mbjob-bis

fi

if echo $broken | grep '4' > /dev/null
then
    ## Modify the mb command file
    cp ${chain}_rand.mbcmd ${chain}_rand
    sed -i -e 's/mcmc nruns=2/mcmc append=yes nruns=2/' ${chain}_rand

    ## Modify the job file
    sed -i -e 's/mpiexec mb  $HOME\/CharSim\/'"${chain}"'_rand.mbcmd/mpiexec mb  $HOME\/CharSim\/'"${chain}"'_rand/' ${chain}.mbjob-bis

fi

rm *-e
# rm *.mbjob-bis-e