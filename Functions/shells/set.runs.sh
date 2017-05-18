#!/bin/sh

##########################
#Shell script for setting up the MrBayes and/or PAUP* scripts
##########################
#SYNTAX:
#sh set.runs.sh <chain_name> <method> <CPU> <outgroup>
#with:
#<chain_name> the path to the matrices chain to be run.
#<method> either "PAUP", "MrBayes" or "both".
#<CPU> number of CPUs available.
#<outgroup> optional outgroup.
##########################
#----
#guillert(at)tcd.ie - 2016/11/17
##########################

## Step 1 - INPUT

## Input values
chain_name=$1
method=$2
CPU=$3
outgroup=$4

## Set up the methods
if echo $method | grep 'both' > /dev/null
then
    method="MrBayesPAUP"
fi

## Get the CPU numbers
# if echo $CPU | grep '1'
# then
#     runs=1
#     chains=2
# else
#     runs=2
#     chains=$(echo "$CPU / 2" | bc | sed 's/\.[0-9]*//g')
# fi

## Step 2 - SET UP MRBAYES

if echo $method | grep 'MrBayes' > /dev/null
then

    ## Set up the MCMC parameters (default)
    Generations=1000000000
    sampling=200
    printing=2000
    diagnosi=10000
    
    ## Copying the three matrices
    cat ${chain_name}_norm.nex > ${chain_name}_norm.mbcmd
    cat ${chain_name}_maxi.nex > ${chain_name}_maxi.mbcmd
    cat ${chain_name}_mini.nex > ${chain_name}_mini.mbcmd
    cat ${chain_name}_rand.nex > ${chain_name}_rand.mbcmd
    
    ## Creating the MrBayes command template
    echo "" > base_mbcmd.tmp
    echo "" >> base_mbcmd.tmp
    echo "begin mrbayes;" >> base_mbcmd.tmp
    echo "[Data input]" >> base_mbcmd.tmp
    echo "set autoclose=yes nowarn=yes;" >> base_mbcmd.tmp
    echo "log start filename=<CHAIN>.log;" >> base_mbcmd.tmp
    #echo "execute <CHAIN>.nex;" >> base_mbcmd.tmp
    echo "" >> base_mbcmd.tmp

    echo "[Model settings]" >> base_mbcmd.tmp
    if [ -n "$outgroup" ]
    then
        echo "outgroup $outgroup ;" >> base_mbcmd.tmp
    fi
    echo "lset nst=1 rates=gamma Ngammacat=4;" >> base_mbcmd.tmp  # Model setting (Mk Gamma4)??
    echo "prset ratepr=variable Shapepr=Exponential(0.5);" >> base_mbcmd.tmp
    echo "" >> base_mbcmd.tmp

    echo "[MCMC settings]" >> base_mbcmd.tmp
    #echo "startvals tau=Start_tree V=Start_tree ;" >> base_mbcmd.tmp     # Prior on the topology??
    echo "mcmc nruns=2 Nchains=6 ngen=${Generations} samplefreq=${sampling} printfreq=${printing} diagnfreq=${diagnosi} Stoprule=YES stopval=0.01 mcmcdiagn=YES file=<CHAIN>;" >> base_mbcmd.tmp
    echo "sump Filename=<CHAIN> Relburnin=YES Burninfrac=0.25;" >> base_mbcmd.tmp
    echo "sumt Filename=<CHAIN> Relburnin=YES Burninfrac=0.25;" >> base_mbcmd.tmp
    echo "end;" >> base_mbcmd.tmp

    ## Copying the commands to the matrices
    cat base_mbcmd.tmp | sed 's/<CHAIN>/'"${chain_name}"'_norm/g' >> ${chain_name}_norm.mbcmd
    cat base_mbcmd.tmp | sed 's/<CHAIN>/'"${chain_name}"'_maxi/g' >> ${chain_name}_maxi.mbcmd
    cat base_mbcmd.tmp | sed 's/<CHAIN>/'"${chain_name}"'_mini/g' >> ${chain_name}_mini.mbcmd
    cat base_mbcmd.tmp | sed 's/<CHAIN>/'"${chain_name}"'_rand/g' >> ${chain_name}_rand.mbcmd

    ## Remove the command template
    rm base_mbcmd.tmp

    ## Be verbose
    echo "Generated the matrix MrBayes commands:"
    echo "mb ${chain_name}_norm.mbcmd"
    echo "mb ${chain_name}_maxi.mbcmd"
    echo "mb ${chain_name}_mini.mbcmd"
    echo "mb ${chain_name}_rand.mbcmd"
