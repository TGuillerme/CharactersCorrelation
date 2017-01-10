##########################
# Script for using TreeCmp between trees for Character Correlation
##########################
#SYNTAX: TreeCmp -c <chain> -o <output> -f <treeformat> -d <draws> -r <rooted>
#with:
#-c <chain> the name of the chain
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
chain_folder=$(echo $CHAIN | sed 's/c_.*/c_cmp/g')

## Create the folder if needed
if ls -d | grep ${chain_folder} > /dev/null
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
        cat ${CHAIN}_norm.con.tre.newick > ${CHAIN}_ref.tre
        cat ${CHAIN}_maxi.con.tre.newick > ${CHAIN}_comb.con.tre
        cat ${CHAIN}_mini.con.tre.newick >> ${CHAIN}_comb.con.tre
        cat ${CHAIN}_rand.con.tre.newick >> ${CHAIN}_comb.con.tre
        rm ${CHAIN}_*.newick
        ## Change the eventual root
        sed -i -e 's/\[\&U\]/'"${root}"'/g' ${CHAIN}_comb.con.tre ; rm ${CHAIN}_comb.con.tre-e
    else
        ## Save the three trees in a same file
        cat ${CHAIN}_norm.con.tre > ${CHAIN}_ref.tre
        cat ${CHAIN}_maxi.con.tre > ${CHAIN}_comb.con.tre
        cat ${CHAIN}_mini.con.tre >> ${CHAIN}_comb.con.tre
        cat ${CHAIN}_rand.con.tre >> ${CHAIN}_comb.con.tre
        ## Change the eventual root
        sed -i -e 's/\[\&U\]/'"${root}"'/g' ${CHAIN}_comb.con.tre ; rm ${CHAIN}_comb.con.tre-e
    fi

# else
#     ## Prepare the comparison files (draws)

fi

#     #Is the input tree a chain?
#     if grep '1 file(s)' TreeCmp_settings.tmp >/dev/null
#     then
#         echo $INPtree > ${output}_tmp/treenames.list

#         #Counting the number of trees available
#         if grep 'newick trees' TreeCmp_settings.tmp > /dev/null
#         then
#             #Number of newick trees per files
#             REFntrees=$(cat $REFtree | wc -l)
#             INPntrees=$(cat $INPtree | wc -l)
#         else
#             #Number of nexus trees per files
#             REFntrees=$(grep "[[:space:]]TREE[[:space:]]\|[[:space:]]Tree[[:space:]]\|[[:space:]]tree[[:space:]]" $REFtree | wc -l)
#             INPntrees=$(grep "[[:space:]]TREE[[:space:]]\|[[:space:]]Tree[[:space:]]\|[[:space:]]tree[[:space:]]" $INPtree | wc -l)
#         fi

#         #Creating the random draw list
#         echo "if($REFntrees < $draws) {
#                 REFrep=TRUE } else {
#                 REFrep=FALSE}
#             if($INPntrees < $draws) {
#                 INPrep=TRUE } else {
#                 INPrep=FALSE }
#             #Saves the list of trees to sample in the REF and INP files    
#             write(sample(seq(1:$REFntrees), $draws, replace=REFrep), file=\"${output}_tmp/REFtree.sample\", ncolumns=1)
#             write(sample(seq(1:$INPntrees), $draws, replace=INPrep), file=\"${output}_tmp/INPtree.sample\", ncolumns=1) " | R --no-save >/dev/null
       
#     else
#         echo "A single tree file must be given if the number of draws is > 1."
#         echo "The single tree file can however contain multiple trees."
#         rm TreeCmp_settings.tmp
#         rm -R ${output}_tmp/
#         exit
#     fi



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
# else 

#     ## Run the tree comparison for draw > 1

