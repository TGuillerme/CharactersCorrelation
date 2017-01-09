## Merging the _bis_ files with the original folders
for jobbis in *_bis_*
do
    ## Get the job name and the target name
    job_name=$(echo ${jobbis} | sed 's/_bis_.*//g')
    target_name=$(echo ${job_name}_*.cx1b | sed 's/'"${job_name}"'_bis_.*.cx1b//g' | sed 's/ //g')

    echo "Merging ${job_name}"

    ## Select the right files in the right folder
    for files in ${jobbis}/${job_name}*
    do
        mv ${files} ${target_name}/
        printf "."
    done

    echo "Done."
done