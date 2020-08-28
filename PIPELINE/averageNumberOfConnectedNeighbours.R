#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

#Before  this, make sure to have run "importRealData-withSingletons.r"
#This is as it formats the SCC_WS file, that you need for this analysis.

#A new statistic to describe the connected components size over the number of nodes.
#ie the number of nodes each individual in the connected component can reach, averaged over all 
#nodes in all connected components

#eg cc sizes: 56,7,8,4 would equal (56^2 + 7^2 + 8^2 + 4^2) / (56+7+8+4)
#56^2 This is the number of nodes that all nodes are connected to (including itself).
#ie in a cc of size two, this number is 4, as node 1 can reach node 1 and 2, and node 2 can reach node 2 and 1. 

#For singletons:
 #cc size: 10, with 10 extra singletons would equal (10^2)+(10*(1^2))  / 20 = 5.5
 #                                          or just (10^2)+10 / 20 = 5.5

currentDir<-paste(args[1],args[2],sep="")
#currentDir<-paste("/Users/d1795494/Documents/PIPELINE/MitoGFP-TRACKMATERUNS/","trackmaterun-bigcellmanymitos2",sep="" )

setwd(currentDir)

sizeCC<-read.csv(paste(args[2],"_SCC_WS.csv",sep=""),row.names=1)
#sizeCC<-read.delim("trackmaterun-bigcellmanymitos2_SCC_WS.csv",row.names=1 , sep=",")

#If you want to test, these should give 3.3 and 5.5
##testTab<-data.frame(c(NA,4,2,NA,NA,NA,NA,NA,NA,NA,NA,NA),c(NA,10,1,1,1,1,1,1,1,1,1,1))
##sizeCC<-t(testTab)

#Make an empty data frame, of same size as sizeCC (minus 1 column as that's just frames in sizeCC)
sizeCCsquared<-data.frame(matrix(NA, nrow = nrow(sizeCC), ncol = ncol(sizeCC)-1))
#Make an empty list too, to add to to make taking average easier. 
AvNoConnectedNeighboursList<-c()

#loop through frames
for(i in 1:nrow(sizeCC)){
  
  #Take the sum of all the CC sizes for one frame. eg 4 + 4 + 5 + 1 + 1 + 1
  sumCCsizes<-sum(sizeCC[i,2:ncol(sizeCC)],na.rm=TRUE)
  
  #take each row, square all the values, add to new dataframe sizeCCsquared (as a check)
  #eg c( 4^2, 4^2, 5^2, 1^2, 1^2, 1^2 )
  sizeCCsquared[i,]<-sizeCC[i,2:ncol(sizeCC)]^2
  #Total all the squared CC sizes. 
  #eg 4^2 + 4^2 + 5^2 + 1^2 + 1^2 + 1^2
  sumCCSizesSquared<-sum(sizeCCsquared[i,],na.rm=TRUE)
  
  AvNoConnectedNeighbours<-sumCCSizesSquared/sumCCsizes
  AvNoConnectedNeighboursList<-c(AvNoConnectedNeighboursList,AvNoConnectedNeighbours)
}

#Line up all those means with the frame they came from
averageNumberOfConnectedNeighbours<-data.frame(AvNoConnectedNeighboursList)

write.csv(averageNumberOfConnectedNeighbours,paste(args[1],args[2],"/",args[2],"_averageNumberOfConnectedNeighbours.csv",sep=""))
#write.csv(averageNumberOfConnectedNeighbours,paste("trackmaterun-bigcellmanymitos2_averageNumberOfConnectedNeighbours.csv",paste=""))

print(paste("averageNumberOfConnectedNeighbours for",args[2],"written",sep=" ")) 
