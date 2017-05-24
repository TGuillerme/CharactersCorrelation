#!/bin/sh

##########################
#Shell script for counting run length from paup log files.
##########################
#SYNTAX:
#sh time.paup.sh <chain_name>
#with:
#<chain_name> the path to the matrices chain to be run.
##########################
#----
#guillert(at)tcd.ie - 2017/05/24
##########################

## Input values
chain_name=$1




## Loop through the chain names
for file in ${chain_name}*.log
do
    ## Get the time
    time=$(grep "Time used" $file | sed 's/(CPU time = .*)//g' | sed 's/  Time used = //g')

    ## Time format
    is_sec=$(echo $time | grep -o "sec")

    ## Count total time
    if [ "$is_sec" == "" ]
    then
        ## Time in hours
        seconds=$($time +%s)
        date -j -f '%H:%M:%S' $time '+%s'

        echo "$file"
        echo "$time"
        echo ""
    else
        ## Time in seconds
        time=$(echo $time | sed 's/sec//g' | sed 's/  /+/g')
        seconds=$(echo $time | bc | sed 's/\..*/./' | sed 's/\.//g')
        echo "$file"
        echo "00:00:0$seconds"
        echo ""
    fi
done

# CPU.hours <- function (time, cores = 1) 
# {
#     if (class(time) == "numeric") {
#         days <- time[1]
#         hours <- time[2]
#         minutes <- time[3]
#         seconds <- time[4]
#     }
#     else {

#         hours <- as.numeric(strsplit(time, split = ":")[[1]][1])
#         minutes <- as.numeric(strsplit(time, split = ":")[[1]][2])
#         seconds <- as.numeric(strsplit(time, split = ":")[[1]][3])

#     }
#     x <- (((hours * 60 + minutes) * 60 + seconds) * cores)/60/60
#     return(x)
# }