# fi
#     #More than one draw, comparison is in treeset method
#     echo "Comparing the trees $draws times"
#     for n in $(seq -w 1 $draws)
#     do
#         #Extracting the trees from the random draw list
#         i=$(sed -n ''"${n}p"'' ${output}_tmp/REFtree.sample)
#         j=$(sed -n ''"${n}p"'' ${output}_tmp/INPtree.sample)
#         if grep 'newick trees' TreeCmp_settings.tmp > /dev/null
#         then
#             #Newick trees
#             sed -n ''"${i}p"'' $REFtree > ${output}_tmp/REF.tre
#             sed -n ''"${j}p"'' $INPtree > ${output}_tmp/INP.tre
#         else
#             #Nexus trees
#             ENDheaderREF=$(grep -n "[[:space:]]TREE[[:space:]]\|[[:space:]]Tree[[:space:]]\|[[:space:]]tree[[:space:]]" $REFtree | cut -f1 -d: | sed -n '1p')
#             ENDheaderINP=$(grep -n "[[:space:]]TREE[[:space:]]\|[[:space:]]Tree[[:space:]]\|[[:space:]]tree[[:space:]]" $INPtree | cut -f1 -d: | sed -n '1p')
#             let "ENDheaderREF -= 1"
#             let "ENDheaderINP -= 1"
#             inexus=$i
#             jnexus=$j
#             let "inexus += $ENDheaderREF"
#             let "jnexus += $ENDheaderINP"
#             sed -n '1,'"$ENDheaderREF"'p' $REFtree > ${output}_tmp/REF.tre
#             #echo ";" >> ${output}_tmp/REF.tre
#             sed -n ''"${inexus}p"'' $REFtree >> ${output}_tmp/REF.tre
#             echo "END;" >> ${output}_tmp/REF.tre
#             sed -n '1,'"$ENDheaderINP"'p' $INPtree > ${output}_tmp/INP.tre
#             #echo ";" >> ${output}_tmp/INP.tre
#             sed -n ''"${jnexus}p"'' $INPtree >> ${output}_tmp/INP.tre
#             echo "END;" >> ${output}_tmp/INP.tre
#         fi

#         #Comparing the trees
#         java -jar TreeCmp/bin/TreeCmp.jar -r ${output}_tmp/REF.tre -d ${metrics} -i ${output}_tmp/INP.tre -o ${output}_tmp/Cmp.${n}.tmp > /dev/null
#         printf .

#     done
#     echo "Done"

#    java -jar TreeCmp/bin/TreeCmp.jar -r ${chain}_norm.con.trees -d ${metrics} -i ${chain}_norm.con.trees -o ${output}.Cmp > /dev/null

# fi


## MANAGING THE OUTPUT



# #BUILDING THE OUTPUT
# if grep '1 draw(s)' TreeCmp_settings.tmp >/dev/null
# then
#     echo "Renaming the output comparisons"
#     totalTrees=$(cat ${output}_tmp/treenames.list | wc -l)

#     #Testing if a Multi tree file was used
#     MultiTreeTest=$(cat ${output}_tmp/${output}.Cmp.tmp | wc -l)
#     let "MultiTreeTest -= 1"
#     #Creating the header
#     echo "Reference Tree\tTree name" > ${output}_tmp/header.tmp

#     if  echo $totalTrees | grep $MultiTreeTest > /dev/null
#     then
#         #Creating the header using the treenames.list file
#         for n in $(seq 1 $totalTrees)
#         do
#             treename=$(sed -n ''"${n}"'p' ${output}_tmp/treenames.list)
#             echo "$REFtree\t$treename"  >> ${output}_tmp/header.tmp
#             printf .
#         done
#     else
#         #Creating a new header from scratch
#         for n in $(seq 1 $MultiTreeTest)
#         do
#             treename=$(sed -n '1p' ${output}_tmp/treenames.list)
#             echo "$REFtree\t$treename.${n}"  >> ${output}_tmp/header.tmp
#             printf .
#         done
#     fi

# else
#     echo "Combining the output comparisons"
#     sed -n '1p' $(ls ${output}_tmp/Cmp.*.tmp | sed -n '1p') > ${output}_tmp/${output}.Cmp.tmp

#     #Combining the output comparisons
#     for n in $(seq -w 1 $draws)
#     do
#         sed -n '2p' ${output}_tmp/Cmp.${n}.tmp >> ${output}_tmp/${output}.Cmp.tmp
#         printf .
#     done

#     #Creating the header using the randon draws list
#     #Creating the header
#     echo "Ref.tree@Inp.tree" | sed 's/@/'"$(printf '\t')"'/g' > ${output}_tmp/header.tmp
#     paste ${output}_tmp/REFtree.sample ${output}_tmp/INPtree.sample >> ${output}_tmp/header.tmp
# fi

# #Pasting the header with the .Cmp.tmp file
# paste ${output}_tmp/header.tmp ${output}_tmp/${output}.Cmp.tmp > ${output}_tmp/${output}.Cmp.tmp2
# echo "write.table(read.table(\"${output}_tmp/${output}.Cmp.tmp2\", header=TRUE, sep='\t')[,-3], file=\"${output}_tmp/${output}.Cmp\", sep='\t', row.names=FALSE)" | R --no-save >/dev/null
# sed 's/"//g' ${output}_tmp/${output}.Cmp > ${output}.Cmp
# echo "Done"

# #CLEANING
# rm TreeCmp_settings.tmp
# rm -R ${output}_tmp/


# #end