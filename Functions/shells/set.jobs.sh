#!/bin/sh

##########################
#Shell script for creating the cluster jobs
##########################
#SYNTAX:
#sh set.runs.sh <chain> <method> <CPU> <job_time> <username> <dir>
#with:
#<chain> the path to the matrix chain name to be run.
#<method> either "PAUP", "MrBayes" or "both".
#<CPU> number of CPUs available in total.
#<job_time> in hours.
#<username> the user name.
#<dir> the directory name (home/30days/90days)
#
#EXAMPLE
#sh set.run.sh 25t_100c_0001 MrBayes 12 168 uqtguil2 90days
##########################
#----
#guillert(at)tcd.ie - 2019/01/17
##########################

## Step 1 - INPUT

## Input values
chain=$1
method=$2
CPU=$3
job_time=$4
username=$5
dir=$6

## Set up the methods
if echo $method | grep 'both' > /dev/null
then
    method="MrBayesPAUP"
fi

nodes=1
CPU=12

if echo $method | grep 'MrBayes' > /dev/null
then
    
    ## Run the first chain
    sh set.runs.sh ${chain} MrBayes ${CPU} outgroup

    ## Job Info
    echo "#!/bin/bash" >> ${chain}.template
    echo "#PBS -A UQ-SCI-BiolSci" >> ${chain}.template
    echo "#PBS -N TEMPLATE.mbcmd" >> ${chain}.template
    echo "#PBS -l select=1:ncpus=${CPU}:mpiprocs=${CPU}:mem=32gb:vmem=32GB,walltime=${job_time}:00:00" >> ${chain}.template

    echo "## Load modules" >> ${chain}.template
    echo "module load mrbayes" >> ${chain}.template
    echo "module load openmpi_ib" >> ${chain}.template
    echo "" >> ${chain}.template

    # Setting the directory name
    echo "## Setting the HOME path" >> ${chain}.template
    echo "HOME=/${dir}/${username}" >> ${chain}.template
    echo "cd \$HOME" >> ${chain}.template
    echo "" >> ${chain}.template

    # Saving entry time
    echo "## Entry time" >> ${chain}.template
    echo "echo \"Entry time\"" >> ${chain}.template
    echo "date" >> ${chain}.template
    echo "" >> ${chain}.template

    echo "## Run the script" >> ${chain}.template
    echo "mpiexec -np ${CPU} mb TEMPLATE.mbcmd" >> ${chain}.template
    echo "" >> ${chain}.template

    echo "## Exit time" >> ${chain}.template
    echo "echo \"Exit time\"" >> ${chain}.template
    echo "date" >> ${chain}.template
    echo "" >> ${chain}.template

    ## Split the template into the multiple chain jobs
    sed 's/TEMPLATE/'"${chain}"'_norm/g' ${chain}.template > ${chain}_norm.mbjob
    sed 's/TEMPLATE/'"${chain}"'_maxi/g' ${chain}.template > ${chain}_maxi.mbjob
    sed 's/TEMPLATE/'"${chain}"'_mini/g' ${chain}.template > ${chain}_mini.mbjob
    sed 's/TEMPLATE/'"${chain}"'_rand/g' ${chain}.template > ${chain}_rand.mbjob

    ## Remove the template
    rm ${chain}.template

fi

if echo $method | grep 'PAUP' > /dev/null
then

    ## Run the first chain
    sh set.runs.sh ${chain} PAUP ${CPU} outgroup

    echo "paup ${chain}_norm.ppcmd" > ${chain}.paupjob
    echo "paup ${chain}_maxi.ppcmd" >> ${chain}.paupjob
    echo "paup ${chain}_mini.ppcmd" >> ${chain}.paupjob
    echo "paup ${chain}_rand.ppcmd" >> ${chain}.paupjob
 
fi
