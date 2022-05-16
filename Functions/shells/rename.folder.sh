## 25t_100c_0001 to 25t_100c_0009
for ((ID=3256223, num=1; ID<=3256242, num<=9; ID++, num++))
do
    echo 000${num}
    mv 25t_100c_0001_${ID}.cx1b 25t_100c_000${num}_${ID}.cx1b
done

## 25t_100c_0010 to 25t_100c_0020
for ((ID=3256232, num=10; ID<=3256242, num<=20; ID++, num++))
do
    echo 00${num}
    mv 25t_100c_0001_${ID}.cx1b 25t_100c_00${num}_${ID}.cx1b
done

## 25t_350c_0051 to 25t_350c_0070
for ((ID=3256243, num=51; ID<=3256262, num<=70; ID++, num++))
do
    echo 00${num}
    mv 25t_100c_0001_${ID}.cx1b 25t_350c_00${num}_${ID}.cx1b
done

## 25t_1000c_0101 to 25t_1000c_0120
for ((ID=3256203, num=101; ID<=3256222, num<=120; ID++, num++))
do
    echo 0${num}
    mv 25t_100c_0001_${ID}.cx1b 25t_1000c_0${num}_${ID}.cx1b
done



## 75t_100c_0151 to 75t_100c_0170
for ((ID=3256285, num=151; ID<=3256304, num<=170; ID++, num++))
do
    echo 0${num}
    mv 25t_100c_0001_${ID}.cx1b 75t_100c_0${num}_${ID}.cx1b
done

## 75t_350c_0201 to 75t_350c_0220
for ((ID=3256305, num=201; ID<=3256324, num<=220; ID++, num++))
do
    echo 0${num}
    mv 25t_100c_0001_${ID}.cx1b 75t_350c_0${num}_${ID}.cx1b
done

## 75t_1000c_0251 to 75t_1000c_0270
for ((ID=3256263, num=251; ID<=3256282, num<=270; ID++, num++))
do
    echo 0${num}
    mv 25t_100c_0001_${ID}.cx1b 75t_1000c_0${num}_${ID}.cx1b
done



## 150t_100c_0301 to 150t_100c_0320
for ((ID=3256163, num=301; ID<=3256182, num<=320; ID++, num++))
do
    echo 0${num}
    mv 25t_100c_0001_${ID}.cx1b 150t_100c_0${num}_${ID}.cx1b
done

## 150t_350c_0351 to 150t_350c_0370
for ((ID=3256183, num=351; ID<=3256202, num<=370; ID++, num++))
do
    echo 0${num}
    mv 25t_100c_0001_${ID}.cx1b 150t_350c_0${num}_${ID}.cx1b
done

# ## 150t_1000c_0251 to 150t_1000c_0270
# for ((ID=3256263, num=251; ID<=3256282, num<=270; ID++, num++))
# do
#     echo 0${num}
#     mv 25t_100c_0001_${ID}.cx1b 150t_1000c_0${num}_${ID}.cx1b
# done



## Modifying core numbers within text
for file in *.mbjob*
do
    sed -i -e 's/_norm.mbcmd/_norm.mbcmd; echo "norm time out"; \date/g' ${file}
    sed -i -e 's/_maxi.mbcmd/_norm.mbcmd; echo "maxi time out"; \date/g' ${file}
    sed -i -e 's/_mini.mbcmd/_norm.mbcmd; echo "mini time out"; \date/g' ${file}
    sed -i -e 's/_rand.mbcmd/_norm.mbcmd; echo "rand time out"; \date/g' ${file}
done

## Modifying the file name saving
# for file in *.mbjob
# do
#     prefix=$(basename ${file} .mbjob)
#     # echo ${prefix}
#     sed -i -e 's/25t_100c_0001_$PBS_JOBID/'"${prefix}"'_$PBS_JOBID/g' ${file}
# done

## Modifying the run time
# for file in 150t_1000c_*.mbjob
# do
#     prefix=$(basename ${file} .mbjob)
#     # echo ${prefix}
#     sed -i -e 's/walltime=48:00:00/walltime=120:00:00/g' ${file}
# done



## Rerunning
# for ((num=362; num<=363; num++))
# do
#     sh rerun.missing.sh 150t_350c_0${num} 3
# done

