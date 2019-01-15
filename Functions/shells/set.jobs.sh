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
#guillert(at)tcd.ie - 2017/02/16
##########################

## Step 1 - INPUT

## Input values
chain1=$1
method=$2
CPU=$3
job_time=$4
username=$5
chain2=$6

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

    ## Job info
    # echo "#!/bin/sh" >> ${chain1}.mbjob
    # echo "#PBS -l walltime=${job_time}:00:00" >> ${chain1}.mbjob
    # echo "#PBS -l select=${nodes}:ncpus=${CPU}:mem=8gb" >> ${chain1}.mbjob
    # echo "" >> ${chain1}.mbjob
    # echo "## Load mrbayes" >> ${chain1}.mbjob
    # echo "module load intel-suite" >> ${chain1}.mbjob
    # echo "module load mpi" >> ${chain1}.mbjob
    # echo "module load beagle-lib" >> ${chain1}.mbjob
    # echo "module load mrbayes/3.2.6" >> ${chain1}.mbjob
    # echo "" >> ${chain1}.mbjob
    

    # echo "#!/bin/bash" >> ${chain1}.mbjob
    # echo "#PBS -A UQ-SCI-BiolSci" >> ${chain1}.mbjob
    # echo "#PBS -l nodes=${nodes}:ppn=${CPU},mem=32GB,vmem=32GB,walltime=${job_time}:00:00" >> ${chain1}.mbjob
    # echo "#PBS -m n" >> ${chain1}.mbjob
    # echo "" >> ${chain1}.mbjob

    # echo "## Load mrbayes" >> ${chain1}.mbjob
    # echo "module load mrbayes" >> ${chain1}.mbjob
    # echo "" >> ${chain1}.mbjob

    echo "#!/bin/bash" >> ${chain1}.template
    echo "#PBS -A UQ-SCI-BiolSci" >> ${chain1}.template
    echo "#-#PBS -l nodes=1:ppn=${CPU},mem=32gb,vmem=32GB,walltime=${job_time}:00:00" >> ${chain1}.template
    echo "#-#PBS -m n" >> ${chain1}.template
    echo "#PBS -N TEMPLATE.mbcmd" >> ${chain1}.template
    echo "#PBS -l select=1:ncpus=${CPU}:mpiprocs=${CPU}:mem=32gb:vmem=32GB,walltime=${job_time}:00:00" >> ${chain1}.template

    echo "## Load modules" >> ${chain1}.template
    echo "module load mrbayes" >> ${chain1}.template
    echo "module load openmpi_ib" >> ${chain1}.template

    # Saving entry time
    echo "## Entry time" >> ${chain1}.template
    echo "echo \"Entry time\"" >> ${chain1}.template
    echo "date" >> ${chain1}.template

    echo "## Run the script" >> ${chain1}.template
    echo "mpiexec -np ${CPU} mb /30days/${username}/TEMPLATE.mbcmd" >> ${chain1}.template

    echo "## Exit time" >> ${chain1}.template
    echo "echo \"Exit time\"" >> ${chain1}.template
    echo "date" >> ${chain1}.template

    echo "## Transfer files" >> ${chain1}.template
    echo "#mv \$HOME/TEMPLATE* /30days/${username}/" >> ${chain1}.template
    echo "#echo \"File transfer OK\"" >> ${chain1}.template



    ## Split the template into the multiple chain jobs
    sed 's/TEMPLATE/'"${chain1}"'_norm/g' ${chain1}.template > ${chain1}_norm.mbjob
    sed 's/TEMPLATE/'"${chain1}"'_maxi/g' ${chain1}.template > ${chain1}_maxi.mbjob
    sed 's/TEMPLATE/'"${chain1}"'_mini/g' ${chain1}.template > ${chain1}_mini.mbjob
    sed 's/TEMPLATE/'"${chain1}"'_rand/g' ${chain1}.template > ${chain1}_rand.mbjob

    ## Remove the template
    rm ${chain1}.template








    ## Creating the job folder (if exists)
    # echo "## Creating the saving folder" >> ${chain1}.mbjob
    # echo "pbsdsh2 \"mkdir -p \$WORK/CharSim/Bayesian/${chain1}/\"" >> ${chain1}.mbjob
    # echo "" >> ${chain1}.mbjob

    # # Saving entry time
    # echo "## Entry time" >> ${chain1}.mbjob
    # echo "echo \"Entry time\"" >> ${chain1}.mbjob
    # echo "date" >> ${chain1}.mbjob
    # echo "" >> ${chain1}.mbjob

    # ## Running the chains
    # echo "## Run the chains" >> ${chain1}.mbjob
    # echo "## norm" >> ${chain1}.mbjob
    # echo "mpiexec mb  \$HOME/CharSim/${chain1}_norm.mbcmd" >> ${chain1}.mbjob
    # echo "" >> ${chain1}.mbjob
    # echo "norm time out"  >> ${chain1}.mbjob
    # echo "date"  >> ${chain1}.mbjob
    # echo "" >> ${chain1}.mbjob
    # # echo "pbsdsh2 \"cp \$TMPDIR/* \$WORK/CharSim/Bayesian/${chain1}/\"" >> ${chain1}.mbjob

    # echo "## maxi" >> ${chain1}.mbjob
    # echo "mpiexec mb  \$HOME/CharSim/${chain1}_maxi.mbcmd" >> ${chain1}.mbjob
    # echo "" >> ${chain1}.mbjob
    # echo "maxi time out"  >> ${chain1}.mbjob
    # echo "date"  >> ${chain1}.mbjob
    # echo "" >> ${chain1}.mbjob

    # echo "## maxi" >> ${chain1}.mbjob
    # echo "pbsexec mpiexec mb \$HOME/CharSim/Bayesian/${chain1}_maxi.mbcmd" >> ${chain1}.mbjob
    # echo "if [ -f \"${chain1}_maxi.con.tre\" ] ; then echo \"maxi time out\" ; else echo \"maxi aborted\" ; fi"  >> ${chain1}.mbjob
    # echo "date"  >> ${chain1}.mbjob
    # echo "pbsdsh2 \"cp \$TMPDIR/* \$WORK/CharSim/Bayesian/${chain1}/\"" >> ${chain1}.mbjob
    # echo "" >> ${chain1}.mbjob

    # echo "## mini" >> ${chain1}.mbjob
    # echo "mpiexec mb  \$HOME/CharSim/${chain1}_mini.mbcmd" >> ${chain1}.mbjob
    # echo "" >> ${chain1}.mbjob
    # echo "mini time out"  >> ${chain1}.mbjob
    # echo "date"  >> ${chain1}.mbjob
    # echo "" >> ${chain1}.mbjob

    # echo "## mini" >> ${chain1}.mbjob
    # echo "pbsexec mpiexec mb \$HOME/CharSim/Bayesian/${chain1}_mini.mbcmd" >> ${chain1}.mbjob
    # echo "if [ -f \"${chain1}_mini.con.tre\" ] ; then echo \"mini time out\" ; else echo \"mini aborted\" ; fi"  >> ${chain1}.mbjob
    # echo "date"  >> ${chain1}.mbjob
    # echo "pbsdsh2 \"cp \$TMPDIR/* \$WORK/CharSim/Bayesian/${chain1}/\"" >> ${chain1}.mbjob
    # echo "" >> ${chain1}.mbjob

    # echo "## rand" >> ${chain1}.mbjob
    # echo "mpiexec mb  \$HOME/CharSim/${chain1}_rand.mbcmd" >> ${chain1}.mbjob
    # echo "" >> ${chain1}.mbjob
    # echo "rand time out"  >> ${chain1}.mbjob
    # echo "date"  >> ${chain1}.mbjob
    # echo "" >> ${chain1}.mbjob

    # echo "## rand" >> ${chain1}.mbjob
    # echo "pbsexec mpiexec mb \$HOME/CharSim/Bayesian/${chain1}_rand.mbcmd" >> ${chain1}.mbjob
    # echo "if [ -f \"${chain1}_rand.con.tre\" ] ; then echo \"rand time out\" ; else echo \"rand aborted\" ; fi"  >> ${chain1}.mbjob
    # echo "date"  >> ${chain1}.mbjob
    # echo "pbsdsh2 \"cp \$TMPDIR/* \$WORK/CharSim/Bayesian/${chain1}/\"" >> ${chain1}.mbjob
    # echo "" >> ${chain1}.mbjob

    # ## Saving exit time
    # echo "## Exit time" >> ${chain1}.mbjob
    # echo "echo \"Exit time\"" >> ${chain1}.mbjob
    # echo "date" >> ${chain1}.mbjob
