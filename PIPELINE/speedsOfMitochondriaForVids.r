#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

#Terminal Filesplitter
#Change: directory, number of i, Filename
#USE ./FILESPLITTER.SH but make sure to edit it to the correct directory change and results filename before running it.

#Results file needs to go through file splitter previous to this^^^

#set the working directory to where all results files and all_frames, all_speeds files are

workingdirectory<-paste(args[1],args[2],sep="")


getAllFrames <- function() {
  setwd(paste(workingdirectory,"/all_frames",sep=""))
  allFrames = list.files(pattern="*.csv")
  for (i in 1:(length(allFrames)-1)) {
    assign(allFrames[i], read.csv(allFrames[i], header=FALSE))  
  }
  return (allFrames)
}
#Speed is distance moved per unit time. Each unit time between frames was different, therefore it reads in as a vraiable for each video. eg in nice120ADJUSTED = 1.93818 secs between frame
#This is gathered from the 'Frame Interval' statistic at the bottom of the dialogue box from Image-> show info. 
#This is validated by the difference between deltaT times in the OME metadata set.
#The distance is the coodinate of the particle in the frame particle Tracker saw, so will be however many pixels the mito moved. 
#Can calculate how many pixels equal what real distance, and do a calculation from there.
#Dividing the pixels distance by the resolution. The resolution is pixels per micron, so divide the number of pixels by how many pixels are in a micron to get the micron value.
#This get you distance in microns

calculateSpeed <- function(X1, Y1, X2, Y2) {
  time <-  as.numeric(args[4])
  resolution<- as.numeric(args[5])
  #I have taken the 120 frames Video Data Frame Interval and adjusted it for a simulation containing 200 frames.
  #eg: 1.93818 Frame Interval*120 Frame = 232.58s, therefore 232.58s/200 Frames = 1.1629 Frame Interval.
  #THIS IS ONLY FOR SIMULATIONS ^ VIDEOS HAVE THEIR OWN SET SPEED
  #To use these in the euclidean distance calc, you want to turn them all into microns before you use them in the equation, so we're redefining them here
  #the number we are dividing by is the resolution in pixels per micron. So we're dividing pixel (x1,X2,Y1,Y2) by pixels per micron, to get microns.
  X1<- X1
  X2<- X2
  Y1<- Y1
  Y2<- Y2
  eucdist<-sqrt((X1 - X2)^2 + (Y1 - Y2)^2)
  eucdist<-eucdist/resolution
  speed <- (eucdist/time)
  return (speed)
}


getAllSpeedsOfOneFrame <- function(results1, results2) {
  speeds <- c()
  mitochondria <- c()
  
  for (k in 1:nrow(results1)) {
    for (r in 1:nrow(results2)) {
      if (results1[k,2] == results2[r,2]) {
        #if they are the same trajectory from one frame to the next, calculate their speed
        X1 <- results1[k,4]
        Y1 <- results1[k,5]
        X2 <- results2[r,4]
        Y2 <- results2[r,5]
        speed <- calculateSpeed(X1, Y1, X2, Y2)
        speeds <- c(speeds, speed) 
        mitochondria <- c(mitochondria, results1[k,2])
      }
    }
  }
  x <- data.frame(mitochondria, speeds)
  return (x)
}


writeSpeedsOfAllMitoPerFrame <- function() {
  
  allSpeedsAllFramesList<-c()
  allFrames <- getAllFrames()
  
  for (i in 1:(length(allFrames)-1)) {
    results1 <- paste("frame", i-1 ,".csv", sep = "")
    results1 <- read.delim(results1, header=FALSE)
    results2 <- paste("frame", i ,".csv", sep = "")
    results2 <- read.delim(results2, header=FALSE)
    
    data <- getAllSpeedsOfOneFrame(results1, results2)
    
    allSpeedsAllFramesList<-c(allSpeedsAllFramesList,data$speeds)

    FileName <- paste("Speedofallmitosinframe", i ,".csv", sep = "")
    write.csv(data, file = paste(workingdirectory,"/all_speeds/",FileName,sep=""), row.names=FALSE)
  }
  averageSpeedAllFrames<-mean(allSpeedsAllFramesList)
  write.csv(averageSpeedAllFrames, file = paste(workingdirectory,"/averageOverAllSpeedsAllFrames.csv",sep=""), row.names=FALSE)
}

