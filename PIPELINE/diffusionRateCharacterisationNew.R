#In order to characterise the diffusion rate of mitochondria in experimental data (MitoGFP and (FRIENDLY?))
#Finding the 10 smallest convex hulls, with frame duration over 10.

#Variable Setting 
numberofsmallestCHwewant<-10
gatheredSuccessfulAreasAllVideos<-c(0:numberofsmallestCHwewant)
#^this resets the data frame for gathering final successful areas, do not reset as you alter the currentvideo name
#if truly automating this, would make an output file of 10 smallest CHs for ALL videos, then collate them afterwards.

#MitoGFP vids
#ScaleAndCrop-100frames3		
#ScaleAndCrop-goodvid120
#ScaleAndCrop-nice120
#ScaleAndCrop-zoomedvid4outfocus
#ScaleAndCrop-bigcellmanymitos
#ScaleAndCrop-manycells120
#ScaleAndCrop-onefourzoom
#ScaleAndCrop-zoomedvideo2

currentvideo<-"trackmaterun-nice120"
directory<-(paste("/Users/d1795494/Documents/PIPELINE/MitoGFP-TRACKMATERUNS/",currentvideo,sep=""))
setwd(directory)

pullSmallAreas<-function(ordereddata){
  count<-0
  successfulAreas<-c()
  successfulTrajectories<-c()
  numberOfFramesInSuccessfulTrajectory<-c()
  for(i in 1:nrow(ordereddata)){
    if (count < numberofsmallestCHwewant){
      #pick out trajectory ID of current area we're looking at
      currentTrajectory<-read.csv(paste(directory,"/all_trajectories/trajectory",ordereddata[i,2],".csv",sep=""),header=FALSE)
      #If the current trajectory has more than 10 rows, continue. 
      if(nrow(currentTrajectory) >= 10){
        count<-count+1
        #Pick out the area covered by that 'successful' trajectory, store it
        successfulAreas<-c(successfulAreas,ordereddata[i,3])
        #Store its name
        successfulTrajectories<-c(successfulTrajectories,ordereddata[i,2])
        #Store the number of frames it has in it. 
        numberOfFramesInSuccessfulTrajectory<-c(numberOfFramesInSuccessfulTrajectory,nrow(currentTrajectory))
      }
    }
  }
  successfulAreasandFrames <- list("areas" = successfulAreas, "frames" = numberOfFramesInSuccessfulTrajectory, "trajectory"= successfulTrajectories)
  return(successfulAreasandFrames)
}

forOneVideo<-function(currentvideo){
  #Read convex hull area list for that specific video
  CHareaFile<-read.csv(paste("areaandlogarealist",currentvideo,".csv",sep=""))
  
  #Sort convex hull area and log area data frame by area, smallest to largest
  ordereddata<-CHareaFile[order(CHareaFile$arealist),]
  
  #Loop through the areas, from top to bottom (smallest to largest), stopping to query whether
  #the correspoding trajectory file has more than 10 rows. If it doesn't, pass onto the next 
  #area (trajectory), but if it does store it in a list and add 1 to a count. Stop at count=10.
  successfulAreasandFrames<-pullSmallAreas(ordereddata)
  print(successfulAreasandFrames)
  
  #add them to the data.frame collating that videos outputs of area.
  write.csv(data.frame(successfulAreasandFrames),paste(numberofsmallestCHwewant,"smallestCHwithmorethan10frames-",currentvideo,".csv",sep=""))
  return(successfulAreasandFrames)
}

successfulAreasandFrames<-forOneVideo(currentvideo)


#Now we have the trajectory IDs that have the smallest convex hulls (ie proably area moving in a diffusive manner), we can use them to calculate the Mean Squared Displacement (MSD),
#Which will lead us to the diffusion rate of the mitochondria.

#OR
#I have gone throuch 2 different MtGFP videos, and from each have chosen 3 mitos that don't move far, and look to be moving diffusively
#Git their xml print outs, ran them through the parse.sh file

#these are:

directory<-(paste("/Users/d1795494/Documents/PIPELINE/MitoGFP-TRACKMATERUNS/"))
setwd(directory)
onefour1<-"trackmaterun-onefourzoom/C2-MiyoGFPjustover5min1-4zoomADJUSTEDCROPPED-ISOLATEDMITO1.xml.csv"
onefour2<-"trackmaterun-onefourzoom/C2-MiyoGFPjustover5min1-4zoomADJUSTEDCROPPED-ISOLATEDMITO2.xml.csv"
onefour3<-"trackmaterun-onefourzoom/C2-MiyoGFPjustover5min1-4zoomADJUSTEDCROPPED-ISOLATEDMITO3.xml.csv"

