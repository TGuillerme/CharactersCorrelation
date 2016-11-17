#!/bin/sh

##########################
#Shell script for setting up the MrBayes and/or PAUP* scripts
##########################
#SYNTAX:
#sh set.runs.sh <matrix> <method> <CPU> <outgroup>
#with:
#<matrix> the path to the matrix to be run.
#<method> either "PAUP", "MrBayes" or "both".
#<CPU> number of CPUs available.
#<outgroup> optional outgroup.
##########################
#----
#guillert(at)tcd.ie - 2016/11/17
##########################

## Step 1 - INPUT

## Input values
matrix=$1
method=$2
CPU=$3
outgroup=$4

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

## Step 2 - SET UP MRBAYES

if echo $method | grep 'MrBayes' > /dev/null
then

    ## Set up the MCMC parameters (default)
    Generations=100000000
    sampling=200
    printing=2000
    diagnosi=10000
    
    ## Copying the three matrices
    cat ${chain_name}_norm.nex > ${chain_name}_norm.cmd
    cat ${chain_name}_maxi.nex > ${chain_name}_maxi.cmd
    cat ${chain_name}_mini.nex > ${chain_name}_mini.cmd
    
    ## Creating the MrBayes command template
    echo "" > base_cmd.tmp
    echo "" >> base_cmd.tmp
    echo "begin mrbayes;" >> base_cmd.tmp
    echo "[Data input]" >> base_cmd.tmp
    echo "set autoclose=yes nowarn=yes;" >> base_cmd.tmp
    echo "log start filename=<CHAIN>.log;" >> base_cmd.tmp
    echo "execute <CHAIN>.nex;" >> base_cmd.tmp
    echo "" >> base_cmd.tmp

    echo "[Model settings]" >> base_cmd.tmp
    if [ -n "$outgroup" ]
    then
        echo "outgroup $outgroup ;" >> base_cmd.tmp
    fi
    echo "lset nst=1 rates=gamma Ngammacat=4;" >> base_cmd.tmp  # Model setting (Mk Gamma4)??
    echo "prset ratepr=variable;" >> base_cmd.tmp               # Prior on the rates??
    echo "prset Shapepr=Exponential(0.5);" >> base_cmd.tmp      # Prior on the shape??
    echo "" >> base_cmd.tmp

    echo "[MCMC settings]" >> base_cmd.tmp
    #echo "startvals tau=Start_tree V=Start_tree ;" >> base_cmd.tmp     # Prior on the topology??
    echo "mcmc nruns=${runs} Nchains=${chains} ngen=${Generations} samplefreq=${sampling} printfreq=${printing} diagnfreq=${diagnosi} Stoprule=YES stopval=0.01 mcmcdiagn=YES file=<CHAIN>;" >> base_cmd.tmp
    echo "sump Filename=<CHAIN> Relburnin=YES Burninfrac=0.25;" >> base_cmd.tmp
    echo "sumt Filename=<CHAIN> Relburnin=YES Burninfrac=0.25;" >> base_cmd.tmp
    echo "end;" >> base_cmd.tmp

    ## Copying the commands to the matrices
    cat base_cmd.tmp | sed 's/<CHAIN>/'"${chain_name}"'_norm/g' >> ${chain_name}_norm.cmd
    cat base_cmd.tmp | sed 's/<CHAIN>/'"${chain_name}"'_maxi/g' >> ${chain_name}_maxi.cmd
    cat base_cmd.tmp | sed 's/<CHAIN>/'"${chain_name}"'_mini/g' >> ${chain_name}_mini.cmd

    ## Remove the command template
    rm base_cmd.tmp

    ## Be verbose
    echo "Generated the matrix MrBayes commands:"
    echo "mb ${chain_name}_norm.cmd"
    echo "mb ${chain_name}_maxi.cmd"
    echo "mb ${chain_name}_mini.cmd"
fi

if echo $method | grep 'PAUP' > /dev/null
then
    echo "PAUP will run"
fi
