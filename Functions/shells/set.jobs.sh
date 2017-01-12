#!/bin/sh

##########################
#Shell script for creating the cluster jobs
##########################
#SYNTAX:
#sh set.runs.sh <chain1> <method> <CPU> <job_time> <chain2>
#with:
#<chain1> the path to the matrix chain name to be run.
#<method> either "PAUP", "MrBayes" or "both".
#<CPU> number of CPUs available in total.
#<job_time> in hours.
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
job_time=$4
chain2=$5

## Set up the methods
if echo $method | grep 'both' > /dev/null
then
    method="MrBayesPAUP"
fi

## Get the nodes numbers
# nodes=$(echo "${CPU}/8" | bc)
# if [ -n "$chain2" ]
# then
#     nodes=$(echo "${nodes}*2" | bc)
#     CPU=$(echo "${CPU}*2" | bc)
# fi

nodes=1
CPU=12

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
    echo "#PBS -l walltime=${job_time}:00:00" >> ${chain1}.mbjob
    echo "#PBS -l select=${nodes}:ncpus=${CPU}:mem=2gb" >> ${chain1}.mbjob
    echo "" >> ${chain1}.mbjob
    echo "## Load mrbayes" >> ${chain1}.mbjob
    echo "module load intel-suite" >> ${chain1}.mbjob
    echo "module load mpi" >> ${chain1}.mbjob
    echo "module load beagle-lib" >> ${chain1}.mbjob
    echo "module load mrbayes/3.2.6" >> ${chain1}.mbjob
    echo "" >> ${chain1}.mbjob
    echo "## Creating the saving folder"
    echo "pbsdsh2 \"mkdir -p \$WORK/CharSim/Bayesian/${chain1}_\$PBS_JOBID/\"" >> ${chain1}.mbjob
    echo "## Entry time" >> ${chain1}.mbjob
    echo "echo \"Entry time\"" >> ${chain1}.mbjob
    echo "date" >> ${chain1}.mbjob
    echo "" >> ${chain1}.mbjob
    echo "## Run the chains" >> ${chain1}.mbjob
    echo "pbsexec mpiexec mb \$HOME/CharSim/Bayesian/${chain1}_norm.mbcmd ; echo \"norm time out\" ; date" >> ${chain1}.mbjob
    echo "## Saving the output" >> ${chain1}.mbjob
    echo "pbsdsh2 \"cp \$TMPDIR/* \$WORK/CharSim/Bayesian/${chain1}_\$PBS_JOBID/\"" >> ${chain1}.mbjob
    echo "pbsexec mpiexec mb \$HOME/CharSim/Bayesian/${chain1}_maxi.mbcmd ; echo \"maxi time out\" ; date" >> ${chain1}.mbjob
    echo "## Saving the output" >> ${chain1}.mbjob
    echo "pbsdsh2 \"cp \$TMPDIR/* \$WORK/CharSim/Bayesian/${chain1}_\$PBS_JOBID/\"" >> ${chain1}.mbjob
    echo "pbsexec mpiexec mb \$HOME/CharSim/Bayesian/${chain1}_mini.mbcmd ; echo \"mini time out\" ; date" >> ${chain1}.mbjob
    echo "## Saving the output" >> ${chain1}.mbjob
    echo "pbsdsh2 \"cp \$TMPDIR/* \$WORK/CharSim/Bayesian/${chain1}_\$PBS_JOBID/\"" >> ${chain1}.mbjob
    echo "pbsexec mpiexec mb \$HOME/CharSim/Bayesian/${chain1}_rand.mbcmd ; echo \"rand time out\" ; date" >> ${chain1}.mbjob
    echo "## Saving the output" >> ${chain1}.mbjob
    echo "pbsdsh2 \"cp \$TMPDIR/* \$WORK/CharSim/Bayesian/${chain1}_\$PBS_JOBID/\"" >> ${chain1}.mbjob
    echo "" >> ${chain1}.mbjob
    echo "## Exit time" >> ${chain1}.mbjob
    echo "echo \"Exit time\"" >> ${chain1}.mbjob
    echo "date" >> ${chain1}.mbjob
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
    echo "#PBS -l walltime=72:00:00" >> ${chain1}.mbjob
    echo "#PBS -l select=${nodes}:ncpus=${CPU}:mem=2gb" >> ${chain1}.mbjob
    echo "" >> ${chain1}.paupjob

    echo "## Load PAUP" >> ${chain1}.paupjob
    echo "module load mpi" >> ${chain1}.paupjob
    echo "module load beagle-lib" >> ${chain1}.paupjob
    echo "module load mrbayes/3.2.6" >> ${chain1}.paupjob


    echo "" >> ${chain1}.paupjob
    echo "## Run the chains" >> ${chain1}.paupjob
    echo "mpiexec mb \$HOME/CharSim/parsimony/${chain1}_norm.paupcmd" >> ${chain1}.paupjob
    echo "mpiexec mb \$HOME/CharSim/parsimony${chain1}_maxi.paupcmd" >> ${chain1}.paupjob
    echo "mpiexec mb \$HOME/CharSim/parsimony${chain1}_mini.paupcmd" >> ${chain1}.paupjob
    echo "mpiexec mb \$HOME/CharSim/parsimony${chain1}_rand.paupcmd" >> ${chain1}.paupjob
    if [ -n "$chain2" ]
    then
        echo "mpiexec mb \$HOME/CharSim/parsimony${chain2}_norm.paupcmd" >> ${chain1}.paupjob
        echo "mpiexec mb \$HOME/CharSim/parsimony${chain2}_maxi.paupcmd" >> ${chain1}.paupjob
        echo "mpiexec mb \$HOME/CharSim/parsimony${chain2}_mini.paupcmd" >> ${chain1}.paupjob
        echo "mpiexec mb \$HOME/CharSim/parsimony${chain2}_rand.paupcmd" >> ${chain1}.paupjob
    fi
fi
