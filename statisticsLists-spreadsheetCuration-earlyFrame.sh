#This means: while Internal field seprator is nothing, read line by line the file, and do something. Input goes in at the end weirdly.
#From https://www.cyberciti.biz/faq/unix-howto-read-line-by-line-from-file/

#Beacuse we're appending to the output files, we need to refresh them each time we run the script or they will just keep appending to themselves.
echo -n "" > PIPELINE/FrameNocollation-earlypoint.txt
echo -n "" > PIPELINE/CCcollation-earlypoint.txt
echo -n "" > PIPELINE/propMaxCCcollation-earlypoint.txt
echo -n "" > PIPELINE/normPropMaxCCcollation-earlypoint.txt
echo -n "" > PIPELINE/MaxMincollation-earlypoint.txt
echo -n "" > PIPELINE/normMaxMincollation-earlypoint.txt
echo -n "" > PIPELINE/percolationCollation-earlypoint.txt
echo -n "" > PIPELINE/walkerDegreeCollation-earlypoint.txt
echo -n "" > PIPELINE/meanDegreeWSCollation-earlypoint.txt
echo -n "" > PIPELINE/cvDegreeWSCollation-earlypoint.txt
echo -n "" > PIPELINE/meanInterMitoDistCollation-earlypoint.txt
echo -n "" > PIPELINE/cvInterMitoDistCollation-earlypoint.txt
echo -n "" > PIPELINE/meanSpeedCollation-earlypoint.txt
echo -n "" > PIPELINE/maxCHCollation-earlypoint.txt
echo -n "" > PIPELINE/minCHCollation-earlypoint.txt
echo -n "" > PIPELINE/meanCHCollation-earlypoint.txt
echo -n "" > PIPELINE/cvCHCollation-earlypoint.txt
echo -n "" > PIPELINE/assocTimeCollation-earlypoint.txt
echo -n "" > PIPELINE/maxCHRateCollation-earlypoint.txt
echo -n "" > PIPELINE/minCHRateCollation-earlypoint.txt
echo -n "" > PIPELINE/meanCHRateCollation-earlypoint.txt
echo -n "" > PIPELINE/cvCHRateCollation-earlypoint.txt
echo -n "" > PIPELINE/AverageDistsWScollation-earlypoint.txt
echo -n "" > PIPELINE/avConnectedNeighboursWSCollation-earlypoint.txt
echo -n "" > PIPELINE/NetworkEfficiencyWSCollation-earlypoint.txt


