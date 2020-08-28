#!/bin/bash
#set -x
#/home/gadmin/Documents/Joanna/FRIENDLY/ ScaleAndCrop-Friendly220219-3 FRIENDLYpiunder5mins3ADJUSTEDCROPPEDabs0-95.csv
#First change the directory to the correct video
cd ${1}/${2}
#Makes storage directories for the split frames and mito speeds
mkdir all_trajectories

cd ${1}
cd ..
./MaxTrajectory.R ${1} ${2} ${3}
cd ${1}/${2}
declare -i maxtraj=$(cat MaxTrajectory.txt)

echo im about to run through $maxtraj files

#^Had to change from more to cat, as more carries with it metadat for scrolling in the terminal, halting progress when ran through ./runAll.sh
for (( i=1; i<=$maxtraj; i++ )); do 
awk -v trajectory="$i" '{if ($2 == trajectory) print $0;}' ${3} > trajectory${i}.csv; 

[ -s trajectory${i}.csv ] || echo "NA" >> trajectory${i}.csv;

mv trajectory${i}.csv all_trajectories

done

cd ..
cd ..


