## Script for reading the results of a job and displaying the CPU time

for job in *.o*
do
    ## Get the job name
    job_name=$(echo ${job} | sed 's/\..*//g')
    echo ${job_name}

    ## Get the starting time
    time_entry=$(grep -n 'Entry time' ${job} | sed 's/:Entry time//g')
    let "time_entry += 1"
    time_entry=$(sed -n ''"${time_entry}"'p' ${job})
    time_entry=$(date -j -u -f "%a %d %b %T %Z %Y" "${time_entry}" "+%s")

    ## Check if the job succeeded
    runs_done=$(grep -c "Analysis completed." ${job})

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
        echo 'scale=5 ; '"${time_run}"'/3600*12' | bc
        echo ""
    else

        ## Get the number of success
        success=$(grep "time out" ${job} | wc -l | sed 's/[[:space:]]//g')

        ## Get the number of fails
        fails=$(grep "aborted" ${job} | wc -l | sed 's/[[:space:]]//g')

        ## Print the results
        if [ $fails -ne 0 ]
        then
            echo "ABORTED JOBS"
            aborted=$(grep "aborted" ${job} | head -1)
            echo $aborted
            ## Get the abortion date out
            time_out=$(grep -n "${aborted}" ${job} | sed 's/:'"${aborted}"'//g')
        else
            echo "JOB-BIS SUCCESFUL"
            grep "time out" ${job}

            terminate=$(grep "rand time out" ${job})
            if [ -n "$terminate" ]
            then
                time_out=$(grep -n "${terminate}" ${job} | sed 's/:'"${terminate}"'//g')
            else
                terminate=$(grep "mini time out" ${job})
                if [ -n "$terminate" ]
                then
                    time_out=$(grep -n "${terminate}" ${job} | sed 's/:'"${terminate}"'//g')
                else
                    terminate=$(grep "maxi time out" ${job})
                    if [ -n "$terminate" ]
                    then
                        time_out=$(grep -n "${terminate}" ${job} | sed 's/:'"${terminate}"'//g')
                    else
                        terminate=$(grep "maxi time out" ${job})
                        if [ -n "$terminate" ]
                        then
                            time_out=$(grep -n "${terminate}" ${job} | sed 's/:'"${terminate}"'//g')
                        fi
                    fi
                fi
            fi
        fi

        let "time_out += 1"
        time_out=$(sed -n ''"${time_out}"'p' ${job})
        time_out=$(date -j -u -f "%a %d %b %T %Z %Y" "${time_out}" "+%s")
        time_run=$(echo $((time_out-time_entry)))
        echo "CPU time:"
        echo 'scale=5 ; '"${time_run}"'/3600*12' | bc
        ## Check convergence
        unconverge=$(grep 'MrBayes suspects that your runs have not converged because the tree' ${job} | wc -l | sed 's/[[:space:]]//g')
        if [ $unconverge -ne 0 ]
        then
            echo "Warning: $unconverge runs did not converge!"
        fi
        echo ""
    fi
done