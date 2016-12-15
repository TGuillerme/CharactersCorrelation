#!/bin/sh

##########################
#Shell script for creating the cluster jobs
##########################
#SYNTAX:
#sh set.runs.sh <chain> <method> <CPU>
#with:
#<matrix> the path to the matrix to be run.
#<method> either "PAUP", "MrBayes" or "both".
#<CPU> number of CPUs available in total.
##########################
#----
#guillert(at)tcd.ie - 2016/11/17
##########################

## Step 1 - INPUT

## Input values
matrix=$1
method=$2
CPU=$3

## Set up the methods
if echo $method | grep 'both' > /dev/null
then
    method="MrBayesPAUP"
fi

## Get the chain name
chain_name=$(echo $matrix | sed 's/.nex//g')

## Get the CPU numbers
if echo $CPU | grep '1'
then
    runs=1
    chains=2
else
    runs=2
    chains=$(echo "$CPU / 2" | bc | sed 's/\.[0-9]*//g')
fi


## To run:
# qsub <chain>.job


#!/bin/sh 
#PBS -l walltime=02:00:00
#PBS -l mem=6gb
#PBS -l select=2:ncpus=16

## Load mrbayes
module load mpi
module load beagle-lib
module load mrbayes/3.2.6

## Run the scripts
mpiexec mb ${chain_name}_norm.mbcmd
mpiexec mb ${chain_name}_maxi.mbcmd
mpiexec mb ${chain_name}_mini.mbcmd
mpiexec mb ${chain_name}_rand.mbcmd
