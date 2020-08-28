#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)


#Run these next two lines:
vidname<-args[2]
workingd<-(paste(args[1],args[2],sep=""))

retrieveAllFrames<-function(){
  directory<-setwd(paste(workingd,"/all_frames",sep=""))
  listofframes<-list.files(pattern="*.csv")
  return(listofframes)
}

getCurrentFrames<-function(){
  countlist<-c()
  listofframes<-retrieveAllFrames()
  for (i in 1:length(listofframes)-1){
    framei<- paste("frame", i,".csv", sep = "")
    framei<- read.delim(framei, header=FALSE)
    count<-nrow(framei)
    countlist<-c(countlist,count)
  }
  #Gives the average number of mitos appearing in frame snapshots over whole video, based on the number of lines, and therefore individual trajectory occurances, in each frame file
  mean<-mean(countlist)
  sd<-sd(countlist)
  write.csv(data.frame(mean,sd),paste(workingd,"/mitoCount-AverageOverAllFrames-",vidname,".csv",sep=""))
}

getCurrentFrames()