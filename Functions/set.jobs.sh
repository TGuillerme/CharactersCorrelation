#!/bin/sh

##########################
#Shell script for creating the cluster jobs
##########################
#SYNTAX:
#sh set.runs.sh <chain1> <method> <CPU> <chain2>
#with:
#<chain1> the path to the matrix chain name to be run.
#<method> either "PAUP", "MrBayes" or "both".
#<CPU> number of CPUs available in total.
#<chain2> an additional path to a matrix chain name.
##########################
#----
#guillert(at)tcd.ie - 2016/11/17
##########################

## Step 1 - INPUT

## Input values
chain1=$1
method=$2
CPU=$3
chain2=$4

## Set up the methods
if echo $method | grep 'both' > /dev/null
then
    method="MrBayesPAUP"
fi

## Get the nodes numbers
nodes=$(echo "${CPU}/8" | bc)
if [ -n "$chain2" ]
then
    nodes=$(echo "${nodes}*2" | bc)
    CPU=$(echo "${CPU}*2" | bc)
fi


if echo $method | grep 'MrBayes' > /dev/null
then
    
    ## Run the first chain
    sh set.runs.sh ${chain1} MrBayes ${CPU} outgroup

    ## Run the second chain
    if [ -n "$chain2" ]
    then
        sh set.runs.sh ${chain2} MrBayes ${CPU} outgroup
    fi

    echo "" > ${chain1}.mbjob
    echo "#!/bin/sh" >> ${chain1}.mbjob
    echo "PBS -l walltime=04:00:00" >> ${chain1}.mbjob
    echo "PBS -l mem=3gb" >> ${chain1}.mbjob
    echo "PBS -l select=${nodes}:ncpus=${CPU}" >> ${chain1}.mbjob
    echo "" >> ${chain1}.mbjob
    echo "## Load mrbayes" >> ${chain1}.mbjob
    echo "module load mpi" >> ${chain1}.mbjob
    echo "module load beagle-lib" >> ${chain1}.mbjob
    echo "module load mrbayes/3.2.6" >> ${chain1}.mbjob
    echo "" >> ${chain1}.mbjob
    echo "## Run the chains" >> ${chain1}.mbjob
    echo "mpiexec mb ${chain1}_norm.mbcmd" >> ${chain1}.mbjob
    echo "mpiexec mb ${chain1}_maxi.mbcmd" >> ${chain1}.mbjob
    echo "mpiexec mb ${chain1}_mini.mbcmd" >> ${chain1}.mbjob
    echo "mpiexec mb ${chain1}_rand.mbcmd" >> ${chain1}.mbjob
    if [ -n "$chain2" ]
    then
        echo "mpiexec mb ${chain2}_norm.mbcmd" >> ${chain1}.mbjob
        echo "mpiexec mb ${chain2}_maxi.mbcmd" >> ${chain1}.mbjob
        echo "mpiexec mb ${chain2}_mini.mbcmd" >> ${chain1}.mbjob
        echo "mpiexec mb ${chain2}_rand.mbcmd" >> ${chain1}.mbjob
    fi
fi

if echo $method | grep 'PAUP' > /dev/null
then

    ## Run the first chain
    sh set.runs.sh ${chain1} PAUP ${CPU} outgroup

    ## Run the second chain
    if [ -n "$chain2" ]
    then
        sh set.runs.sh ${chain2} PAUP ${CPU} outgroup
    fi
    
    echo "" > ${chain1}.paupjob
    echo "#!/bin/sh" >> ${chain1}.paupjob
    echo "PBS -l walltime=04:00:00" >> ${chain1}.paupjob
    echo "PBS -l mem=3gb" >> ${chain1}.paupjob
    echo "PBS -l select=${nodes}:ncpus=${CPU}" >> ${chain1}.paupjob
    echo "" >> ${chain1}.paupjob

    echo "## Load PAUP" >> ${chain1}.paupjob
    echo "module load mpi" >> ${chain1}.paupjob
    echo "module load beagle-lib" >> ${chain1}.paupjob
    echo "module load mrbayes/3.2.6" >> ${chain1}.paupjob


    echo "" >> ${chain1}.paupjob
    echo "## Run the chains" >> ${chain1}.paupjob
    echo "mpiexec mb ${chain1}_norm.paupcmd" >> ${chain1}.paupjob
    echo "mpiexec mb ${chain1}_maxi.paupcmd" >> ${chain1}.paupjob
    echo "mpiexec mb ${chain1}_mini.paupcmd" >> ${chain1}.paupjob
    echo "mpiexec mb ${chain1}_rand.paupcmd" >> ${chain1}.paupjob
    if [ -n "$chain2" ]
    then
        echo "mpiexec mb ${chain2}_norm.paupcmd" >> ${chain1}.paupjob
        echo "mpiexec mb ${chain2}_maxi.paupcmd" >> ${chain1}.paupjob
        echo "mpiexec mb ${chain2}_mini.paupcmd" >> ${chain1}.paupjob
        echo "mpiexec mb ${chain2}_rand.paupcmd" >> ${chain1}.paupjob
    fi
fi
