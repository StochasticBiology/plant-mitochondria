#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

#Altered this to read from the historcalAndNewPairs folders- running with organelles.-am.ce script that spits out both historical and new adjacency matrices, so we are just using the new ones here
#WE'RE USING THE NEW PAIRS, AS HISTORICAl PAIRS DON'T REPRESENT REAL TIME PAIRINGS THEY JUST KEEP ALL OF THEM.

#EDIT: 29/4/2020
#Some networks that have no associations in the first few frames generate empty -spec.txt files. Therefore, There is a script that writes in 
#"NA NA" into these empty files so they can still be read in, and there is a if == "NA NA" catch below that excludes them from being input into the calculations.

#matching associations in the below loops so never get tallied into the count or mean association times. 
#the empty -spec.txt files are ONLY ALTERED in the historicalAndNewPairs file in the appropriate directory. The -spec.txt files in main dir are unchanged
leaddirectory<-args[1]
videoname<-args[2]
filename<-args[3]
frametime<-args[4]
colocdist<-args[7]

workingd<-paste(leaddirectory,videoname,"/historicalAndNewPairs",sep="")
setwd(workingd)

File<-read.delim(paste(leaddirectory,videoname,"/",filename,sep=""),header=TRUE)
MaxTrajectoryNo<-max(File$Trajectory)
FrameNumber<-max(File$Frame)
#This part makes a first file with 1 as the count for that coordinate happening. It works nicely because keeping the coordinates as '23 45'<- that can only occur once in any table,
#So we can use the match function on it rather than having to go through each row in the current file to find it.

#need to include this stringsAsFactors bit so it doesn't spit out a list of levels every time you call a coordinate (this happends because it thinks each entry is a string)
options(stringsAsFactors = FALSE)
firstfile<-read.csv(paste(filename,"-",colocdist,"-0-spec.txt",sep=""),header=FALSE)
print("done")
countList<-c()
if(firstfile[,1]=="NA NA"){
  countList<-c(countList,"NA")
 }else{
  for(i in 1:length(firstfile)){
  countList<-c(countList,1)
 }
}
countingTable<-data.frame(firstfile,countList)

#Take the counts of the frames (from associationCounts) and turn them into seconds counts by mulitplying by the videos or simulations' INDIVIDUAL frame interval.
convertFrameCountIntoSecondsCount<-function(){
  countingTable<-read.csv(paste(leaddirectory,"/",videoname,"/associationtimesin",videoname,".csv",sep=""))
  secondsCountColumn<-c()
  for (i in 1:nrow(countingTable)){
    secondsCount<-countingTable[i,3]*as.numeric(frametime)
    secondsCountColumn<-c(secondsCountColumn,secondsCount)
  }
  newCountingTable<-data.frame(countingTable,secondsCountColumn)
  write.csv(newCountingTable,paste(leaddirectory,"/",videoname,"/associationtimesin",videoname,".csv",sep=""))
  #when taking average YOU MUST REMOVE THE NAS (that will be included if you have empty -spec.txt files) OR THEY WILL BE TALLIED TO THE MEAN 
  meanAssociationTimeSeconds<-mean(secondsCountColumn,na.rm=TRUE)
  write.csv(meanAssociationTimeSeconds,paste(leaddirectory,"/",videoname,"/associationtimeMeanIn",videoname,".csv",sep=""))
}

#if the value in the adjacency list is found in a subsequent frame, add to the count for that value (that specific pair of mitos eg '45 67')
associationCounts<-function(){
for(i in 1:(FrameNumber-1)){
  options(stringsAsFactors = FALSE)
  currentfile<-read.csv(paste(filename,"-",colocdist,"-",i,"-spec.txt",sep=""),header=FALSE)
  for (j in 1:nrow(currentfile)){
    if(currentfile[j,1]=="NA NA"){
      print("includes empty frames")
    }else{
    if(currentfile[j,1] %in% countingTable$V1){
      x<-match(currentfile[j,1], countingTable$V1)
      countingTable[x,2]<-(as.numeric(countingTable[x,2])+1)
    }else{
      countingTable<-rbind(countingTable,c(currentfile[j,],1))
     }
    }
   }
  }
  write.csv(countingTable,paste(leaddirectory,"/",videoname,"/associationtimesin",videoname,".csv",sep=""))
 }


#Run these two functions
associationCounts()
convertFrameCountIntoSecondsCount()
