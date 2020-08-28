#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

filename<-args[2]
workingdirectory<-paste(args[1],args[2],sep="")

#Tack this onto the end of the production script
#For videos these are [1]-/home/gadmin/Documents/Joanna/MitoGFP/ or FRIENDLY/ or Msh1/ [2]Scaled-zoomedvid2 etc

createStatHistograms<-function(){
  setwd(workingdirectory)
  stattable<-stattable[,-c(1,2)]
  printAs <- paste("(",filename,") all frames","\n",statname,"Distribution",sep=" ")
  jpeg(paste(statname,"plot.jpg",sep=" "))
    hist(as.numeric(t(stattable)), col=colourr,main=printAs,xlab=statname)
  dev.off()
}

createSingleHistograms <- function() {
  stattable<-stattable[,-c(1,2)]
  for (i in 1:as.numeric(args[3])){
    data <- as.numeric(stattable[i,])
    saveAs <-paste("(",filename,")",statname,"Frame",i,sep=" ")
    png(paste(workingdirectory,"/histograms/",saveAs,sep=""))
    printAs <- paste(statname,"Frame",i,"plot.jpg",sep=" ")
    hist(data, xlab= statname, main = printAs,col=colourr)
    dev.off()
  }
}

createLoggedTables<-function(){
  setwd(workingdirectory)
  colvector<-c()
  stattable<-stattable[,-c(1,2)]
  out<-matrix(NA,nrow=nrow(stattable),ncol=ncol(stattable))
  for (i in 1:nrow(stattable)){
    for (j in 1:ncol(stattable)){
      colvector<-c(colvector,log(stattable[i,j]))
    }
    out[i,]<-c(colvector)
    colvector<-c()
  }
  saveAs <-paste("(",filename,") Logged",statname,sep=" ")
  hereok<-write.csv(out, paste(saveAs,".csv",sep=""))
}

createLogStatHistograms<-function(){
  setwd(workingdirectory)
  stattable<-stattable[,-c(1,2)]
  printAs <- paste("(",filename,") all frames","\n","log",statname,"Distribution",sep=" ")
  jpeg(paste("logged",statname,"plot.jpg",sep=" "))
  hist(as.numeric(log(t(stattable))), col=colourr,main=printAs,xlab = paste("Log (",statname,")",sep=""))
  dev.off()
}

statname<- "Betweeness Centrality"
stattable<-read.csv(paste(args[1],args[2],"/",args[2],"_BC.csv",sep=""))
maxtable<-read.csv(paste(args[1],args[2],"/",args[2],"_MaxBC.csv",sep=""))
colourr<-"lightblue"
createStatHistograms()
createSingleHistograms()
createLoggedTables()
createLogStatHistograms()


statname<-"Degree"
stattable<-read.csv(paste(args[1],args[2],"/",args[2],"_D.csv",sep=""))
maxtable<-read.csv(paste(args[1],args[2],"/",args[2],"_MaxD.csv",sep=""))
colourr<-"pink"
createStatHistograms()
createSingleHistograms()
createLoggedTables()
createLogStatHistograms()

statname<-"Size of Connected Components"
stattable<-read.csv(paste(args[1],args[2],"/",args[2],"_SCC.csv",sep=""))
maxtable<-read.csv(paste(args[1],args[2],"/",args[2],"_LSCC.csv",sep=""))
colourr<-"lightgreen"
createStatHistograms()
createSingleHistograms()
createLoggedTables()
createLogStatHistograms()