fi

if echo $method | grep 'PAUP' > /dev/null
then
    
    ## Copying the three matrices and adding the symbols
    cat ${chain_name}_norm.nex > ${chain_name}_norm.ppcmd
    cat ${chain_name}_maxi.nex > ${chain_name}_maxi.ppcmd
    cat ${chain_name}_mini.nex > ${chain_name}_mini.ppcmd
    cat ${chain_name}_rand.nex > ${chain_name}_rand.ppcmd
    
    ## Creating the MrBayes command template
    echo "" > base_ppcmd.tmp
    echo "" >> base_ppcmd.tmp
    echo "begin paup;" >> base_ppcmd.tmp
    echo "[Data input]" >> base_ppcmd.tmp
    echo "set autoclose=yes warntree=no warnreset=no;" >> base_ppcmd.tmp
    echo "log start file=<CHAIN>.log replace;" >> base_ppcmd.tmp
    echo "execute <CHAIN>.nex;" >> base_ppcmd.tmp

    if [ -n "$outgroup" ]
    then
        echo "[Model settings]" >> base_ppcmd.tmp
        echo "outgroup $outgroup;" >> base_ppcmd.tmp
        echo "set maxtrees=500 increase=auto autoInc=500;" >> base_ppcmd.tmp
    else
        echo "[Model settings]" >> base_ppcmd.tmp
        echo "set maxtrees=500 increase=auto autoInc=500;" >> base_ppcmd.tmp
    fi

    echo "" >> base_ppcmd.tmp
    echo "[Parsimony search]" >> base_ppcmd.tmp
    echo "hsearch addseq=random nreps=500 rseed=01234 rearrlimit=5000000 limitperrep=yes;" >> base_ppcmd.tmp
    # echo "bootstrap bseed=12345 nreps=100 ConLevel=50 KeepAll=yes TreeFile = <CHAIN>.bs;" >> base_ppcmd.tmp


    echo "" >> base_ppcmd.tmp
    echo "[Summarize search]" >> base_ppcmd.tmp
    if [ -n "$outgroup" ]
    then
        echo "savetrees /file=<CHAIN>.tre root replace;" >> base_ppcmd.tmp
    else
        echo "savetrees /file=<CHAIN>.tre replace;" >> base_ppcmd.tmp
    fi
    echo "contree /majrule cutoff=50 file=<CHAIN>.contre replace;" >> base_ppcmd.tmp
    echo "q;" >> base_ppcmd.tmp
    echo "end;" >> base_ppcmd.tmp

    ## Copying the commands to the matrices
    cat base_ppcmd.tmp | sed 's/<CHAIN>/'"${chain_name}"'_norm/g' >> ${chain_name}_norm.ppcmd
    cat base_ppcmd.tmp | sed 's/<CHAIN>/'"${chain_name}"'_maxi/g' >> ${chain_name}_maxi.ppcmd
    cat base_ppcmd.tmp | sed 's/<CHAIN>/'"${chain_name}"'_mini/g' >> ${chain_name}_mini.ppcmd
    cat base_ppcmd.tmp | sed 's/<CHAIN>/'"${chain_name}"'_rand/g' >> ${chain_name}_rand.ppcmd

    ## Remove the command template
    rm base_ppcmd.tmp

    ## Be verbose
    echo "Generated the matrix PAUP commands:"
    echo "paup ${chain_name}_norm.ppcmd"
    echo "paup ${chain_name}_maxi.ppcmd"
    echo "paup ${chain_name}_mini.ppcmd"
    echo "paup ${chain_name}_rand.ppcmd"

fi
