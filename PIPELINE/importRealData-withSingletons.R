#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

#This script is designed for getting graphs and well-formatted tables from one microscope video, that has already been run through the relevant 'summaryStatisticsGenerationForVideoData.nb' Mathematica Script

setwd(paste(args[1],args[2],sep=""))

#For outputs that are three columns (Frame,Value) and import easily
#With singletons
videoname<- args[2]

nameF<-paste("",videoname,"_F.csv",sep="")
inputFrameList<- read.csv(nameF,header=TRUE)

nameCC_WS<- paste("",videoname,"_CC_WS.csv",sep="")
noConnectedComponentsWS<-read.csv(nameCC_WS, header=TRUE)
#Edge no should be exactly the same as historical networks
nameEN_WS<- paste("",videoname,"_EN_WS.csv",sep="")
noEdgesWS<-read.csv(nameEN_WS, header=TRUE)
nameNN_WS<- paste("",videoname,"_NN_WS.csv",sep="")
noNodesWS<-read.csv(nameNN_WS, header=TRUE)
nameMD_WS<- paste("",videoname,"_MaxD_WS.csv",sep="")
maxDegreeWS<-read.csv(nameMD_WS,header=TRUE)
###nameMBC_WS<- paste("",videoname,"_MaxBC_WS.csv",sep="")
###maxBCWS<-read.csv(nameMBC_WS,header=TRUE)

#For outputs that have had to come through ./NBCfilesmerging, so have been 'cat' together- but are still only one file (although they dont have a column title)
#15-7-20 I'm not using betweeness centrality anymore, although might want to include in thesis, but won't matter there that it doens't include singletons. So commenting these sections out.

#Maximum Normalised Betweeness Centrality with singletons
###nameMaxNBC<- paste("",videoname,"_mergedMaxNBCfile_WS.csv",sep="")
###maxNBC<-read.csv(nameMaxNBC, header=FALSE)
###maxNBC<-data.frame(inputFrameList, maxNBC)
###write.csv(maxNBC, paste(videoname,"_maxNBCformatted_WS.csv",sep=""))

#Mean Normalised Betweeness Centrality with singletons 
###nameMeanNBC<- paste("",videoname,"_mergedMeanNBCfile_WS.csv",sep="")
###meanNBC<-read.csv(nameMeanNBC, header=FALSE)
###meanNBC<-data.frame(inputFrameList, meanNBC)
###write.csv(meanNBC, paste(videoname,"_meanNBCformatted_WS.csv",sep=""))


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
nameSCC<-paste("",videoname,"_SCC_WS.csv",sep="")
sizeConnectedComponents<-read.csv(nameSCC,header=TRUE)
sizeConnectedComponents$V1<-gsub("[\\{}]","",sizeConnectedComponents$V1)
#colnames(sizeConnectedComponents)<-c("Frame","V1")
x<-data.frame(inputFrameList,sizeConnectedComponents, stringsAsFactors=FALSE)
name<-"SCC_WS"
#Invisible prevents whole tables being printed out into terminal
invisible(createDataFrame())
outputfilename<-paste("",videoname,"_",name,".csv", sep ="")
cellSplit_sizeConnectedComponents<-read.csv(outputfilename,header=TRUE)

#Degree Values
nameD<-paste("",videoname,"_D_WS.csv",sep="")
degreeValue<-read.csv(nameD,header=TRUE)
degreeValue$V1<-gsub("[\\{}]","", degreeValue$V1)
#colnames(degreeValue)<-c("V1")
x<-data.frame(inputFrameList,degreeValue)
name<-"D_WS"
invisible(createDataFrame())
outputfilename<-paste("",videoname,"_",name,".csv", sep ="")
cellSplit_degreeValue<-read.csv(outputfilename,header=TRUE)

#Betweeness Values
###nameBC<-paste("",videoname,"_BC_WS.csv",sep="")
###betweenessValue<-read.csv(nameBC,header=TRUE)
###betweenessValue$V1<-gsub("[\\{}]","", betweenessValue$V1)
#colnames(betweenessValue)<-c("V1")
###x<-data.frame(inputFrameList,betweenessValue)
###name<-"BC_WS"
###invisible(createDataFrame())
###outputfilename<-paste("",videoname,"_",name,".csv", sep ="")
###cellSplit_betweenessValue<-read.csv(outputfilename,header=TRUE)

#Normalised Betweeness Values
###nameNBC<-paste(args[2],"_mergedNBCfile_WS.csv",sep="")
###normBetweenessValue<-read.table(nameNBC,header=FALSE)
###normBetweenessValue$V1<-gsub("[\\{}]","", normBetweenessValue$V1)
#colnames(betweenessValue)<-c("V1")
###x<-data.frame(inputFrameList,normBetweenessValue)
###name<-"normBC_WS"
###invisible(createDataFrame())
###outputfilename<-paste("",videoname,"_",name,".csv", sep ="")
###cellSplit_normBetweenessValue<-read.csv(outputfilename,header=TRUE)

AllSpeeds = list.files(pattern="*.csv")
for (i in 1:length(AllSpeeds)){
  assign(AllSpeeds[i], as.data.frame(AllSpeeds[i], header=TRUE))
}

#Size of largest Connected Components
#This list is generated here as it just needs to take the first column of the connected component size table- the sizes are ordered in their lists already, allowing this.
listLargestConnectedComponents<- subset(cellSplit_sizeConnectedComponents,select=c( "Frame","V1" ))
write.csv(listLargestConnectedComponents,paste(videoname,"_LSCC_WS.csv",sep=""))
