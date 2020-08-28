#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

library(ggplot2)
library(sp)


workingd<-(paste(args[1],args[2],sep=""))
#workingd<-(paste("/home/gadmin/Documents/Joanna/Simulation/SimulationFrames/ntwrkGenForABCsim/",allParas,sep=""))
setwd(workingd)
print(workingd)

vidname<-args[2]


wholecell<-read.delim(paste(workingd,"/",args[3],sep=""),header=T)
MaxTraj<-read.delim(paste(workingd,"/MaxTrajectory.txt",sep=""),header = F)
MaxTraj<-MaxTraj[1,1]

getAllTrajs <- function() {
  setwd(paste(workingd,"/all_trajectories",sep=""))
  allTrajs = list.files(pattern="*.csv")
  return(allTrajs)
}
allTrajs<-getAllTrajs()

#Convex Hull area of whole cell. 
#Finding this in order to use it to find the proportion of each trajectories convex hull in proportion to this one.
wholecellCH<-function(wholecell){
  wholecell<-wholecell[,4:5]
  hpts <- chull(wholecell)
  hpts <- c(hpts, hpts[1])
  chull.poly <- Polygon(wholecell[hpts, ], hole=F)
  whole.cell.chull.area <- chull.poly@area
  return(whole.cell.chull.area)
}

createCHMapPlot<-function(){
  allTrajs<-getAllTrajs()
  arealist<-c()
  logarealist<-c()
  trajlist<-c()
  proportionalCHlist<-c()
  rateList<-c()
  setwd(paste(workingd,"/all_trajectories",sep=""))
  wholecell<-read.delim(paste(workingd,"/",args[3],sep=""),header=T)
  whole.cell.chull.area<-wholecellCH(wholecell)
  wholecell<-wholecell[,4:5]
  #Plotting area of convex hulls in a graphical representation of whole cell (pdf format)
  pdf(paste(workingd,"/",vidname,"ConvexHullMap.pdf",sep=""))
  plot(wholecell,xlim= c(0,max(wholecell$x)+70), xlab = "x-coordinates", ylab="y-coordinates",main = vidname,cex=0.5)
  for (i in 1:length(allTrajs)){
    trajfile<-read.delim(paste(allTrajs[i],sep=""),header = F)
    #had to put this if catch in to exclude any trajectories that were only one coordinate long, as they would generate an area of 0
    if(nrow(trajfile)>=3){
      #HERE
      trajfilecoords<-trajfile[,4:5]
      hpts <- chull(trajfilecoords)
      hpts <- c(hpts, hpts[1])
      
      rn1<- sample(0:1,1)
      rn2<- sample(0:1,1)
      rn3<- sample(0:1,1)
      
      #plot the convex hull as a polygon shape (this depends on the "sp" package being installed)
      chull.poly <- Polygon(trajfilecoords[hpts, ], hole=F)
      #find its area
      chull.area <- chull.poly@area
      #Fill the middle of the polygon transparently
      polygon(trajfilecoords[hpts,],col=rgb(rn1,rn2,rn3,1/4))
      #keep all the areas for each trajectory in a list
      #The point of dividing the area by the resolution is to go from pixels -> microns 
      #The resolution for the experimental data is variable, wheras for the theoretical it is always 1 as the cell space is already converted to microns.
      areaInMicrons<-chull.area/as.numeric(args[5])
      arealist<-c(arealist,areaInMicrons)
      logarealist<-c(logarealist,log(areaInMicrons))
      #Also want to calculate the 'Convex Hull Rate' to normalise the convex hull area covered by the amount of time spent covering it. So we're doing distance (now in microns)
      #over time, so need to calculate the time each trajectory exists for. So nrow(trajectory)*frame interval = seconds spent moving about. Then divide area by this time.  
      timeMoved<-nrow(trajfile)*as.numeric(args[4])
      convexHullRate<- areaInMicrons/timeMoved
      rateList<-c(rateList,convexHullRate)
      #keep all the trajectory names in a list
      #picks the name of the trajectory from the column of trajectory name, so you know it's exactly that trajectory. 
      #You could also pick the 'i' this loop iterates through, the earlier versions of this script did that.
      trajlist<-c(trajlist,trajfile[1,2])
      #keep all the proportional areas of the trajectories in a list
      proportionalCHlist<-c(proportionalCHlist, chull.area/whole.cell.chull.area)
      #add a line to the plot for every new trajectory you want to add
      lines(trajfilecoords[hpts, ], col=rgb(rn1,rn2,rn3,3/4))
    }
  }
  dev.off()
  print("CHtracepdfcomplete")
  write.csv(data.frame(trajlist,arealist,logarealist), paste(workingd,"/areaandlogarealist",vidname,".csv",sep=""))
  write.csv(data.frame(trajlist,rateList), paste(workingd,"/convexHullRateList",vidname,".csv",sep=""))
  write.csv(data.frame(trajlist,proportionalCHlist), paste(workingd,"/proportionalCHarealist",vidname,".csv",sep=""))
  write.csv(data.frame(trajlist), paste(workingd,"/trajlist",vidname,".csv",sep=""))
}
createCHMapPlot()

#Stats for value export- raw values
arealist<-read.csv(paste(workingd,"/areaandlogarealist",vidname,".csv",sep=""),header=T)
maxarea<-max(arealist$arealist)
maxlogarea<-max(arealist$logarealist)
minarea<-min(arealist$arealist)
minlogarea<-min(arealist$logarealist)
CoVarea<-sd(arealist$arealist)/mean(arealist$arealist)
meanArea<-mean(arealist$arealist)

write.csv(data.frame(maxarea,minarea,meanArea,CoVarea), paste(workingd,"/ConvexHullSummStats_",vidname,".csv",sep=""))

#Stats for value export- normalised (as conves hull rate)
ratelist<-read.csv(paste(workingd,"/convexHullRateList",vidname,".csv",sep=""),header=T)
maxrate<-max(ratelist$rateList)
minrate<-min(ratelist$rateList)
CoVrate<-sd(ratelist$rateList)/mean(ratelist$rateList)
meanrate<-mean(ratelist$rateList)

write.csv(data.frame(maxrate,minrate,meanrate,CoVrate), paste(workingd,"/ConvexHullSummStatsAsRate_",vidname,".csv",sep=""))

#histogram formatting
areabinvector<-seq(floor(minarea),ceiling(maxarea),1)
logareabinvector<-seq(floor(minlogarea),ceiling(maxlogarea),0.1)


setwd(paste(workingd,"/histograms",sep=""))                 
png(filename=paste("ConvexHullArea",vidname,".png",sep=""))
hist(arealist$arealist,breaks=areabinvector,main=c(paste("Trajectory Convex Hull area"),paste(vidname)),xlab= "area(um^2)")
dev.off()

png(filename=paste("ConvexHullLogArea",vidname,".png",sep=""))
hist(arealist$logarealist,breaks=logareabinvector,main=c(paste("Trajectory Convex Hull logged area"),paste(vidname)),xlab="log(area)(um^2)")
dev.off()

