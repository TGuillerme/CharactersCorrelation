## Script for moving the data_in into data_out

for f in *.con.tre
do
    chain=$(basename $f .con.tre)
    echo $chain

    ## Check if the con.tre is not empty
    if tail -1 ${chain}.con.tre | grep 'end;' > /dev/null
    then
        
        ## Make the new folder (checks if the directory exists)
        mkdir -p Done/${chain}

        ## Move to the finished chains
        mv ${chain}* Done/${chain}/

    else
        echo "$chain.con.tre does not contain a proper tree"
    fi

    ## Copy the jobs
    # cp ../Jobs_in/${chain}* Done/${chain}
    # mv ../Jobs_in/${chain}* ../Jobs_in/Done/
done