nice1201<-"trackmaterun-nice120/C2-nice120ADJUSTEDCROPPED-ISOLATEDMITO1.xml.csv"
nice1202<-"trackmaterun-nice120/C2-nice120ADJUSTEDCROPPED-ISOLATEDMITO2.xml.csv"
nice1203<-"trackmaterun-nice120/C2-nice120ADJUSTEDCROPPED-ISOLATEDMITO3.xml.csv"

goodvid1201<-"trackmaterun-goodvid120/C2-goodvid120ADJUSTEDCROPPED-ISOLATEDMITO1.xml.csv"
goodvid1202<-"trackmaterun-goodvid120/C2-goodvid120ADJUSTEDCROPPED-ISOLATEDMITO2.xml.csv"
goodvid1203<-"trackmaterun-goodvid120/C2-goodvid120ADJUSTEDCROPPED-ISOLATEDMITO3.xml.csv"

#MSD involves computing the squared displacement from the initial point (x(t) - x(0))^2 for a bunch of different times t, averaged over trajectories.
#Gradient of this with time is diffusion rate.
#In a given video all frame intervals will be the same number of seconds. Say that number of seconds is dt. 
#Then if a trajectory starts in frame i we have x(0) = position in frame i, x(dt) = position in frame i+1, x(2dt) = position in frame i+2, etc
#Another trajectory might start in frame j in the same video, so x(0) for that one would be position in frame j, x(dt) = position in frame j+1, et c
#Take the average (x(dt) - x(0))^2 across all trajectories, and the average (x(2dt) - x(0))^2, and so on, to build the MSD profile with time

#But if doing from isolated mitos, do this:
listOfTrajectoryIDs<-c(onefour1,onefour2,onefour3,nice1201,nice1202,nice1203,goodvid1201,goodvid1202,goodvid1203)
namesOfTrajectoryIDs<-c("onefour1","onefour2","onefour3","nice1201","nice1202","nice1203","goodvid1201","goodvid1202","goodvid1203")
currentTrajectory<-read.delim(listOfTrajectoryIDs[1])
colnames(currentTrajectory)<-c("originalCount","Trajectory","Frame","x","y","z","m0","m1","m2","m3","m4","NPscore")

#Pulls the x or y value from the first position of the mito in that trajectory 
x0<-currentTrajectory[1,]$x
y0<-currentTrajectory[1,]$y

#Loops through all time points in the current trajectory, working with each one as it goes. 
#sdisp= 'squared displacement'

squaredDisplace<-function(currentTrajectory){
  squareddisplacements<-c()
  x0<-currentTrajectory[1,]$x
  y0<-currentTrajectory[1,]$y
  
  for (t in 2:nrow(currentTrajectory)){
    #This loops through dts, so dt, 2dt, 3dt etc for one trajectory. 
    #For x
    xdt<-currentTrajectory[t,]$x
    sdispX<-(xdt - x0)^2 
    
    #For y
    ydt<-currentTrajectory[t,]$y
    sdispY<-(ydt - y0)^2 
    
    #Both
    sqrddisp<-sdispX+sdispY
    
    squareddisplacements<-c(squareddisplacements,sqrddisp)
  }
  squareddisplacementslist<-list("trajectory"=currentTrajectory[1,]$Trajectory, "squareddisplacements"=squareddisplacements )
  return(squareddisplacementslist)
}


trajectoryWithMostFrames<-function(){
  theMostFrames<-0
  for(j in 1:length(listOfTrajectoryIDs)){
    currentFile<-read.delim(listOfTrajectoryIDs[j])
    if (max(currentFile$Frame) > theMostFrames){
      theMostFrames<-max(currentFile$Frame)
    }
  }
  return(theMostFrames)
}


preMSDs<-function(listOfTrajectoryIDs){
  theMostFrames<-trajectoryWithMostFrames()
  #Making an empty data frame, of row length=trajectory number, and col length= longest frame length of any of the trajectories
  sqrdDispAllTrajs<-data.frame(matrix(NA, nrow = length(listOfTrajectoryIDs), ncol = theMostFrames))

  #loop through trajectories
  for(m in 1:length(listOfTrajectoryIDs)){
    currentTrajectory<-read.delim(listOfTrajectoryIDs[m])
    sqrdDispCurrentTraj<-squaredDisplace(currentTrajectory)
    #print(sqrdDispCurrentTraj$squareddisplacements)
  
    
    #Because all the trajectories have different numbers of frames associated with them, we pad their displacement lists before averaging. 
    sqrdDispCurrentTrajFix<-pad(sqrdDispCurrentTraj$squareddisplacements,theMostFrames)
    
    sqrdDispAllTrajs[m,]<-sqrdDispCurrentTrajFix
  }
  return(sqrdDispAllTrajs)
}


