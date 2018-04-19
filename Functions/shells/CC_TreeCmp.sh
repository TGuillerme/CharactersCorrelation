##########################
# Script for using TreeCmp between trees for Character Correlation
##########################
#SYNTAX: sh CC_TreeCmp -c <chain> -r <ref> -o <output> -f <treeformat> -d <draws> -r <rooted>
#with:
#-c <chain> the name of the chain
#-r <ref> the reference tree number (1 = normal, 2 = maximum, 3 = minimum, 4 = null)
#-o <output> OPTIONAL the output name (if missing, is set to <chain>)
#-f <treeformat> OPTIONAL the tree in and out format (if missing, is set to '.nex')
#-d <draws> OPTIONAL the number of draws for the comparison (if missing, is set to '1000')
#-r <rooted> OPTIONAL logical, whether to consider the tree as rooted or not (if missing, is set to 'TRUE')
##########################
#guillert(at)tcd.ie - 2017/01/09
##########################
#Requirements:
#-R 3.x
#-TreeCmp java script (Bogdanowicz et al 2012)
#-http://www.la-press.com/treecmp-comparison-of-trees-in-polynomial-time-article-a3300
#-TreeCmp folder to be installed at the level of the analysis
##########################

#INPUT

## Input values
while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -c|--chain)
        CHAIN="$2"
        shift
        ;;
    -r|--ref)
        REF="$2"
        shift
        ;;
    -o|--output)
        OUTPUT="$2"
        shift
        ;;
    -f|--format)
        FORMAT="$2"
        shift
        ;;
    -d|--draws)
        DRAWS="$2"
        shift
        ;;
    -t|--true)
        TRUE="$2"
        shift
        ;;
    -r|--rooted)
        ROOTED="$2"
        ;;
        *)

        ;;
esac
shift
done

## Set default arguments
if [ "$CHAIN" == "" ]
then
    echo "ERROR: --chain is missing!"
    exit
fi

if [ "$REF" == "" ]
then
    REF=1
fi

if [ "$OUTPUT" == "" ]
then
    OUTPUT=${CHAIN}
fi

if [ "$FORMAT" == "" ]
then
    FORMAT="nexus"
else
    if [ "$FORMAT" != "nexus" ]
    then
        if [ "$FORMAT" != "newick" ]
        then
            echo "ERROR: --format must be 'nexus' or 'newick'!"
            exit
        fi
    fi
fi

if [ "$DRAWS" == "" ]
then
    DRAWS=1
fi

if [ "$ROOTED" == "" ]
then
    ROOTED="TRUE"
else
    if [ "$ROOTED" != "TRUE" ]
    then
        if [ "$ROOTED" != "FALSE" ]
        then
            echo "ERROR: --rooted must be 'TRUE' or 'FALSE'!"
            exit
        fi
    fi
fi

if [ "$TRUE" == "" ]
then
    TRUE="TRUE"
else
    if [ "$TRUE" != "TRUE" ]
    then
        if [ "$TRUE" != "FALSE" ]
        then
            echo "ERROR: --true must be 'TRUE' or 'FALSE'!"
            exit
        fi
    fi
fi


# ##DEBUG
# echo "chain name = ${CHAIN}"
# echo "output name = ${OUTPUT}"
# echo "format out = ${FORMAT}"
# echo "draws num? = ${DRAWS}"
# echo "use root? = ${ROOTED}"

## Set up the metrics
if [ "$ROOTED" == "TRUE" ]
then
    #Rooted metrics
    metrics="mc rc ns tt" #Matching Cluster / Robinson-Foulds (based on cluster) / Nodal Split / Triples
    root="\[\&R\]"
else
    #Unrooted metrics
    metrics="ms rf pd qt" #Matching Split / Robinson-Foulds / Path difference / Quartet 
    root="\[\&U\]"
fi

## Get the Chain folder name
if [ "$REF" == 1 ]
then
    chain_folder=$(echo $CHAIN | sed 's/c_.*/c_cmp_norm/g')
fi
if [ "$REF" == 2 ]
then
    chain_folder=$(echo $CHAIN | sed 's/c_.*/c_cmp_maxi/g')
