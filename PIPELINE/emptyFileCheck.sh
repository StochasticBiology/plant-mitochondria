#!/bin/bash

#This is added just incase 199 has an empty file, the count would otherwise only go up to 198- it will error if 199 remians empty
#however, the experimental results don't have this overhang file, so just be careful- only use when file running with ./associationTime.r
#errors due to not being able to read at associationCounts -> read.csv -> read.table
#c=`echo $6 + 1 | bc`
#echo "$c"
#for i in $(seq 0 $c); do

#IF IT'S NOT RUNNING AND HAS AN EMPTY 199 FRAME-spec, LOOK ABOVE ^^^^
##for i in $(seq 0 $6); do

#echo note that empty check runs through -spoec.txt files in main directory, but changes occuring in the historicalAndNewPairs directory
##echo ${i}
##if [[ -s $1/$2/$3-1.6-${i}-spec.txt ]]; then echo "file has something"; else echo "NA NA" > $1/$2/historicalAndNewPairs/$3-1.6-${i}-spec.txt; fi

##done



#In some instances this happens for speeds too, ie 0_100_1.000_0.000_0.000_0.000_0.000_0.000_0.000_0_0.990_0.000_9 
#The new .r code for ./speedsOfMitochondriaForVidsForIntervals-AllIntervals.R reads in the 'Speedofallmitosinframe...csv'
#Sometimes these are empty, particularly in the slowest sims. So will fill with NAs for reading. 
for i in $(seq 0 $6); do

if grep -q "mitochondria" "$1$2/all_speeds/Speedofallmitosinframe${i}.csv"; then
  echo "String found here" ; # SomeString was found 
else echo "NA" > $1/$2/all_speeds/Speedofallmitosinframe${i}.csv ;
#else echo "empty" ;

fi

done