MeanSDs<-function(){
  sqrdDispAllTrajs<-preMSDs(listOfTrajectoryIDs)
  alldtMeans<-c()
  for(i in 1:ncol(sqrdDispAllTrajs)){
    #Average all squareddisplacements for all trajectories, for the time they align with. ie 1dt, 2dt, 3dt.
    dtMean<-mean(sqrdDispAllTrajs[,i],na.rm=TRUE)
    alldtMeans<-c(alldtMeans,dtMean)
  }
  return(alldtMeans)
}

#write.csv(sqrdDispAllTrajs,"allSquaredDisplacements.csv")
#write.csv(alldtMeans,"allMeanSquaredDisplacements.csv")


#Plotting Squared Displacement over time
#time conversion- all the three videos I used have a time interval of 1.93818
#Needs to be individual to each video. 
timesequence<-seq(1.93818,(theMostFrames*1.93818),1.93818)
x=timesequence[0:theMostFrames]
y=alldtMeans
plot(x,y,xlab = "Time(seconds)", ylab="SD (overallsuccessfulTrajs)")

mod <- lm(y ~ x)
abline(mod)
coef(mod)[2]
#0.00880894 
#Not quite correct as should quit averaging while they all share timepoints. eg up to frame 23.

#All individually
sqrdDispAllTrajs<-preMSDs()


#You can do the averaging before or after estimating diffusion rate so you can do either.
#So here we will create a list of the gradients, then average them
#onefour1
y=unlist(sqrdDispAllTrajs[1,])
png("trackmaterun-onefourzoom/onefourzoom-ISOLATEDMITO1-MSD.png")
mod <- lm(y ~ x)
plot(x,y,xlab = "Time(seconds)", ylab="Squared Displacement",main=paste(namesOfTrajectoryIDs[1],"\n","coeff estimate (slope) =",coef(mod)[2],sep=""))
abline(mod)
coef(mod)[2]
dev.off()
#0.1168168



#onefour2
y=unlist(sqrdDispAllTrajs[2,])
png("trackmaterun-onefourzoom/onefourzoom-ISOLATEDMITO2-MSD.png")
mod <- lm(y ~ x)
plot(x,y,xlab = "Time(seconds)", ylab="Squared Displacement",main=paste(namesOfTrajectoryIDs[2],"\n","coeff estimate (slope) =",coef(mod)[2],sep=""))
abline(mod)
coef(mod)[2]
dev.off()
#0.008294754  

#onefour3
y=unlist(sqrdDispAllTrajs[3,])
png("trackmaterun-onefourzoom/onefourzoom-ISOLATEDMITO3-MSD.png")
mod <- lm(y ~ x)
plot(x,y,xlab = "Time(seconds)", ylab="Squared Displacement",main=paste(namesOfTrajectoryIDs[3],"\n","coeff estimate (slope) =",coef(mod)[2],sep=""))
abline(mod)
coef(mod)[2]
dev.off()
#0.00631964   

#nice1201
y=unlist(sqrdDispAllTrajs[4,])
png("trackmaterun-nice120/nice120-ISOLATEDMITO1-MSD.png")
mod <- lm(y ~ x)
plot(x,y,xlab = "Time(seconds)", ylab="Squared Displacement",main=paste(namesOfTrajectoryIDs[4],"\n","coeff estimate (slope) =",coef(mod)[2],sep=""))
abline(mod)
coef(mod)[2]
dev.off()
#0.01426927   

#nice1202
y=unlist(sqrdDispAllTrajs[5,])
png("trackmaterun-nice120/nice120-ISOLATEDMITO2-MSD.png")
mod <- lm(y ~ x)
plot(x,y,xlab = "Time(seconds)", ylab="Squared Displacement",main=paste(namesOfTrajectoryIDs[5],"\n","coeff estimate (slope) =",coef(mod)[2],sep=""))
abline(mod)
coef(mod)[2]
dev.off()
#0.05288481  

#nice1203
y=unlist(sqrdDispAllTrajs[6,])
png("trackmaterun-nice120/nice120-ISOLATEDMITO3-MSD.png")
mod <- lm(y ~ x)
plot(x,y,xlab = "Time(seconds)", ylab="Squared Displacement",main=paste(namesOfTrajectoryIDs[6],"\n","coeff estimate (slope) =",coef(mod)[2],sep=""))
abline(mod)
coef(mod)[2]
dev.off()
#0.003354107  

#goodvid1201
y=unlist(sqrdDispAllTrajs[7,])
png("trackmaterun-goodvid120/goodvid120-ISOLATEDMITO1.png")
mod <- lm(y ~ x)
plot(x,y,xlab = "Time(seconds)", ylab="Squared Displacement",main=paste(namesOfTrajectoryIDs[7],"\n","coeff estimate (slope) =",coef(mod)[2],sep=""))
abline(mod)
coef(mod)[2]
dev.off()
#0.001677587  

