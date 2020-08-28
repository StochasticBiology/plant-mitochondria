#!/bin/bash
#First change the directory to the correct video
cd ${1}/${2}
#Makes storage directories for the split frames and mito speeds
mkdir all_frames
mkdir all_speeds
mkdir histograms
mkdir log_all_speeds
mkdir interMitoDistances

#splits the frames
#MAKE SURE the for loop only goes over how many frames are in the video you're looking at. If the number of frames in the video is less than what youve stated in the for loop, the loop will make excess and empty files, which R will throw an error for further down the line.
#Had to change $line to $0 to print whole line on Mac- for some reason OSX doesn't like the $line command. $1, $2, $3 print the 1st, 2nd, 3rd fields respectively, $0 prints the whole line.
for i in $(seq 0 $4); do
awk -v frame="$i" '{if ($3 == frame) print $0;}' ${3} > frame${i}.csv;

#stores them in the all_frames file
mv frame${i}.csv all_frames

done

cd ..
cd ..
