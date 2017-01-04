#!/bin/sh

##########################
#Shell script for re-runing jobs with missing trees
##########################
#SYNTAX:
#sh rerun.missing.sh <chain> <missing>
#with:
#<chain> being the chain name
#<missing> being the number of trees to rerun.
##########################
#----
#guillert(at)tcd.ie - 2017/01/04
##########################

## Input values
chain=$1
missing=$2

cp ${chain}.mbjob ${chain}.mbjob-bis

if echo $missing | grep '3' > /dev/null
then
    sed -i -e 's/$PBS_JOBID/bis_$PBS_JOBID/g' ${chain}.mbjob-bis
    sed -i -e 's/mpiexec mb \$HOME\/CharSim\/Bayesian\/'"${chain}"'_norm.mbcmd/# mpiexec mb \$HOME\/CharSim\/Bayesian\/'"${chain}"'_norm.mbcmd/g' ${chain}.mbjob-bis
fi

if echo $missing | grep '2' > /dev/null
then
    sed -i -e 's/$PBS_JOBID/bis_$PBS_JOBID/g' ${chain}.mbjob-bis
    sed -i -e 's/mpiexec mb \$HOME\/CharSim\/Bayesian\/'"${chain}"'_norm.mbcmd/# mpiexec mb \$HOME\/CharSim\/Bayesian\/'"${chain}"'_norm.mbcmd/g' ${chain}.mbjob-bis
    sed -i -e 's/mpiexec mb \$HOME\/CharSim\/Bayesian\/'"${chain}"'_maxi.mbcmd/# mpiexec mb \$HOME\/CharSim\/Bayesian\/'"${chain}"'_maxi.mbcmd/g' ${chain}.mbjob-bis
fi

if echo $missing | grep '1' > /dev/null
then
    sed -i -e 's/$PBS_JOBID/bis_$PBS_JOBID/g' ${chain}.mbjob-bis
    sed -i -e 's/mpiexec mb \$HOME\/CharSim\/Bayesian\/'"${chain}"'_norm.mbcmd/# mpiexec mb \$HOME\/CharSim\/Bayesian\/'"${chain}"'_norm.mbcmd/g' ${chain}.mbjob-bis
    sed -i -e 's/mpiexec mb \$HOME\/CharSim\/Bayesian\/'"${chain}"'_maxi.mbcmd/# mpiexec mb \$HOME\/CharSim\/Bayesian\/'"${chain}"'_maxi.mbcmd/g' ${chain}.mbjob-bis
    sed -i -e 's/mpiexec mb \$HOME\/CharSim\/Bayesian\/'"${chain}"'_mini.mbcmd/# mpiexec mb \$HOME\/CharSim\/Bayesian\/'"${chain}"'_mini.mbcmd/g' ${chain}.mbjob-bis
fi

rm *.mbjob-bis-e