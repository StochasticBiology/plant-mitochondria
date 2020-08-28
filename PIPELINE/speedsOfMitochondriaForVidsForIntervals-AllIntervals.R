#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
 

#for frames in 1:allFrames
#For every frame, you want to take the mean of all speeds from frame1 to frame n, where n is all frames
meanSpeedsBetweenAllFrames<-function(){
 meanList<-c()
  labelList<-c()
    for (f in 1:args[6]){
      #get the mean speed between the start frame and the one you're currently tracking to 
      speedList<-c()
      for(i in 1:f){
        speedFile<-read.csv(paste(args[1],args[2],"/all_speeds/Speedofallmitosinframe", i ,".csv", sep = ""))
        speedList<-c(speedList,speedFile$speeds)
      }
    meanList<-c(meanList,mean(speedList))
    labelList<-c(labelList,paste("frame0to",f,sep=""))
    }
  allLists<-data.frame(labelList,meanList)
  colnames(allLists)<-c("framesTimes","overallMean")
  write.csv(allLists,paste(args[1],args[2],"/speedMeansOverAllFrames",args[2],".csv", sep = ""))
  print(paste("written for",args[2],sep=" "))
}

meanSpeedsBetweenAllFrames()
