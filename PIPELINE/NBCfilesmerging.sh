#!/bin/bash

cd ${1}/${2}

#need to remove any previous one or it will keep adding new runs to the same file 
rm ${2}_mergedNBCfile.csv
rm ${2}_mergedMaxNBCfile.csv
rm ${2}_mergedMeanNBCfile.csv
echo "Dont worry about this error if it's the first time running this data ^^"

#Loop through all frame numbers
for i in $(seq 1 ${3}); do 

#paste list of normalised BCs into a new file as one long line with comma seperation
paste -s -d, ${i}_normalisedBC.csv >> ${i}NBC.csv

#paste all of the different frames into one merged file ready for importrealdata.R
cat ${i}NBC.csv >> ${2}_mergedNBCfile.csv
rm ${i}_normalisedBC.csv
rm ${i}NBC.csv


awk 1 ${i}_maxnormalisedBC.csv >> ${2}_mergedMaxNBCfile.csv
rm ${i}_maxnormalisedBC.csv

awk 1 ${i}_meannormalisedBC.csv >> ${2}_mergedMeanNBCfile.csv
rm ${i}_meannormalisedBC.csv

done

cd ..
cd ..

