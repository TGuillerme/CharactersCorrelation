## Script for moving the data_in into data_out

## Input
jobname=$1
user=$2
usessh=$3


## Setting the paths
FROMUSER="${user}@awoonga.qriscloud.org.au"
FROMPATH="/90days/${user}"
JOBPATH="/Users/TGuillerme/Projects/CharactersCorrelation/Cluster/Bayesian/Jobs_in/Done"

# ## Check if jobs is runnable
# if echo $usessh | grep "yes" > /dev/null
# then
#     checkjobexist=$(ssh ${FROMUSER} ls /home/${user}/)
#     if echo $checkjobexist | grep ${jobname} > /dev/null
#     then

#         ## Is not runnable, do the mv on the cluster first
#         echo "move to ${jobname} to 30days on the cluster"
#         echo "    mv ${jobname}* /30days/${user}/"
#     fi
# fi

## Modify the job file
sed 's/mpiexec -np 12 mb \$HOME\/CharSim\//mpiexec -np 12 mb \/30days\/'"${user}"'\//' ${JOBPATH}/${jobname}.mbjob > mbjob.tmp
sed 's/mv \$HOME/#mv \$HOME/' mbjob.tmp > ${JOBPATH}/${jobname}.mbjob
rm mbjob.tmp

## Modify the command file
sed 's/mcmc nruns=2/mcmc append=yes nruns=2/' ${JOBPATH}/${jobname}.mbcmd > mbcmd.tmp
mv mbcmd.tmp ${JOBPATH}/${jobname}.mbcmd

## Rerun command
if echo $usessh | grep "yes" > /dev/null
then
    scp ${JOBPATH}/${jobname}.mb* ${FROMUSER}:${FROMPATH}
    echo "To rerun ${jobname}:"
    echo "    qsub /30days/${user}/${jobname}.mbjob"
else
    echo "To rerun ${jobname}:"
    echo "Copy ${jobname}.mbcmd and ${jobname}.mbjob to CLUSTER:/30days/${user}/"
    echo "then:"
    echo "    qsub /30days/${user}/${jobname}.mbjob"

fi








if echo ${tail_end} | grep -q "end;"


## Downloading the jobs out
scp ${FROMUSER}:${FROMPATH}/CharSim/*.o* ${JOBSOUT}

## Getting the chain name
for file in ${JOBSOUT}*.o*
do
    chaintmp=$(echo ${file} | sed 's/.mbcmd.o[0-9]*//')
    chain=$(echo ${chaintmp} | sed 's/\/Users\/TGuillerme\/Projects\/CharactersCorrelation\/Cluster\/Bayesian\/Jobs_out\///')
    ## Copying the files
    echo ${chain}
    scp ${FROMUSER}:${FROMPATH}${chain}* ${DATAOUT}
done

## Cleaning
#for f in *.con.tre ; do chain=$(basename $f .con.tre); echo $chain ; srm ${chain}* ; echo " cleaned" ; done


# scp Users/TGuillerme/Projects/CharactersCorrelation/Cluster/Bayesian/Jobs_out/Done/75t_1000c_0111_rand uqapasto@awoonga.qriscloud.org.au:/home/uqapasto/CharSim/