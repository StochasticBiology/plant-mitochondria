#This means: while Internal field seprator is nothing, read line by line the file, and do something. Input goes in at the end weirdly.
#From https://www.cyberciti.biz/faq/unix-howto-read-line-by-line-from-file/

#Beacuse we're appending to the output files, we need to refresh them each time we run the script or they will just keep appending to themselves.
echo -n "" > PIPELINE/FrameNocollation-midpoint.txt
echo -n "" > PIPELINE/CCcollation-midpoint.txt
echo -n "" > PIPELINE/propMaxCCcollation-midpoint.txt
echo -n "" > PIPELINE/normPropMaxCCcollation-midpoint.txt
echo -n "" > PIPELINE/MaxMincollation-midpoint.txt
echo -n "" > PIPELINE/normMaxMincollation-midpoint.txt
echo -n "" > PIPELINE/percolationCollation-midpoint.txt
echo -n "" > PIPELINE/walkerDegreeCollation-midpoint.txt
echo -n "" > PIPELINE/meanDegreeWSCollation-midpoint.txt
echo -n "" > PIPELINE/cvDegreeWSCollation-midpoint.txt
echo -n "" > PIPELINE/meanInterMitoDistCollation-midpoint.txt
echo -n "" > PIPELINE/cvInterMitoDistCollation-midpoint.txt
echo -n "" > PIPELINE/meanSpeedCollation-midpoint.txt
echo -n "" > PIPELINE/maxCHCollation-midpoint.txt
echo -n "" > PIPELINE/minCHCollation-midpoint.txt
echo -n "" > PIPELINE/meanCHCollation-midpoint.txt
echo -n "" > PIPELINE/cvCHCollation-midpoint.txt
echo -n "" > PIPELINE/assocTimeCollation-midpoint.txt
echo -n "" > PIPELINE/maxCHRateCollation-midpoint.txt
echo -n "" > PIPELINE/minCHRateCollation-midpoint.txt
echo -n "" > PIPELINE/meanCHRateCollation-midpoint.txt
echo -n "" > PIPELINE/cvCHRateCollation-midpoint.txt
echo -n "" > PIPELINE/AverageDistsWScollation-midpoint.txt
echo -n "" > PIPELINE/avConnectedNeighboursWSCollation-midpoint.txt
echo -n "" > PIPELINE/NetworkEfficiencyWSCollation-midpoint.txt