fi
if [ "$REF" == 3 ]
then
    chain_folder=$(echo $CHAIN | sed 's/c_.*/c_cmp_mini/g')
fi
if [ "$REF" == 4 ]
then
    chain_folder=$(echo $CHAIN | sed 's/c_.*/c_cmp_rand/g')
fi


## Create the folder if needed
if ls | grep ${chain_folder} > /dev/null
then
    silent="silent"
else 
    mkdir ${chain_folder}
fi

## PREPARING THE COMPARISON FILES
if [ "$DRAWS" == 1 ]
then
    ## Creating a temporary input file containing the trees
    if [ "$FORMAT" == "nexus" ]
    then
        ## Convert output to newick
        sh Nex2New.sh ${CHAIN} "newick"

        ## Save the three trees in a same file
        
        if [ "$REF" == 1 ]
        then
            cat ${CHAIN}_norm.con.tre.newick > ${CHAIN}_ref.tre
        fi
        if [ "$REF" == 2 ]
        then
            cat ${CHAIN}_maxi.con.tre.newick > ${CHAIN}_ref.tre
        fi
        if [ "$REF" == 3 ]
        then
            cat ${CHAIN}_mini.con.tre.newick > ${CHAIN}_ref.tre
        fi
        if [ "$REF" == 4 ]
        then
            cat ${CHAIN}_rand.con.tre.newick > ${CHAIN}_ref.tre
        fi

        cat ${CHAIN}_norm.con.tre.newick > ${CHAIN}_comb.con.tre
        cat ${CHAIN}_maxi.con.tre.newick >> ${CHAIN}_comb.con.tre
        cat ${CHAIN}_mini.con.tre.newick >> ${CHAIN}_comb.con.tre
        cat ${CHAIN}_rand.con.tre.newick >> ${CHAIN}_comb.con.tre
        if [ "$TRUE" == "TRUE" ]
        then
            cat ${CHAIN}_truetree.nex.newick >> ${CHAIN}_comb.con.tre
        fi
        ## If true tree = TRUE
        rm ${CHAIN}_*.newick


        ## Change the eventual root
        sed -i -e 's/\[\&U\]/'"${root}"'/g' ${CHAIN}_comb.con.tre ; rm ${CHAIN}_comb.con.tre-e
    else
        ## Save the three trees in a same file
        
        if [ "$REF" == 1 ]
        then
            cat ${CHAIN}_norm.con.tre > ${CHAIN}_ref.tre
        fi
        if [ "$REF" == 2 ]
        then
            cat ${CHAIN}_maxi.con.tre > ${CHAIN}_ref.tre
        fi
        if [ "$REF" == 3 ]
        then
            cat ${CHAIN}_mini.con.tre > ${CHAIN}_ref.tre
        fi
        if [ "$REF" == 4 ]
        then
            cat ${CHAIN}_rand.con.tre > ${CHAIN}_ref.tre
        fi
        
        cat ${CHAIN}_norm.con.tre > ${CHAIN}_comb.con.tre
        cat ${CHAIN}_maxi.con.tre >> ${CHAIN}_comb.con.tre
        cat ${CHAIN}_mini.con.tre >> ${CHAIN}_comb.con.tre
        cat ${CHAIN}_rand.con.tre >> ${CHAIN}_comb.con.tre
        if [ "$TRUE" == "TRUE"]
        then
            cat ${CHAIN}_truetree.tre >> ${CHAIN}_comb.con.tre
        fi
        ## Change the eventual root
        sed -i -e 's/\[\&U\]/'"${root}"'/g' ${CHAIN}_comb.con.tre ; rm ${CHAIN}_comb.con.tre-e
    fi

fi

## RUNNING THE COMPARISONS
if [ "$DRAWS" == 1 ]
then
    echo "Comparing trees:"
    ## Run the tree comparison for draw = 1
    java -jar TreeCmp/bin/TreeCmp.jar -r ${CHAIN}_ref.tre -d ${metrics} -i ${CHAIN}_comb.con.tre -o ${chain_folder}/${OUTPUT}.con.tre.Cmp > /dev/null
    rm ${CHAIN}_ref.tre ; rm ${CHAIN}_comb.con.tre
    printf "."
    echo "Done."
fi
