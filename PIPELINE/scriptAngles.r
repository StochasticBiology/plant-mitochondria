#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

#Run these next two lines:
vidname<-args[2]
workingd<-(paste(args[1],args[2],sep=""))

retrieveAllFrames<-function(){
  directory<-setwd(paste(workingd,"/all_frames",sep=""))
  listofframes<-list.files(pattern="*.csv")
  #print(listofframes)
  return(listofframes)
}

getCurrentFrames<-function(){
  #print(Sys.time())
  datalist<-c()
  listofframes<-retrieveAllFrames()
  #print(length(listofframes))
  trajectorylist<-c()
  anglelist<-c()
  Alist<-c()
  Blist<-c()
  Clist<-c()
  for (i in 3:length(listofframes)-3){
    framea<- paste("frame", i,".csv", sep = "")
    framea<- read.delim(framea, header=FALSE)
    frameb<- paste("frame", i+1,".csv", sep = "")
    frameb<- read.delim(frameb, header=FALSE)
    framec<- paste("frame", i+2,".csv", sep = "")
    framec<- read.delim(framec, header=FALSE) 
    DATA<-findCoordinates(framea,frameb,framec,j,k,m,trajectorylist,anglelist,Alist,Blist,Clist)
    datalist<-c(datalist,DATA)
    #print(Sys.time())
  }
  write.csv(datalist, file = paste(workingd,"/",vidname,"allanglevector.csv",sep=""), row.names=FALSE)
}




findCoordinates<-function(framea,frameb,framec,j,k,m,trajectorylist,anglelist,Alist,Blist,Clist){
  for(j in 1:nrow(framea)){
    if(framea[j,2] %in% frameb[,2]){
      if(framea[j,2] %in% framec[,2]){
        k<-match(framea[j,2],frameb[,2])
        m<-match(framea[j,2],framec[,2])
        a1<-framea[j,4]
        a2<-framea[j,5]
        b1<-frameb[k,4]
        b2<-frameb[k,5]
        c1<-framec[m,4]
        c2<-framec[m,5]
        degree<-degreesbetweenvectors(a1,a2,b1,b2,c1,c2)
        anglelist<-c(anglelist,degree)
      }
    }
  }
  x<-c(anglelist)
  return(x)
}

#Note:if you don't return the value at the end of a function, it just returns the last value, so here we're just returning the last value, ThetaDegrees
degreesbetweenvectors<-function(a1,a2,b1,b2,c1,c2){
  #(A-B)
  AB1<- (a1-b1)
  AB2<- (a2-b2)
  #(C-B)
  CB1<-(c1-b1)
  CB2<-(c2-b2)
        magAB<-sqrt(((AB1)^2)+((AB2)^2))
        magCB<-sqrt(((CB1)^2)+((CB2)^2))
  dotproduct<-(AB1*CB1)+(AB2*CB2)
  costheta<-dotproduct/(magAB*magCB)
  thetadegrees<-(acos(costheta))*180/pi
}

#Run GetCurrentFrames() as the main function calling findcoordinates and degreesbetweenvectors
getCurrentFrames()
#_______________________________________________________________________________________



createAngleHistograms<-function(){
  binvector<-c(seq(0,180,10))
  saveAs <-paste(vidname,"_StackedAngleHist",sep=" ")
  jpeg(paste(workingd,"/",saveAs,".jpg",sep=""))
  angleVector<-read.csv(paste(workingd,"/",vidname,"allanglevector.csv",sep=""))
  hist(angleVector$x,xaxt='n',breaks=binvector,xlim=c(0,180),  col="plum1",xlab = "Angle (degrees)", ylab="Frequency",main = paste("Angle of mito direction of all mitos","\n","in",args[2]))
  axis(1, at = seq(0,180,45))
  dev.off()
}

createAngleHistograms()