fi

if echo $method | grep 'PAUP' > /dev/null
then

    ## Run the first chain
    sh set.runs.sh ${chain1} PAUP ${CPU} outgroup

    echo "paup ${chain1}_norm.ppcmd" > ${chain1}.paupjob
    echo "paup ${chain1}_maxi.ppcmd" >> ${chain1}.paupjob
    echo "paup ${chain1}_mini.ppcmd" >> ${chain1}.paupjob
    echo "paup ${chain1}_rand.ppcmd" >> ${chain1}.paupjob
    
    # echo "" > ${chain1}.paupjob
    # echo "#!/bin/sh" >> ${chain1}.paupjob
    # echo "#PBS -l walltime=${job_time}:00:00" >> ${chain1}.mbjob
    # echo "#PBS -l select=${nodes}:ncpus=${CPU}:mem=2gb" >> ${chain1}.mbjob
    # echo "" >> ${chain1}.paupjob

    # echo "## Load PAUP" >> ${chain1}.paupjob
    # echo "module load mpi" >> ${chain1}.paupjob
    # echo "module load beagle-lib" >> ${chain1}.paupjob
    # echo "module load mrbayes/3.2.6" >> ${chain1}.paupjob


    # echo "" >> ${chain1}.paupjob
    # echo "## Run the chains" >> ${chain1}.paupjob
    # echo "mpiexec mb \$HOME/CharSim/parsimony/${chain1}_norm.paupcmd" >> ${chain1}.paupjob
    # echo "mpiexec mb \$HOME/CharSim/parsimony${chain1}_maxi.paupcmd" >> ${chain1}.paupjob
    # echo "mpiexec mb \$HOME/CharSim/parsimony${chain1}_mini.paupcmd" >> ${chain1}.paupjob
    # echo "mpiexec mb \$HOME/CharSim/parsimony${chain1}_rand.paupcmd" >> ${chain1}.paupjob
    # if [ -n "$chain2" ]
    # then
    #     echo "mpiexec mb \$HOME/CharSim/parsimony${chain2}_norm.paupcmd" >> ${chain1}.paupjob
    #     echo "mpiexec mb \$HOME/CharSim/parsimony${chain2}_maxi.paupcmd" >> ${chain1}.paupjob
    #     echo "mpiexec mb \$HOME/CharSim/parsimony${chain2}_mini.paupcmd" >> ${chain1}.paupjob
    #     echo "mpiexec mb \$HOME/CharSim/parsimony${chain2}_rand.paupcmd" >> ${chain1}.paupjob
    # fi
fi
