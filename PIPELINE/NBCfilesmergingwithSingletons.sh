#!/bin/bash

cd ${1}/${2}

#need to remove any previous one or it will keep adding new runs to the same file 
rm ${2}_mergedNBCfile_WS.csv
rm ${2}_mergedMaxNBCfile_WS.csv
rm ${2}_mergedMeanNBCfile_WS.csv
echo "Dont worry about this error if it's the first time running this data ^^"

#Loop through all frame numbers
for i in $(seq 1 ${3}); do

#paste list of normalised BCs into a new file as one long line with comma seperation
paste -s -d, ${i}_normalisedBC_WS.csv >> ${i}NBC_WS.csv

#paste all of the different frames into one merged file ready for importrealdata.R
cat ${i}NBC_WS.csv >> ${2}_mergedNBCfile_WS.csv
rm ${i}_normalisedBC_WS.csv
rm ${i}NBC_WS.csv

awk 1 ${i}_maxnormalisedBC_WS.csv >> ${2}_mergedMaxNBCfile_WS.csv
rm ${i}_maxnormalisedBC_WS.csv

awk 1 ${i}_meannormalisedBC_WS.csv >> ${2}_mergedMeanNBCfile_WS.csv
rm ${i}_meannormalisedBC_WS.csv

done

cd ..
cd ..