#Call This, which uses the three functions above

writeSpeedsOfAllMitoPerFrame()

#Then move these all into a folder called AllSpeeds
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  #SpeedHistograms
  
  Video<-(args[2])

  getAllSpeeds<- function() {
    setwd(paste(workingdirectory,"/all_speeds",sep=""))
    AllSpeeds = list.files(pattern="*.csv")
    for (i in 1:length(AllSpeeds)){
      assign(AllSpeeds[i], as.data.frame(AllSpeeds[i], header=TRUE))
    }
    return(AllSpeeds)
  }

createSpeedHistograms <- function() {
  AllSpeeds <- getAllSpeeds()
  for (i in seq(from=1,to=args[6])){
    histogramSourceFileName <- paste("Speedofallmitosinframe",i,".csv", sep="")
    data <- read.csv(histogramSourceFileName)
    saveAs <-paste("Histogram of Speeds in Frame",i,".png", sep="")
    png(paste(workingdirectory,"/histograms/",saveAs,sep=""))
    printAs <- paste("(",Video,")","Speeds in Frame",i,sep=" ")
    #printAs <- paste("Speeds in Frame",i,sep=" ")
    hist((data$speeds), xlab= "Speeds (um/sec)", main = printAs,col="lightgoldenrod")
    dev.off()
  }
}

createSpeedHistograms()



createAllSpeedHistograms<-function(){
  allspeedslist<-c()
  printAs <- paste("(",Video,")","AllSpeeds",sep=" ")
  png(paste(workingdirectory,"/histograms/",printAs,".png",sep=""))
  for (i in 1:args[6]){
    setwd(paste(workingdirectory,"/all_speeds/",sep=""))
    d1<- read.csv(paste("Speedofallmitosinframe",i,".csv",sep=""))
    allspeedslist<-c(allspeedslist,d1$speeds)
    hist(allspeedslist, xlab="speed (um/sec)",col="gold")
    legend("topright", c("allspeeds, all mitos over all frames"), lwd=10)
  }
  dev.off()
}

createAllSpeedHistograms()


#################### logged speed histograms ################################

createlogSpeedHistograms <- function() {
  AllSpeeds <- getAllSpeeds()
  for (i in seq(from=1,to=args[6])){
    histogramSourceFileName <- paste("Speedofallmitosinframe",i,".csv", sep="")
    data <- read.csv(histogramSourceFileName)
    saveAs <-paste("Histogram of Logged Speeds in Frame",i,".png", sep="")
    png(paste(workingdirectory,"/histograms/",saveAs,sep=""))
    printAs <- paste("(",Video,")","Logged Speeds in Frame",i,sep=" ")
    #printAs <- paste("Speeds in Frame",i,sep=" ")
    hist(log(data$speeds), xlab= "Log(speed) (um/sec)", main = printAs,col="plum")
    dev.off()
  }
}

createlogSpeedHistograms()



createAlllogSpeedHistograms<-function(){
  allspeedslist<-c()
  printAs <- paste("(",Video,")","AllLoggedSpeeds",sep=" ")
  png(paste(workingdirectory,"/histograms/",printAs,".png",sep=""))
  for (i in 1:args[6]){
    setwd(paste(workingdirectory,"/all_speeds/",sep=""))
    d1<- read.csv(paste("Speedofallmitosinframe",i,".csv",sep=""))
    allspeedslist<-c(allspeedslist,d1$speeds)
    hist(log(allspeedslist), xlab="Log(speed) (um/sec)", col="purple")
    legend("topleft", c("logallspeeds, all mitos over all frames"), lwd=10)
  }
  dev.off()
}

createAlllogSpeedHistograms()
