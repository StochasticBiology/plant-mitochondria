#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

suppressMessages(library(ggplot2))
suppressMessages(library(dplyr))
suppressMessages(library(vioplot))

#A script to find the length of each trajectory in a whole video, with the aim of getting the average length.
#Tajectories are made up of coordinates, appearing in consecutive frames.

workingd<-(paste(args[1],args[2],sep=""))
videoname<-args[2]
setwd(workingd)

retrieveAllTrajectories<-function(){
  directory<-setwd(paste(workingd,"/all_trajectories",sep=""))
  listoftrajs<-list.files(pattern="*.csv")
  return(listoftrajs)
}
allTrajs <- retrieveAllTrajectories()

everyDistanceOfAllFrames<-function(){
  allTrajs <- retrieveAllTrajectories()
  distsofthattraj<-c()
  trajectorynumber<-c()
  summeddistances<-c()
  allsummeddistances<-c()
  frametimeoftrajectory<-c()
    for(k in 1:length(allTrajs)){
       File <- read.delim(paste("trajectory", k ,".csv", sep = ""), header=FALSE)
       numberofframesofthattrajectory<-nrow(File)
       #here we are subtracting one for comparisons not adding as adding would run us off the bottom of the table and it would error
       for (j in 2:nrow(File)){
         X1<-File[j-1,4]
         Y1<-File[j-1,5]
         X2<-File[j,4]
         Y2<-File[j,5]
         distance <- sqrt((X1 - X2)^2 + (Y1 - Y2)^2)
         #altering the distance travelled by the resolution of te video. Trajectroy length in pixels/ pixel per micron resolution = microns travelled
         distance<-distance/as.numeric(args[3])
         distsofthattraj<-c(distsofthattraj,distance)
       }
       trajectorynumber<-c(trajectorynumber,k)
       summeddistances<-sum(distsofthattraj)
       allsummeddistances<-c(allsummeddistances,summeddistances)
       frametimeoftrajectory<-c(frametimeoftrajectory, numberofframesofthattrajectory)
       distsofthattraj<-c()
    }
  data<-data.frame(trajectorynumber,allsummeddistances,frametimeoftrajectory)
  FileName <- paste("trajectorylengths", videoname,".csv", sep = "")
  write.csv(data, file = paste(workingd,"/",FileName,sep=""), row.names=FALSE)
}

everyDistanceOfAllFrames()


#ggplot work
#THos violin plot of trajectory lengths wont include data for trajectories with <2 lines of output in- you cannot calculate trejectory lengths for them.
setwd(workingd)
trajectoryFile <- read.csv(paste("trajectorylengths", videoname,".csv", sep = ""))
#If the file has come into the everyDistanceOfAllFrames with just NA in, as it was an empty trajectory from the simulation, the distance will be 0.But ggplot does not plot non-positive numbers, so we need ot make the 0 into NA. 
#This should not mess with the other data as the simulation will never produce distanced so of exactly 0 moved. 
for(i in 1:nrow(trajectoryFile)){
  if(is.na(trajectoryFile[i,2])==FALSE && trajectoryFile[i,2]==0 ){
    trajectoryFile[i,2]=NA
  }
}
pdf(paste(workingd,"/",videoname,"vioplot.pdf",sep=""))
ggplot(trajectoryFile, aes(x = videoname, y = allsummeddistances)) + geom_point(col=trajectoryFile$allsummeddistances) + geom_violin(alpha=.2)+geom_point(aes(x=videoname,y=mean(trajectoryFile$allsummeddistances)),shape=4,col="black",size=4)+ylab("all summed distances (microns)") + labs(title = paste("Trajectory lengths for ",videoname,""))
dev.off()
