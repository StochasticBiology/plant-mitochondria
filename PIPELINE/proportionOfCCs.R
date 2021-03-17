#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

setwd(args[1])
print("reading")

#was reading in with read.table, giving the characteristic rows with no column seperation. Code built around that. For netwroks with no early frames, needed to modify- used readLines
#Could have use read.delim but code structured for line by line use. 
SCCfileX<-readLines(paste(args[1],args[2],"/",args[2],"_SCCreformat2.csv",sep=""))
SCCfile<-data.frame(SCCfileX)
colnames(SCCfile)<-"V1"
#This works!!! because you cannot have 0s in the list of values, but you also can't have Nas in the list you want to total to give you a value to decide by for the proportions,
#So you need to create a list with 0's to overcome the 'spiky' format of the mathematica outputs, but ALSO have a format with NAs so you do not include excessive 0 values into your violin plots. 

fixingLengthsAndFormat<-function(){
  #Makes a matrix of NAs, fills it with numbers when values occur in the input file. USes lengthlongestsixzes to find length of line, and 
  #fixandaddingNAs to hold the numerical values and fill gaps with NAs
  maxlength<-lengthLongestSizes()
  out<-matrix(NA,nrow=nrow(SCCfile),ncol=maxlength)
  for(i in 1:nrow(SCCfile)){
    list<-fixandaddingnas(i)
    out[i,]<-c(list)
  }
  finalDataFrame<- as.data.frame(out,header=FALSE)
  return(finalDataFrame)
}

fixandaddingnas<-function(i){
#Fixes the strings into numeric values, and adds NA values into any file lines that are not of the max length. 
  asCharacterList<-as.character(SCCfile$V1[i])
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

lengthLongestSizes<-function(){
#Finds the length of the longest string in the SCC file, to make the other strings as long as-> avoiding 'spikey' file format.
  lengths<-c()
  for (i in 1:nrow(SCCfile)){
    asCharacterList<-as.character(SCCfile$V1[i])
    splitList<-strsplit(asCharacterList[1],",")
    listForEditing<-as.numeric(as.character(unlist(splitList)))
    length<-length(listForEditing)
    lengths<-c(lengths,length)
  }
  return(max(lengths))
}


#literally just using these for the zeros- you cant get the total with NA values- the whole outcome is just 'NA'
#Current file has NAs in so need to replace them back with 0s.
replacesNA<-function(finaldataframe){
  SCCfilewithzeros<-data.frame(finaldataframe)
 # for (i in 1:nrow(SCCfilewithzeros)){
  #  for (j in 1:ncol(SCCfilewithzeros)){
      SCCfilewithzeros[is.na(SCCfilewithzeros)] <- 0
   # }
  #}
  #write.csv(SCCfilealtered,file="SCCfilealtered.csv")
  return(SCCfilewithzeros)
}

equateProportions<-function(){
  #Fix format to correct width dataframe filling gaps with NAs
  print("fixing")
  finaldataframe<-fixingLengthsAndFormat()
  #Tunr those Nas to 0s to not mess with calculations
  print("adding 0s")
  SCCfilewithzeros<-replacesNA(finaldataframe)
  #loop through row, find row total
  for (i in 1:nrow(finaldataframe)){
    rowtotal<-sum(SCCfilewithzeros[i,1:ncol(SCCfilewithzeros)])
    #loop through columns, find proportions calculated against rowtotal.
    for (j in 1:ncol(finaldataframe)){
      currentvalue<-finaldataframe[i,j]
      proportionvalue<-currentvalue/rowtotal
      finaldataframe[i,j]<-proportionvalue
    }
  }
  #spits out SCC values into one long list, going along biggest proportions first (first col of everyrow), then next col of every row and so on..
  onelist<- onebiglonglist(finaldataframe)
  write.csv(onelist,file=paste(args[1],args[2],"/",args[2],"_everySCCproportionlonglist.csv",sep=""))
  #Spits SCC proportions out in the right format, as on big dataframe with rows = frames
  write.csv(finaldataframe,file=paste(args[1],args[2],"/",args[2],"_SCCproportions.csv",sep=""))
  #Transforming prop CC using Arcsin Square Root Transform
  transformedmaxpropCC<- pi*asin(sqrt(finaldataframe[,1]))
  write.csv(transformedmaxpropCC,file=paste(args[1],args[2],"/",args[2],"_normSCCproportions.csv",sep=""))
}


onebiglonglist<-function(finaldataframe){
  onelist<-c()
  for(i in 1:ncol(finaldataframe)){
    onelist<-c(onelist,finaldataframe[,i])
  }
  #write.csv(onelist,file=paste("Thisone","longlist.csv",sep="_"))
  return(onelist)
}

equateProportions()

