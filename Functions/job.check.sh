## Script for reading the results of a job and displaying the CPU time

for job in *.o*
do
    ## Get the job name
    job_name=$(echo ${job} | sed 's/\..*//g')
    echo ${job_name}

    ## Get the starting time
    time_entry=$(grep -n 'Entry time' ${job} | sed 's/:Entry time//g')
    let "time_entry += 1" ; echo $time_entry
    time_entry=$(sed -n ''"${time_entry}"'p' ${job})
    time_entry=$(date -j -u -f "%a %d %b %T %Z %Y" "${time_entry}" "+%s")

    ## Check if the job succeeded
    runs_done=$(grep -c "Analysis stopped because convergence diagnostic hit stop value." ${job})

    ## Job done properly
    if echo $runs_done | grep '4' > /dev/null
    then
        echo "JOB DONE"
        ## CPUT time
        time_out=$(grep -n 'Exit time' ${job} | sed 's/:Exit time//g')
        let "time_out += 1"
        time_out=$(sed -n ''"${time_out}"'p' ${job})
        time_out=$(date -j -u -f "%a %d %b %T %Z %Y" "${time_out}" "+%s")
        time_run=$(echo $((time_out-time_entry)))
        echo "CPU time:"
        echo 'scale=5 ; '"${time_run}"'/3600*8' | bc
    else
        ## Get the number of chains missing
        runs_missing=4
        let "runs_missing -= ${runs_done}"
        echo "JOB ABORTED"
        echo "Missing the last ${runs_missing} runs."
    fi
    echo ""
done