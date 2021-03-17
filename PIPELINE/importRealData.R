#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

#This script is designed for getting graphs and well-formatted tables from one microscope video, that has already been run through the relevant 'summaryStatisticsGenerationForVideoData.nb' Mathematica Script

setwd(paste(args[1],args[2],sep=""))

#For outputs that are three columns (Frame,Value) and import easily
videoname<- args[2]
nameCC<- paste("",videoname,"_CC.csv",sep="")
noConnectedComponents<-read.csv(nameCC, header=TRUE)
nameEN<- paste("",videoname,"_EN.csv",sep="")
noEdges<-read.csv(nameEN, header=TRUE)
nameNN<- paste("",videoname,"_NN.csv",sep="")
noNodes<-read.csv(nameNN, header=TRUE)
nameMD<- paste("",videoname,"_MaxD.csv",sep="")
maxDegree<-read.csv(nameMD,header=TRUE)
nameMBC<- paste("",videoname,"_MaxBC.csv",sep="")
maxBC<-read.csv(nameMBC,header=TRUE)

nameF<-paste("",videoname,"_F.csv",sep="")
inputFrameList<- read.csv(nameF,header=TRUE)

#For outputs that have had to come through ./NBCfilesmerging, so have been 'cat' together- but are still only one file (although they dont have a column title)

#Maximum Normalised Betweeness Centrality
nameMaxNBC<- paste("",videoname,"_mergedMaxNBCfile.csv",sep="")
maxNBC<-read.csv(nameMaxNBC, header=FALSE)
maxNBC<-data.frame(inputFrameList, maxNBC)
write.csv(maxNBC, paste(videoname,"_maxNBCformatted.csv",sep=""))

#Mean Normalised Betweeness Centrality
nameMeanNBC<- paste("",videoname,"_mergedMeanNBCfile.csv",sep="")
meanNBC<-read.csv(nameMeanNBC, header=FALSE)
meanNBC<-data.frame(inputFrameList, meanNBC)
write.csv(meanNBC, paste(videoname,"_meanNBCformatted.csv",sep=""))



#Three functions called as createDataFrame()
#creating a new data frame from these neatened lists
createDataFrame<-function(){
  nameF<-paste("",videoname,"_F.csv",sep="")
  inputFrameList<- read.csv(nameF,header=TRUE)
  maxlength<-lengthLongestSizes()
  out<-matrix(NA,nrow=nrow(x),ncol=maxlength)
  for(i in 1:nrow(x)){
    list<-fixandaddingzeros(i)
    out[i,]<-c(list)
  }
  finalDataFrame<- as.data.frame(out,header=FALSE)
  finalfinalDataFrame<-data.frame(inputFrameList,finalDataFrame)
  outputfilename<-paste("",videoname,"_",name,".csv", sep ="")
  write.csv(finalfinalDataFrame, file=outputfilename)
  return(finalfinalDataFrame)
}

#fixing values to numbers and adding NAs where values are missing
fixandaddingzeros<-function(i){
  asCharacterList<-as.character(x$V1[i])
  splitList<-strsplit(asCharacterList[1],",")
  listFixed<-as.numeric(as.character(unlist(splitList)))
  maxlength<-lengthLongestSizes()
  if (length(listFixed)<(maxlength)){
    n<-(maxlength)-length(listFixed)
    for (k in 1:n){
      listFixed<-c(listFixed,NA)
    }
    newListFixed<-listFixed
  }else{
    newListFixed<-listFixed
  }
  return(newListFixed)
}

#Find the length of the longest list in the file to match the length of every other list to
lengthLongestSizes<-function(){
  lengths<-c()
  for (i in 1:nrow(x)){
    asCharacterList<-as.character(x$V1[i])
    splitList<-strsplit(asCharacterList[1],",")
    listForEditing<-as.numeric(as.character(unlist(splitList)))
    length<-length(listForEditing)
    lengths<-c(lengths,length)
  }
  return(max(lengths))
}



#For outputs that are lists- to split them into cells and make data frames rectangular by filling in with 0s- to reformat them into a useable form
#Size of Connected Components
nameSCC<-paste("",videoname,"_SCC.csv",sep="")
sizeConnectedComponents<-read.csv(nameSCC,header=TRUE)
sizeConnectedComponents$V1<-gsub("[\\{}]","",sizeConnectedComponents$V1)
#colnames(sizeConnectedComponents)<-c("Frame","V1")
x<-data.frame(inputFrameList,sizeConnectedComponents, stringsAsFactors=FALSE)
name<-"SCC"
#Invisible prevents whole tables being printed out into terminal
invisible(createDataFrame())
outputfilename<-paste("",videoname,"_",name,".csv", sep ="")
cellSplit_sizeConnectedComponents<-read.csv(outputfilename,header=TRUE)

#Degree Values
nameD<-paste("",videoname,"_D.csv",sep="")
degreeValue<-read.csv(nameD,header=TRUE)
degreeValue$V1<-gsub("[\\{}]","", degreeValue$V1)
#colnames(degreeValue)<-c("V1")
x<-data.frame(inputFrameList,degreeValue)
name<-"D"
invisible(createDataFrame())
outputfilename<-paste("",videoname,"_",name,".csv", sep ="")
cellSplit_degreeValue<-read.csv(outputfilename,header=TRUE)

#Betweeness Values
nameBC<-paste("",videoname,"_BC.csv",sep="")
betweenessValue<-read.csv(nameBC,header=TRUE)
betweenessValue$V1<-gsub("[\\{}]","", betweenessValue$V1)
#colnames(betweenessValue)<-c("V1")
x<-data.frame(inputFrameList,betweenessValue)
name<-"BC"
invisible(createDataFrame())
outputfilename<-paste("",videoname,"_",name,".csv", sep ="")
cellSplit_betweenessValue<-read.csv(outputfilename,header=TRUE)

#Normalised Betweeness Values
#Commented out as did not use this statistic, also if network has no edges and therefore no NBC in early frames this errors. 
#nameNBC<-paste(args[2],"_mergedNBCfile.csv",sep="")
#normBetweenessValue<-read.table(nameNBC,header=FALSE)
#normBetweenessValue$V1<-gsub("[\\{}]","", normBetweenessValue$V1)
##colnames(betweenessValue)<-c("V1")
#x<-data.frame(inputFrameList,normBetweenessValue)
#name<-"normBC"
#invisible(createDataFrame())
#outputfilename<-paste("",videoname,"_",name,".csv", sep ="")
#cellSplit_normBetweenessValue<-read.csv(outputfilename,header=TRUE)

AllSpeeds = list.files(pattern="*.csv")
for (i in 1:length(AllSpeeds)){
  assign(AllSpeeds[i], as.data.frame(AllSpeeds[i], header=TRUE))
}

#Size of largest Connected Components
#This list is generated here as it just needs to take the first column of the connected component size table- the sizes are ordered in their lists already, allowing this.
listLargestConnectedComponents<- subset(cellSplit_sizeConnectedComponents,select=c( "Frame","V1" ))
write.csv(listLargestConnectedComponents,paste(videoname,"_LSCC.csv",sep=""))
