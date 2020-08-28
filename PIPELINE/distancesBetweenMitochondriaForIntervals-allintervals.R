#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)


#Generating a list of mean distances from time 0-n where n is all time points
meancvFrom0toAllendpoints<-function(){
  meanList<-c()
  cvList<-c()
  labelList<-c()
  for(f in 0:args[6]){
    distanceList<-c()
    for(i in 0:f){
      file<-read.csv(paste(args[1],args[2],"/interMitoDistances/",args[2],"distancesrelatedtoframe",i,".csv",sep=""))
      distanceList<-c(distanceList,file$shortestdistancesmicrons)
    }
    CoVallshortestdistsallmitos<-sd(distanceList)/mean(distanceList)
    meanallshortestdistsallmitos<-mean(distanceList)
    meanList<-c(meanList,meanallshortestdistsallmitos)
    cvList<-c(cvList,CoVallshortestdistsallmitos)
    labelList<-c(labelList,paste("frame0to",f,sep=""))
  }
  allLists<-data.frame(labelList,meanList,cvList)
  colnames(allLists)<-c("framesTimes","overallMean","overallCoV")
  write.csv(allLists,paste(args[1],args[2],"/interMitoDistances/summaryStatsAccumulatesOverAllFramesInterMitoDist",args[2],".csv", sep = ""))
  print(paste("written for",args[2],sep=" "))
  }
meancvFrom0toAllendpoints()




#If you want to do this for a specific endpoint, not all endpoints, do this:

#midpoint=args[6]/2
#earlypoint=args[6]/10

#meancvFrom0toendpoint(earlypoint)
#meancvFrom0toendpoint(midpoint)

#obviously here i goes from i to n in steps of 1, so we don't have to worry about rounding midpoint or early point. Just be careful with other bits of software.
meancvFrom0toendpoint<-function(x){
  distanceList<-c()
  for(i in 0:x){
    file<-read.csv(paste(args1,args2,"/interMitoDistances/",args2,"distancesrelatedtoframe",i,".csv",sep=""))
    distanceList<-c(distanceList,file$shortestdistancesmicrons)
  }
  CoVallshortestdistsallmitos<-sd(distanceList)/mean(distanceList)
  meanallshortestdistsallmitos<-mean(distanceList)
  timePeriodSummaryStats<-data.frame(CoVallshortestdistsallmitos,meanallshortestdistsallmitos)
  colnames(timePeriodSummaryStats)<-c("overallCoV","overallMean")
  write.csv(timePeriodSummaryStats,paste(args1,args2,"/interMitoDistances/summaryStatsFrame0-",i,"InterMitoDist",args2,".csv", sep = ""))
  return(timePeriodSummaryStats)
}