input="/Users/d1795494/Documents/PIPELINE/OriginDirectoriesTable.txt"
while IFS= read -r line
do
  echo "$line"
  #Find the number of frames in the video you're currently looking at
  name=$(find "$line" -name "*_F.csv")
  frames=$(cat $name | wc -l)
  #In order to get the middle values of frame time
  middleFrame=$(($frames/2))
            #Go through each statistic and find the correct corresponding frame number, and statistics from it
            #Be aware that some files may have the top header column counted and some may not. $middleFrame is adjusted accordingly here
            #In awk, you need -v to pass redefined shell variable to awk
            # 1 Frame
            find  $line -name "*_F.csv" | xargs -n1 awk -v frame="$((middleFrame+1))" -F "," '{if(NR==frame) print $1}' >> PIPELINE/FrameNocollation-midpoint.txt
            # 2 CC 
            find $line -name "*_CC.csv" | xargs -n1 awk -v frame="$((middleFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/CCcollation-midpoint.txt
            # 3 SCC
            find $line -name "*_SCCproportions.csv" | xargs -n1 awk -v frame="$((middleFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/propMaxCCcollation-midpoint.txt
            # 4 normSCCproportions
            find $line -name "*_normSCCproportions.csv" | xargs -n1 awk -v frame="$((middleFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/normPropMaxCCcollation-midpoint.txt
            # 5 MaxMin
            find $line -name "*normalisedAndRawMaxMinDistsForAllFrames.csv" | xargs -n1 awk -v frame="$((middleFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/MaxMincollation-midpoint.txt
            # 6 normMaxMin
            find $line -name "*normalisedAndRawMaxMinDistsForAllFrames.csv" | xargs -n1 awk -v frame="$((middleFrame+1))" -F "," '{if(NR==frame) print $4}' >> PIPELINE/normMaxMincollation-midpoint.txt
            # 7 Percolation- this is the only statistics thats still encompassing the whole network. Will be excluded eventually
            find $line -name "percolationThresholdJumps*.csv" | xargs -n1 awk -F "," 'END{print $1}' >> PIPELINE/percolationCollation-midpoint.txt
            # 8 DegreeDrop
            find $line -name "MeanDropsBetweenStepsForAllFramesIn*.csv" | xargs -n1 awk -v frame="$((middleFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/walkerDegreeCollation-midpoint.txt
            # 9 MeanDegree With Singletons
            find $line -name "*_MeanD_WS.csv" | xargs -n1 awk -v frame="$((middleFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/meanDegreeWSCollation-midpoint.txt
            # 10 CoeffVar degree with singletons
            find $line -name "*_CoeffVarD_WS.csv" | xargs -n1 awk -v frame="$((middleFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/cvDegreeWSCollation-midpoint.txt
            # 11 Mean InterMitoDist 
            find $line -name "summaryStatsAccumulatesOverAllFramesInterMitoDist*" | xargs -n1 awk -v frame="$((middleFrame+2))" -F "," '{if(NR==frame) print $3}' >> PIPELINE/meanInterMitoDistCollation-midpoint.txt
            # 12 CV InterMitoDist
            find $line -name "summaryStatsAccumulatesOverAllFramesInterMitoDist*" | xargs -n1 awk -v frame="$((middleFrame+2))" -F "," '{if(NR==frame) print $4}' >> PIPELINE/cvInterMitoDistCollation-midpoint.txt
            # 13 Mean Speed
            find $line -name "speedMeansOverAllFrames*" | xargs -n1 awk -v frame="$((middleFrame+1))" -F "," '{if(NR==frame) print $3}' >> PIPELINE/meanSpeedCollation-midpoint.txt
            # 14 Convex hull maximum    100Frames4 might need editing here for these
            find $line -name "ConvexHullSummStatsFromFrame1to$middleFrame*" | xargs -n1 awk -F "," 'END{print $2}' >> PIPELINE/maxCHCollation-midpoint.txt
            # 15 Convex hull minimum
            find $line -name "ConvexHullSummStatsFromFrame1to$middleFrame*" | xargs -n1 awk -F "," 'END{print $3}' >> PIPELINE/minCHCollation-midpoint.txt
            # 16 Convex hull mean
            find $line -name "ConvexHullSummStatsFromFrame1to$middleFrame*" | xargs -n1 awk -F "," 'END{print $4}' >> PIPELINE/meanCHCollation-midpoint.txt
            # 17 Convex hull CoV
            find $line -name "ConvexHullSummStatsFromFrame1to$middleFrame*" | xargs -n1 awk -F "," 'END{print $5}' >> PIPELINE/cvCHCollation-midpoint.txt
            # 18 AssociationTime
            find $line -name "associationtimeIntervalsMeanIn1to$middleFrame*" | xargs -n1 awk -F "," 'END{print $2}' >> PIPELINE/assocTimeCollation-midpoint.txt
            # 19 Convex hull maximum
            find $line -name "ConvexHullSummStatsAsRateFromFrame1to$middleFrame*" | xargs -n1 awk -F "," 'END{print $2}' >> PIPELINE/maxCHRateCollation-midpoint.txt
            # 20 Convex hull minimum
            find $line -name "ConvexHullSummStatsAsRateFromFrame1to$middleFrame*" | xargs -n1 awk -F "," 'END{print $3}' >> PIPELINE/minCHRateCollation-midpoint.txt
            # 21 Convex hull mean
            find $line -name "ConvexHullSummStatsAsRateFromFrame1to$middleFrame*" | xargs -n1 awk -F "," 'END{print $4}' >> PIPELINE/meanCHRateCollation-midpoint.txt
            # 22 Convex hull CoV
            find $line -name "ConvexHullSummStatsAsRateFromFrame1to$middleFrame*" | xargs -n1 awk -F "," 'END{print $5}' >> PIPELINE/cvCHRateCollation-midpoint.txt
            # 23 averageDists with singletons
            find $line -name "averageDistsOverNetworksForAllFrames_WS.csv" | xargs -n1 awk -v frame="$((middleFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/AverageDistsWScollation-midpoint.txt
            # 24 averageNumberOfConnectedNeighbours
            find $line -name "*averageNumberOfConnectedNeighbours.csv" | xargs -n1 awk -v frame="$((middleFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/avConnectedNeighboursWSCollation-midpoint.txt
            # 25 Network efficiency with singletons
            find $line -name "*avNetworkEfficiency_WS.csv" | xargs -n1 awk -v frame="$((middleFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/NetworkEfficiencyWSCollation-midpoint.txt
            
            #CAREFUL-speed and intermito distances will have a different count- intermit goes from 0, speeds goes from 1
            #Not including as more difficult to split by frame time: percolationThreshold

done < "$input"


paste -d' ' PIPELINE/FrameNocollation-midpoint.txt PIPELINE/CCcollation-midpoint.txt PIPELINE/propMaxCCcollation-midpoint.txt PIPELINE/normPropMaxCCcollation-midpoint.txt PIPELINE/MaxMincollation-midpoint.txt PIPELINE/normMaxMincollation-midpoint.txt PIPELINE/percolationCollation-midpoint.txt PIPELINE/walkerDegreeCollation-midpoint.txt PIPELINE/meanDegreeWSCollation-midpoint.txt PIPELINE/cvDegreeWSCollation-midpoint.txt PIPELINE/meanInterMitoDistCollation-midpoint.txt PIPELINE/cvInterMitoDistCollation-midpoint.txt PIPELINE/meanSpeedCollation-midpoint.txt PIPELINE/maxCHCollation-midpoint.txt PIPELINE/minCHCollation-midpoint.txt PIPELINE/meanCHCollation-midpoint.txt PIPELINE/cvCHCollation-midpoint.txt PIPELINE/assocTimeCollation-midpoint.txt PIPELINE/maxCHRateCollation-midpoint.txt PIPELINE/minCHRateCollation-midpoint.txt PIPELINE/meanCHRateCollation-midpoint.txt PIPELINE/cvCHRateCollation-midpoint.txt PIPELINE/AverageDistsWScollation-midpoint.txt PIPELINE/avConnectedNeighboursWSCollation-midpoint.txt PIPELINE/NetworkEfficiencyWSCollation-midpoint.txt > PIPELINE/StatsTable-MIDPOINT.txt

            
