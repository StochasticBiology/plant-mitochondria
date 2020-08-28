#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

print("polygon errors in simulation are caused by straight line motion- no polygon generated")

library(sp)
library(sets)

workingd<-(paste(args[1],args[2],sep=""))
setwd(workingd)
vidname<-args[2]

fullResultsTable<-read.delim(paste(args[1],args[2],"/",args[3],sep=""),sep="\t")

wholecell<-fullResultsTable




removeNonRelevantFrames<-function(x){
  newTable<-c()
  for(i in 1:nrow(fullResultsTable)){
    if(fullResultsTable$Frame[i] <= x){
     newTable<-rbind(newTable, fullResultsTable[i,])
    }
  }
  return(newTable)
}
  

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

createCHMapPlot<-function(newResultsTable){
  arealist<-c()
  logarealist<-c()
  trajlist<-c()
  proportionalCHlist<-c()
  rateList<-c()
  whole.cell.chull.area<-wholecellCH(wholecell)
  wholecell<-wholecell[,4:5]
  
  #Plotting area of convex hulls in a graphical representation of whole cell (pdf format)
  #pdf(paste(workingd,"/",vidname,"ConvexHullMapTESTTEST.pdf",sep=""))
  #plot(wholecell,xlim= c(0,max(wholecell$x)+70), xlab = "x-coordinates", ylab="y-coordinates",main = vidname,cex=0.5)

  #Needed to make a list of the actualy trajectory numbers, not just looping by 1,2,3,4.. incase of instances of 1,4,5,10... where one or more trajectory values skip
  deletedDuplicatesTrajectories<-as.set(newResultsTable$Trajectory)
    for (i in deletedDuplicatesTrajectories){
     trajfile<-c()
     #print(paste("Trajectory",i))
     for(r in 1:nrow(newResultsTable)){
      if(newResultsTable$Trajectory[r]==i){
        #If it belongs to one trajectory, add the whole line to the file.
        trajfile<-rbind(trajfile,newResultsTable[r,])
      }
     }
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
          #polygon(trajfilecoords[hpts,],col=rgb(rn1,rn2,rn3,1/4))
          #keep all the areas for each trajectory in a list
          if(chull.area==0){
            print(paste("trajectory",trajfile[1,2],"has an area of 0"))
            }
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
          #lines(trajfilecoords[hpts, ], col=rgb(rn1,rn2,rn3,3/4))
       }
      }
  #dev.off()
  
  #Stats for value export- raw values
  
  maxarea<-max(arealist)
  minarea<-min(arealist)
  CoVarea<-sd(arealist)/mean(arealist)
  meanArea<-mean(arealist)
  
  write.csv(data.frame(maxarea,minarea,meanArea,CoVarea), paste(workingd,"/ConvexHullSummStatsFromFrame1to",max(newResultsTable$Frame),"_",vidname,".csv",sep=""))
  
  #Stats for value export- normalised (as convex hull rate)
  maxrate<-max(rateList)
  minrate<-min(rateList)
  CoVrate<-sd(rateList)/mean(rateList)
  meanrate<-mean(rateList)
  
  write.csv(data.frame(maxrate,minrate,meanrate,CoVrate), paste(workingd,"/ConvexHullSummStatsAsRateFromFrame1to",max(newResultsTable$Frame),"_",vidname,".csv",sep=""))
  
  print(paste("CHcompleteFor",args[2]))
}


#If you want any other frames to stop at, make new variables here
earlypoint<-as.numeric(args[6])/10
newResultsTable<-removeNonRelevantFrames(earlypoint)
MaxTraj<-max(newResultsTable$Trajectory)
areasAndRates<-createCHMapPlot(newResultsTable)

midpoint<-as.numeric(args[6])/2
newResultsTable<-removeNonRelevantFrames(midpoint)
MaxTraj<-max(newResultsTable$Trajectory)
areasAndRates<-createCHMapPlot(newResultsTable)



