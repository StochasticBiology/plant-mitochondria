#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

videoname<-args[2]
resolution<-as.integer(args[5])

#change: directory
#need to add in units alterations for micron unit length
getAllFrames <- function() {
  setwd(paste(args[1],videoname,"/all_frames",sep=""))
  allFrames <- list.files(pattern="*.csv")
  for (i in 1:length(allFrames)) {
    assign(allFrames[i], read.csv(allFrames[i], header=FALSE))  
  }
  return (allFrames)
}

#This function looks just through the current frame, taking the distance from the xy you're at, and going through all of the other x ys. When it gets to the point that it compares 
#itself, it produces NA, in order that 0 is not counted in the min() calculation. It spits out the smallest of the numbers in all the comparisons it's done.
comparetoallothers<-function(X1,Y1,results,resolution){
  onevalsdistances<-c()
   for (n in 1:nrow(results)) {
     X1<-X1
     Y1<-Y1
     X2 <- results[n, 4]
     Y2 <- results[n, 5]
    # print(results[n,2])
     d <- sqrt((X1 - X2)^2 + (Y1 - Y2)^2)
     d<- d / resolution
    if(d == 0){
      d<-NA  
    }
    # print(d)
    onevalsdistances <- c(onevalsdistances, d)
   }
  return(min(onevalsdistances,na.rm=TRUE))
  #return(onevalsdistances)
 }


shortestDistancesOfAllFrames<-function(){
  allFrames <- getAllFrames()
  framenumber<-c()
  cvshortestdistsallframes<-c()
  allmitosallshortest<-c()
  for (k in 1:length(allFrames)-1){
    framenumber<-c(framenumber,k)
    resultsFileName <- paste("frame", k ,".csv", sep = "")
    results<- read.delim(resultsFileName, header=FALSE)
    manyvalsshortestdistances <- c()
    shortestdistancesmicrons <-c()
    mitonames<-c()
    for(i in 1:nrow(results)){
        X1<-results[i,4]
        Y1<-results[i,5]
        #Get the shortest distance between current mito and all other mitos, divide by the resolution of the video to get length in microns
        shortestdistancecurrentmito<-comparetoallothers(X1,Y1,results,resolution)
        #Store in a list, building up for all mitos
        shortestdistancesmicrons<-c(shortestdistancesmicrons,shortestdistancecurrentmito)
        allmitosallshortest<-c(allmitosallshortest,shortestdistancecurrentmito)
        mitonames<-c(mitonames,results[i,2])
    }
    csvFileName <- paste(args[1],videoname,"/interMitoDistances/",videoname,"distancesrelatedtoframe", k ,".csv", sep = "")
    #write a file for each frame with all mito labels and that mitos shortest distance to next mito.
    write.csv(data.frame(mitonames,shortestdistancesmicrons), file = csvFileName)
    #get the coefficient of variation for that one frames' mitochondrial shortest distances. Store in list.
    cvshortestdistsallframes<-c(cvshortestdistsallframes,coeffvarfunction(shortestdistancesmicrons))
  }
  CoVallshortestdistsallmitos<-sd(allmitosallshortest)/mean(allmitosallshortest)
  meanallshortestdistsallmitos<-mean(allmitosallshortest)
  summaryStats<-data.frame(CoVallshortestdistsallmitos,meanallshortestdistsallmitos)
  colnames(summaryStats)<-c("overallCoV","overallMean")
  outputtable<-data.frame(framenumber,cvshortestdistsallframes)
  #Write a file overall for the video, with a list of the frames as the CoV for shortest mitochondrial distances in that frame.
  write.csv(outputtable, file = paste(args[1],videoname,"/interMitoDistances/",videoname,"allframesCoeffVar.csv", sep = ""))
  #Then write a file with the summary stats for intermito distance- overall (all frames, all mitos) mean and CoV.
  write.csv(summaryStats, file = paste(args[1],videoname,"/interMitoDistances/summaryStatsInterMitoDist",videoname,".csv", sep = ""))
}

coeffvarfunction<-function(shortestdistancesmicrons){
  coeffvarofshortestdistancesoneframe<-sd(shortestdistancesmicrons)/mean(shortestdistancesmicrons)
  return(coeffvarofshortestdistancesoneframe)
}

shortestDistancesOfAllFrames()



