## Script for making consensus tree on salvaged chains

## Input
chain=$1
tree=$2

echo "${chain}_${tree}"

## Get in the right dir
cd ${chain}/

## Check if the chains are finished
if grep -q "end;" ${chain}_${tree}.run1.t
then
    run1_finished="TRUE"
else
    run1_finished="FALSE"
    echo "Counting length in ${chain}_${tree}.run1.t..."
    run1_length=$(wc -l ${chain}_${tree}.run1.t | sed 's/'"${chain}"'_'"${tree}"'.run1.t//g' | sed 's/[[:space:]]//g')
    echo "Done."
fi

if grep -q "end;" ${chain}_${tree}.run2.t
then
    run2_finished="TRUE"
else
    run2_finished="FALSE"
    echo "Counting length in ${chain}_${tree}.run2.t..."
    run2_length=$(wc -l ${chain}_${tree}.run2.t | sed 's/'"${chain}"'_'"${tree}"'.run2.t//g' | sed 's/[[:space:]]//g')
    echo "Done."
fi

## If both chains are done, run the mb script
if [ "$run1_finished" == "TRUE" ] && [ "$run2_finished" == "TRUE" ]
then

    list=$(ls ${chain}_${tree}*)
    if echo $list | grep -q "${chain}_${tree}.mbcmd"
    then
        ## Create the <CHAIN>_<TREE> File
        cp ${chain}_${tree}.mbcmd ${chain}_${tree}
    fi

    ## Remove all the MrBayes commands and replace by sumt
    mbcmd_start=$(grep -n "begin mrbayes;" ${chain}_${tree} | sed 's/:begin mrbayes;//g')
    sed ''"$mbcmd_start"',$d' ${chain}_${tree} > tmp
    mv tmp ${chain}_${tree}
    echo "begin mrbayes;" >> ${chain}_${tree}
    echo "set autoclose=yes nowarn=yes;" >> ${chain}_${tree}
    echo "sumt;" >> ${chain}_${tree}
    echo "end;" >> ${chain}_${tree}

    ## Run the script
    mb ${chain}_${tree}

    ## Return to parent dir
    cd ..

else
    ## Count the number of lines missing in run1
    if [ "$run1_finished" == "TRUE" ]
    then
        echo "Counting length in ${chain}_${tree}.run1.t..."
        run1_length=$(wc -l ${chain}_${tree}.run1.t | sed 's/'"${chain}"'_'"${tree}"'.run1.t//g' | sed 's/[[:space:]]//g')
        echo "Done."
        let "run1_length -=1"
    fi

    if [ "$run2_finished" == "TRUE" ]
    then
        echo "Counting length in ${chain}_${tree}.run2.t..."
        run2_length=$(wc -l ${chain}_${tree}.run2.t | sed 's/'"${chain}"'_'"${tree}"'.run2.t//g' | sed 's/[[:space:]]//g')
        echo "Done."
        let "run2_length -=1"
    fi

    ## Check which chain has most trees
    if [ "$run1_length" -gt "$run2_length" ]
    then
        let "run1_length -=1"
        echo "Trimming ${chain}_${tree}.run1.t..."
        sed ''"$run2_length"','"$run1_length"'d' ${chain}_${tree}.run1.t > tmp
        mv tmp ${chain}_${tree}.run1.t
        echo "Done."
    else
        if [ "$run2_length" -gt "$run1_length" ]
        then
            let "run2_length -=1"
            echo "Trimming ${chain}_${tree}.run2.t..."
            sed ''"$run1_length"','"$run2_length"'d' ${chain}_${tree}.run2.t > tmp
            mv tmp ${chain}_${tree}.run2.t
            echo "Done."
        fi
    fi

    ## Finish the files
    if [ "$run1_finished" == "FALSE" ]
    then
        echo "end;" >> ${chain}_${tree}.run1.t
    fi
    if [ "$run2_finished" == "FALSE" ]
    then
        echo "end;" >> ${chain}_${tree}.run2.t
    fi

    ## Remove all the MrBayes commands and replace by sumt
    mbcmd_start=$(grep -n "begin mrbayes;" ${chain}_${tree} | sed 's/:begin mrbayes;//g')
    sed ''"$mbcmd_start"',$d' ${chain}_${tree} > tmp
    mv tmp ${chain}_${tree}
    echo "begin mrbayes;" >> ${chain}_${tree}
    echo "set autoclose=yes nowarn=yes;" >> ${chain}_${tree}
    echo "sumt;" >> ${chain}_${tree}
    echo "end;" >> ${chain}_${tree}

    ## Run the script
    mb ${chain}_${tree}

    ## Return to parent dir
    cd ..
    
fi