input="./PIPELINE/OriginDirectoriesTable.txt"
while IFS= read -r line
do
  echo "$line"
  #Find the number of frames in the video you're currently looking at
  name=$(find "$line" -name "*_F.csv")
  frames=$(cat $name | wc -l)
  #In order to get the middle values of frame time
  earlyFrame=$(($frames/10))
            #Go through each statistic and find the correct corresponding frame number, and statistics from it
            #Be aware that some files may have the top header column counted and some may not. $earlyFrame is adjusted accordingly here
            #In awk, you need -v to pass redefined shell variable to awk
            #Frame
            find  $line -name "*_F.csv" | xargs -n1 awk -v frame="$((earlyFrame+1))" -F "," '{if(NR==frame) print $1}' >> PIPELINE/FrameNocollation-earlypoint.txt
            #CC 
            find $line -name "*_CC.csv" | xargs -n1 awk -v frame="$((earlyFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/CCcollation-earlypoint.txt
            #SCC
            find $line -name "*_SCCproportions.csv" | xargs -n1 awk -v frame="$((earlyFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/propMaxCCcollation-earlypoint.txt
            #normSCCproportions
            find $line -name "*_normSCCproportions.csv" | xargs -n1 awk -v frame="$((earlyFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/normPropMaxCCcollation-earlypoint.txt
            #MaxMin
            find $line -name "*normalisedAndRawMaxMinDistsForAllFrames.csv" | xargs -n1 awk -v frame="$((earlyFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/MaxMincollation-earlypoint.txt
            #normMaxMin
            find $line -name "*normalisedAndRawMaxMinDistsForAllFrames.csv" | xargs -n1 awk -v frame="$((earlyFrame+1))" -F "," '{if(NR==frame) print $4}' >> PIPELINE/normMaxMincollation-earlypoint.txt
            #Percolation- this is the only statistics thats still encompassing the whole network. Will be excluded eventually
            find $line -name "percolationThresholdJumps*.csv" | xargs -n1 awk -F "," 'END{print $1}' >> PIPELINE/percolationCollation-earlypoint.txt
            #DegreeDrop
            find $line -name "MeanDropsBetweenStepsForAllFramesIn*.csv" | xargs -n1 awk -v frame="$((earlyFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/walkerDegreeCollation-earlypoint.txt
            #MeanDegree With Singletons
            find $line -name "*_MeanD_WS.csv" | xargs -n1 awk -v frame="$((earlyFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/meanDegreeWSCollation-earlypoint.txt
            #CoeffVar degree with singletons
            find $line -name "*_CoeffVarD_WS.csv" | xargs -n1 awk -v frame="$((earlyFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/cvDegreeWSCollation-earlypoint.txt
            #Mean InterMitoDist 
            find $line -name "summaryStatsAccumulatesOverAllFramesInterMitoDist*" | xargs -n1 awk -v frame="$((earlyFrame+2))" -F "," '{if(NR==frame) print $3}' >> PIPELINE/meanInterMitoDistCollation-earlypoint.txt
            #CV InterMitoDist
            find $line -name "summaryStatsAccumulatesOverAllFramesInterMitoDist*" | xargs -n1 awk -v frame="$((earlyFrame+2))" -F "," '{if(NR==frame) print $4}' >> PIPELINE/cvInterMitoDistCollation-earlypoint.txt
            #Mean Speed
            find $line -name "speedMeansOverAllFrames*" | xargs -n1 awk -v frame="$((earlyFrame+1))" -F "," '{if(NR==frame) print $3}' >> PIPELINE/meanSpeedCollation-earlypoint.txt
            #Convex hull maximum
            find $line -name "ConvexHullSummStatsFromFrame1to${earlyFrame}_*" | xargs -n1 awk -F "," 'END{print $2}' >> PIPELINE/maxCHCollation-earlypoint.txt
            #Convex hull minimum
            find $line -name "ConvexHullSummStatsFromFrame1to${earlyFrame}_*" | xargs -n1 awk -F "," 'END{print $3}' >> PIPELINE/minCHCollation-earlypoint.txt
            #Convex hull mean
            find $line -name "ConvexHullSummStatsFromFrame1to${earlyFrame}_*" | xargs -n1 awk -F "," 'END{print $4}' >> PIPELINE/meanCHCollation-earlypoint.txt
            #Convex hull CoV
            find $line -name "ConvexHullSummStatsFromFrame1to${earlyFrame}_*" | xargs -n1 awk -F "," 'END{print $5}' >> PIPELINE/cvCHCollation-earlypoint.txt
            #AssociationTime
            find $line -name "associationtimeIntervalsMeanIn1to${earlyFrame}_*" | xargs -n1 awk -F "," 'END{print $2}' >> PIPELINE/assocTimeCollation-earlypoint.txt
            #Convex hull maximum
            find $line -name "ConvexHullSummStatsAsRateFromFrame1to${earlyFrame}_*" | xargs -n1 awk -F "," 'END{print $2}' >> PIPELINE/maxCHRateCollation-earlypoint.txt
            #Convex hull minimum
            find $line -name "ConvexHullSummStatsAsRateFromFrame1to${earlyFrame}_*" | xargs -n1 awk -F "," 'END{print $3}' >> PIPELINE/minCHRateCollation-earlypoint.txt
            #Convex hull mean
            find $line -name "ConvexHullSummStatsAsRateFromFrame1to${earlyFrame}_*" | xargs -n1 awk -F "," 'END{print $4}' >> PIPELINE/meanCHRateCollation-earlypoint.txt
            #Convex hull CoV
            find $line -name "ConvexHullSummStatsAsRateFromFrame1to${earlyFrame}_*" | xargs -n1 awk -F "," 'END{print $5}' >> PIPELINE/cvCHRateCollation-earlypoint.txt
            #averageDists with singletons
            find $line -name "averageDistsOverNetworksForAllFrames_WS.csv" | xargs -n1 awk -v frame="$((earlyFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/AverageDistsWScollation-earlypoint.txt
            #averageNumberOfConnectedNeighbours
            find $line -name "*averageNumberOfConnectedNeighbours.csv" | xargs -n1 awk -v frame="$((earlyFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/avConnectedNeighboursWSCollation-earlypoint.txt
            #Network efficiency with singletons
            find $line -name "*avNetworkEfficiency_WS.csv" | xargs -n1 awk -v frame="$((earlyFrame+1))" -F "," '{if(NR==frame) print $2}' >> PIPELINE/NetworkEfficiencyWSCollation-earlypoint.txt
            
            #CAREFUL-speed and intermito distances will have a different count- intermit goes from 0, speeds goes from 1
            #Not including as more difficult to split by frame time: percolationThreshold

done < "$input"


paste -d' ' PIPELINE/FrameNocollation-earlypoint.txt PIPELINE/CCcollation-earlypoint.txt PIPELINE/propMaxCCcollation-earlypoint.txt PIPELINE/normPropMaxCCcollation-earlypoint.txt PIPELINE/MaxMincollation-earlypoint.txt PIPELINE/normMaxMincollation-earlypoint.txt PIPELINE/percolationCollation-earlypoint.txt PIPELINE/walkerDegreeCollation-earlypoint.txt PIPELINE/meanDegreeWSCollation-earlypoint.txt PIPELINE/cvDegreeWSCollation-earlypoint.txt PIPELINE/meanInterMitoDistCollation-earlypoint.txt PIPELINE/cvInterMitoDistCollation-earlypoint.txt PIPELINE/meanSpeedCollation-earlypoint.txt PIPELINE/maxCHCollation-earlypoint.txt PIPELINE/minCHCollation-earlypoint.txt PIPELINE/meanCHCollation-earlypoint.txt PIPELINE/cvCHCollation-earlypoint.txt PIPELINE/assocTimeCollation-earlypoint.txt PIPELINE/maxCHRateCollation-earlypoint.txt PIPELINE/minCHRateCollation-earlypoint.txt PIPELINE/meanCHRateCollation-earlypoint.txt PIPELINE/cvCHRateCollation-earlypoint.txt PIPELINE/AverageDistsWScollation-earlypoint.txt PIPELINE/avConnectedNeighboursWSCollation-earlypoint.txt PIPELINE/NetworkEfficiencyWSCollation-earlypoint.txt > PIPELINE/StatsTable-earlypoint.txt