#goodvid1202
y=unlist(sqrdDispAllTrajs[8,])
png("trackmaterun-goodvid120/goodvid120-ISOLATEDMITO2.png")
mod <- lm(y ~ x)
plot(x,y,xlab = "Time(seconds)", ylab="Squared Displacement",main=paste(namesOfTrajectoryIDs[8],"\n","coeff estimate (slope) =",coef(mod)[2],sep=""))
abline(mod)
coef(mod)[2]
dev.off()
#0.001970627 

#goodvid1203
y=unlist(sqrdDispAllTrajs[9,])
png("trackmaterun-goodvid120/goodvid120-ISOLATEDMITO3.png")
mod <- lm(y ~ x)
plot(x,y,xlab = "Time(seconds)", ylab="Squared Displacement",main=paste(namesOfTrajectoryIDs[9],"\n","coeff estimate (slope) =",coef(mod)[2],sep=""))
abline(mod)
coef(mod)[2]
dev.off()
#0.1502016 

#TO GET OVERALL DIFFUSION RATE, we plot the MSDs over time, and take the gradient.
msdList<-alldtMeans[1:23]
#or
msdList2<-c()
for(i in 1:23){
  msdList2<-c(msdList2,mean(sqrdDispAllTrajs[,i]))
}
#these two give the same thing

#PLOT
x=timesequence[0:23]
y=msdList
mod <- lm(y ~ x)
plot(x,y,xlab = "Time(seconds)", ylab="Mean Squared Displacement",main=paste("Mean Squared Displacement of","\n","9 mitochondria from 3 videos","\n","coeff estimate (slope) = ",coef(mod)[2],sep=""))
abline(mod)
coef(mod)[2]
#Diffusion Rate estimate: 0.02634334 




#Pad function import, don't reinvent the wheel. source(https://github.com/kevinushey/Kmisc/blob/master/R/pad.R)
#Pads ur list with NAs

pad <- function(x, n) {
  
  if (is.data.frame(x)) {
    
    nrow <- nrow(x)
    attr(x, "row.names") <- 1:n
    for( i in 1:ncol(x) ) {
      x[[i]] <- c( x[[i]], rep(NA, times=n-nrow) )
    }
    return(x)
    
  } else if (is.list(x)) {
    if (missing(n)) {
      max_len <- max( sapply( x, length ) )
      return( lapply(x, function(xx) {
        return( c(xx, rep(NA, times=max_len-length(xx))) )
      }))
    } else {
      return( lapply(x, function(xx) {
        if (n > length(xx)) {
          return( c(xx, rep(NA, times=n-length(xx))) )
        } else {
          return(xx)
        }
      }))
    }
  } else if (is.matrix(x)) {
    
    return( rbind( x, matrix(NA, nrow=n-nrow(x), ncol=ncol(x)) ) )
    
  } else {
    
    return( c( x, rep(NA, n-length(x)) ) )
    
  }
  
}







#Alternatively, could use sqrt((X1 - X2)^2 + (Y1 - Y2)^2) (? waiting for advice from Iain)

#' Calculates the Mean Squared Displacement for a trajectory
#' Borrowed and adapted from the source code from computeMSD in the flowcatchR package
#'  sx is the x axis positions along the trajectory
#'  sy is the y axis positions along the trajectory
#'  until is how many points should be included in the Mean Squared Displacement curve (im using this as as many timepoints I want
#'  to go over, ie nrow(currentTrajectory))
#' returns msd.t A numeric vector containing the values of the MSD

computeMSD <- function(sx,sy,until=4)
{
  msd.t <- rep(0,until)
  msd.t<-c()
  for (dt in 1:until)
  {
    #Generates a vector of values, of x values from 1+t:length(sx) - 1:(length(sx)-t), 
    #basically, every comparison between every coordinate in the list
    #so eg when dt=1 and length(sx)=9, it does sx[2:9]-sx[1:8]
    #      when dt=2 and length(sx)=9, it does sx[3:9]-sx[1:7]
    #      ....
    #      when dt=8 and length(sx)=9, it does sx[9:9]-sx[1:1]
    #      when dt=9 and length(sx)=9, it does sx[10:9]-sx[1:0], and sx[10:9] turns up Na and a value, which is why the na.omit is included
    displacement.x <- as.vector(na.omit(sx[(1+dt):length(sx)]) - sx[1:(length(sx)-dt)])
    displacement.y <- as.vector(na.omit(sy[(1+dt):length(sy)]) - sy[1:(length(sy)-dt)])
    sqrdispl <- (displacement.x^2 + displacement.y^2)
    #msd.t[dt] <- mean(sqrdispl)
    msd.t<-c(msd.t,mean(sqrdispl))
  }
  return(msd.t)
}


sx[(1+dt):length(sx)]) - sx[1:(length(sx)-dt)])