#!/bin/bash

#In some instances empty files happen for speeds too, ie 0_100_1.000_0.000_0.000_0.000_0.000_0.000_0.000_0_0.990_0.000_9 
#The new .r code for ./speedsOfMitochondriaForVidsForIntervals-AllIntervals.R reads in the 'Speedofallmitosinframe...csv'
#Sometimes these are empty, particularly in the slowest sims. So will fill with NAs for reading. 
for i in $(seq 0 $6); do

if grep -q "mitochondria" "$1/$2/all_speeds/Speedofallmitosinframe${i}.csv"; then
  echo "String found here" ; # SomeString was found 
else echo "NA" > $1/$2/all_speeds/Speedofallmitosinframe${i}.csv ;
#else echo "empty" ;

fi

done
