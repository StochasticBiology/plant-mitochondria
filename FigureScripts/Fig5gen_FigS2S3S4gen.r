library(ggplot2)
library(jpeg)
library(cowplot)
library(gridExtra)
library(ggpubr)
library(magick)
library(ggdark)
library(ggthemes)
library(methods)

#Load data table with summary stats for chosen networks - swap in early/middle/late data here.
x<-read.delim("/Users/d1795494/Documents/PIPELINEdocs/SIMSTATSTABLE-EARLYPOINT-24-8-20-labellingUpdate.csv",header=TRUE,sep=",")
#This new table includes experimental videos of length <120, that we cannot accurately compare to those of length 120 (the most common video length, and the value that the models are comparable to)
#So we will colour mark them if they are of a different length, then also single them out later on in the trellis plotting ( for their own little trllis plot of smaller videos. ) 
cols = ifelse(x$Type=="Experimental", ifelse(x$Label=="F1"|x$Label=="F2"|x$Label=="F3"|x$Label=="F4"|x$Label=="F5"|x$Label=="F6"|x$Label=="F7"|x$Label=="F8"|x$Label=="F9"|x$Label=="F10"|x$Label=="F11"|x$Label=="F12"|x$Label=="F13"|x$Label=="F14"|x$Label=="F15"|x$Label=="F16"|x$Label=="F17"|x$Label=="F18"|x$Label=="F19"|x$Label=="F20"|x$Label=="F21"|x$Label=="F01", "red", "green"), "gray")

#FOR FIRST FRAME ONLY
#If you're just doing frame 1, just specify exactly which videos you don't want (You only want the comparable videos- at frame 1, the simulations and some GFPs and FRs are not comparable in frame times)
a<-c("GFP01","GFP02","GFP03","GFP04","GFP005","GFP007","GFP05","GFP06","GFP07","GFP08","GFP09","GFP010","GFP011","F7","F11","F01","INDVID1","INDVID2")
positionsOfVidsUnder120frames<-match(a,x$Label)
cols[positionsOfVidsUnder120frames]<-"yellow"

#FOR EARLY
positionsOfVidsUnder120frames<-c()
for(i in 1:nrow(x)){
  #For last, mid, or early frames:
   if(x$FrameNocollation[i] < 11){
    positionsOfVidsUnder120frames<-c(positionsOfVidsUnder120frames,i)
    cols[i]<-"yellow"
  }
}

#FOR MIDDLE
positionsOfVidsUnder120frames<-c()
for(i in 1:nrow(x)){
  #For last, mid, or early frames:
     if(x$FrameNocollation[i] < 59){
    positionsOfVidsUnder120frames<-c(positionsOfVidsUnder120frames,i)
    cols[i]<-"yellow"
  }
}

#FOR LATE
positionsOfVidsUnder120frames<-c()
for(i in 1:nrow(x)){
  #For last, mid, or early frames:
  if(x$FrameNocollation[i] < 118){
    positionsOfVidsUnder120frames<-c(positionsOfVidsUnder120frames,i)
    cols[i]<-"yellow"
  }
}


#Check the labelling is appropriate
data.frame(x$Label,x$FrameNocollation,cols)


#Comment out convex hulls if doing frame 1
xl<-c()
xl$NameOfFile = x$FileName
xl$Type = x$Type
xl$Label = x$Label
xl$FrameNumber = x$FrameNocollation
xl$logConnectedComponentNo. = log(x$CCcollation)
xl$PropCC = x$propMaxCCcollation
xl$PropCC. = x$normPropMaxCCcollation
xl$logMaxMin = log(x$MaxMincollation)
xl$MaxMin. = x$normMaxMincollation
xl$logPercolate0.5 = log(x$percolationCollation)
xl$DegreeDrop = x$walkerDegreeCollation
xl$logMeanDegree = log(x$meanDegreeCollation)
xl$DegreeCV = x$cvDegreeCollation
xl$InterMitochondrialMean = x$meanInterMitoDistCollation
xl$InterMitochondrialCV = x$cvInterMitoDistCollation
xl$MeanSpeed = x$meanSpeedCollation
xl$logmaxCH = log(x$maxCHCollation)
xl$logminCH = log(x$minCHCollation)
xl$logMeanConvexHull = log(x$meanCHCollation)
xl$cvCH = x$cvCHCollation
xl$logAssociationTime = log(x$assocTimeCollation)
xl$maxCHRate = x$maxCHRateCollation
xl$minCHRate = x$minCHRateCollation
xl$meanCHRate = x$meanCHRateCollation
xl$cvCHRate = x$cvCHRateCollation
xl$logAvDistOverNet = log(x$AverageDistscollation)
xl$logAvCnctdNeighbrs = log(x$avConnectedNeighbours)
xl$NetworkEfficiency = x$NetworkEfficiencyCollation

xl=data.frame(xl)
colsxl=cols

#for  plots
xl[ xl == "NaN" ] <- NA
xl[ xl == "Inf" ] <- NA
xl[ xl == "-Inf" ] <- NA


#xe = dataframe with selectively logged data, BUT with all videos < 120 frames length excluded
#Must have the cols list changed to reflect the shortened data frame 'Labels'
xe <- xl[-c(positionsOfVidsUnder120frames) , ]
colsxe<-cols[ - c(positionsOfVidsUnder120frames)]



#Plots for individual graphs in same style as trellis- will arrange into grid later

#What relationships do we want plotted?
#Without degree drop
xaxes= c("InterMitoMean","logassocTime", "logassocTime","MeanSpeed","logMeanDeg","InterMitoCV","logMeanDeg", "MeanSpeed","logmeanCH","logMeanDeg","MeanSpeed","logCCNum")
yaxes= c("logMeanDeg", "logCCNum","logMeanDeg", "logmeanCH", "logmeanCH", "logmeanCH", "networkEfficiency", "networkEfficiency", "networkEfficiency", "DegreeCV","DegreeCV","DegreeCV") 

#extended labelling
xaxes= c("InterMitochondrialMean","logAssociationTime", "logAssociationTime","MeanSpeed","logMeanDegree","InterMitochondrialCV","logMeanDegree", "MeanSpeed","logMeanConvexHull","logMeanDegree","MeanSpeed","logConnectedComponentNo.")
yaxes= c("logMeanDegree", "logConnectedComponentNo.","logMeanDegree", "logMeanConvexHull", "logMeanConvexHull", "logMeanConvexHull", "NetworkEfficiency", "NetworkEfficiency", "NetworkEfficiency", "DegreeCV","DegreeCV","DegreeCV") 

#For first frame plot
xaxes= c("InterMitoMean","logassocTime", "logassocTime","logMeanDeg", "MeanSpeed","logMeanDeg","logMeanDeg","MeanSpeed","logCCNum")
yaxes= c("logMeanDeg", "logCCNum","logMeanDeg", "networkEfficiency", "networkEfficiency" ,"DegreeDrop", "DegreeCV","DegreeCV","DegreeCV") 
  
#Old Order
#yaxes<-c("InterMitoMean","logmeanCH","logmeanCH","logmeanCH","logMeanDeg","DegreeDrop","DegreeCV","DegreeCV","DegreeCV","networkEfficiency","networkEfficiency","networkEfficiency")
#xaxes<-c("logMeanDeg","MeanSpeed","logMeanDeg","InterMitoCV","logAvCnctdNeighbrs","logMeanDeg","logMeanDeg","MeanSpeed","logCCNum","logMeanDeg","MeanSpeed","logmeanCH")




#12 plots, including 2 (graph 10 and 12) with interesting networks (those that buck the connectivity/heterogeneity relationship) marked with asterisks

#If you're doing just frame 1, you just need this:
appropriateCols<-colsxe 
statTable<-xe
positionsOfSimsOfInterest<-match(c("ST1", "ST11", "ST9", "NM2", "ST2", "S1"),xe$Label)
for(i in positionsOfSimsOfInterest){
  appropriateCols[i]<-"blue"
}

#if you DON'T WANT friendly, use this set of instructions
appropriateCols<-colsxe 
statTable<-xe
positionsOfFriendly<-which(appropriateCols %in% "red")
positionsOfIndependantsAndTooShortVids<-which(xe$Label %in% c("GFP005","GFP007","INDVID1","F7","F11","F01"))
positionsToRemove<-c(positionsOfFriendly,positionsOfIndependantsAndTooShortVids)
xeNoFr<-xe[-positionsToRemove,]


colsnoFR = ifelse(xeNoFr$Type=="Experimental", "green", "gray")

statTable<-xeNoFr
appropriateCols<-colsnoFR
positionsOfSimsOfInterest<-match(c("ST1", "ST11", "ST9", "NM2", "ST2", "S1"),xeNoFr$Label)

count=0
for(i in 1:nrow(statTable)){
  if (statTable[i,2]=="Theoretical"){
    count=count+1
    }
}

#If you WANT Friendly and WT and theory, use this set of instructions
appropriateCols<-colsxe    
positionsOfIndependantsAndTooShortVids<-which(xe$Label %in% c("GFP005","GFP007","INDVID1","F7","F11","F01"))
positionsToRemove<-c(positionsOfIndependantsAndTooShortVids)
xeWithFr<-xe[-positionsToRemove,]
appropriateCols<-appropriateCols[-positionsToRemove]

positionsOfSimsOfInterest<-match(c("ST1", "ST11", "ST9", "NM2", "ST2", "S1"),xeWithFr$Label)
for(i in positionsOfSimsOfInterest){
  appropriateCols[i]<-"blue"
}

statTable<-xeWithFr

#If you just want friendly and mtGFP, use this
positionsOfTheoretical<-which(xe$Type %in% "Theoretical")
positionsOfIndependantsAndTooShortVids<-which(xe$Label %in% c("GFP005","GFP007","INDVID1","F7","F11","F01"))
positionsToRemove<-c(positionsOfTheoretical,positionsOfIndependantsAndTooShortVids)
limitedTableNoTheory<-xe[-positionsToRemove,]
appropriateCols<-appropriateCols[-positionsToRemove]


positionsOfSimsOfInterest<-match(c("ST1", "ST11", "ST9", "NM2", "ST2", "S1"),limitedTableNoTheory$Label)
for(i in positionsOfSimsOfInterest){
  appropriateCols[i]<-"blue"
}

statTable<-limitedTableNoTheory

#Just double check these labellings are correct, and that the right videos have been removed.
data.frame(statTable$Label,appropriateCols,statTable$FrameNumber)

#Plotting
#For the early, mid and final plots, we want all the x and y axes to be the same, so need to figure out which one of the three carries the max values. 
#Be aware that these files need to be the most recent versions. Generated from limitedTrellisPlotting* files
#We're not plotting the summary statistics from the independent videos, so can remove the last two rows from the max calculations. 


early<-read.delim("/Users/d1795494/Documents/PIPELINEdocs/SIMSTATSTABLE-SELECTIVELYLOGGED-EARLYPOINT-24-8-20-labellingUpdate.csv",header=TRUE,sep=",")
mid<-read.delim("/Users/d1795494/Documents/PIPELINEdocs/SIMSTATSTABLE-SELECTIVELYLOGGED-MIDPOINT-24-8-20-labellingUpdate.csv",header=TRUE,sep=",")
late<-read.delim("/Users/d1795494/Documents/PIPELINEdocs/SIMSTATSTABLE-SELECTIVELYLOGGED-24-8-20-labellingUpdate.csv",header=TRUE,sep=",")

#Use this only if you're just plotting FR and WT
#positionsOfTheoreticalAgain<-which(early$Type %in% "Theoretical")
#early<-early[-positionsOfTheoreticalAgain,]
#mid<-mid[-positionsOfTheoreticalAgain,]
#late<-late[-positionsOfTheoreticalAgain,]

findAxisLimits<-function(early,mid,late){
  #percolate has lots of Infs across time so need to remove these before max()
  is.na(early)<-sapply(early, is.infinite)
  is.na(mid)<-sapply(mid, is.infinite)
  is.na(late)<-sapply(late, is.infinite)
  allmax<-c()
  allmin<-c()
  for(i in 6:ncol(early)){
    #--- max
    earlymax<-max(early[1:(nrow(early)-2),i],na.rm=TRUE)
    midmax<-max(mid[1:(nrow(mid)-2),i],na.rm=TRUE)
    latemax<-max(late[1:(nrow(late)-2),i],na.rm=TRUE)
    overallmax<-max(earlymax,midmax,latemax)
    allmax<-c(allmax,overallmax)
    #---- min
    earlymin<-min(early[1:(nrow(early)-2),i],na.rm=TRUE)
    midmin<-min(mid[1:(nrow(mid)-2),i],na.rm=TRUE)
    latemin<-min(late[1:(nrow(late)-2),i],na.rm=TRUE)
    overallmin<-min(earlymin,midmin,latemin)
    allmin<-c(allmin,overallmin)
  }
  namesOfMaxandMinValues<-colnames(early[,6:ncol(early)])
  namesAndMaxandMinValues<-data.frame(namesOfMaxandMinValues,allmax,allmin)
  return(namesAndMaxandMinValues)
}

namesAndMaxandMinValues<-findAxisLimits(early,mid,late)
#need the names to be in elongated form
namesAndMaxandMinValues$elongatedNames<-colnames(xl[5:ncol(xl)])
namesAndMaxandMinValues$namesOfMaxandMinValues<-namesAndMaxandMinValues$elongatedNames


plotFig4 <- function() {
  plotList <- c()
  
  #for (i in 1:8) {
  for (i in 1:12) {
    labelx <- xaxes[i]
    labely <- yaxes[i]
    
    #if (i == 6 || i==7 || i == 8) {
    if (i == 10 || i==11 || i == 12) {
      pointsForMarkingX <- c()
      pointsForMarkingY <- c()
      for (r in positionsOfSimsOfInterest) {
        #Creates a list of x or y coordinates based on where the value for the
        #stats in plot 10 or 12 (i) for the network of interest (r) lie
        pointsForMarkingX <-
          c(pointsForMarkingX, statTable[[xaxes[i]]][r])
        pointsForMarkingY <-
          c(pointsForMarkingY, statTable[[yaxes[i]]][r])
      }
      my.data <-
        data.frame(x = statTable[[labelx]], y = statTable[[labely]])
      
      currentPlot <-
        ggplot(data = my.data, aes(x = x, y = y)) + 
        annotate(
          "point",
          x = pointsForMarkingX,
          y = pointsForMarkingY,
          col = "blue",
          size=5
        ) +
        geom_point(
          col = appropriateCols,
          size = 4,
          stroke = 0,
          shape = 16
        ) +
        xlim(c(namesAndMaxandMinValues[match(labelx,namesAndMaxandMinValues[,1]),3]-0.1,namesAndMaxandMinValues[match(labelx,namesAndMaxandMinValues[,1]),2]+0.1)) +
        ylim(c(namesAndMaxandMinValues[match(labely,namesAndMaxandMinValues[,1]),3]-0.1,namesAndMaxandMinValues[match(labely,namesAndMaxandMinValues[,1]),2]+0.1)) +
        geom_text(aes(label = statTable$Label), alpha = 0.5 , size = 2, color= 'black') + xlab(labelx) + ylab(labely) 
      
      #^These lim commands look through namesAndMaxandMinValues, matching the names of x and y
      #axes to the corresponding maximum values, to just plot 0 to max for all time point graphs. 
      #So that all the time plots have the same axis to compare to. 
      
      plotList <- c(plotList, list(currentPlot))
      
    } else {
      my.data <- data.frame(x = statTable[[labelx]], y = statTable[[labely]])
      
      currentPlot <-
        ggplot(data = my.data, aes(x = x, y = y)) + geom_point(
          col = appropriateCols,
          size = 4,
          stroke = 0,
          shape = 16
        ) +
        xlim(c(namesAndMaxandMinValues[match(labelx,namesAndMaxandMinValues[,1]),3]-0.1,namesAndMaxandMinValues[match(labelx,namesAndMaxandMinValues[,1]),2]+0.1)) +
        ylim(c(namesAndMaxandMinValues[match(labely,namesAndMaxandMinValues[,1]),3]-0.1,namesAndMaxandMinValues[match(labely,namesAndMaxandMinValues[,1]),2]+0.1)) +
        geom_text(aes(label = statTable$Label), alpha = 0.5 ,size = 2, color= "black") + xlab(labelx) + ylab(labely) 
       
      
      plotList <- c(plotList, list(currentPlot))
      
    }
  }
  return(plotList)
}



p <-ggarrange(plotlist=plotFig4(), labels = c("A","B","C","D","E","F","G","H","I","J","K","L"),
              nrow = 4,
              ncol = 3 ) 
p

#Save and export
ggsave("~/Documents/PhD Reports and Documents/ReportsAndFormalities/Paper/paperDrafts/Figures/Figure5/fig5-5-2-21-EarlyPoint-labelsCorrected.pdf", p, width = 30, height = 30, units = "cm")
#ggsave("~/Documents/PhD Reports and Documents/ReportsAndFormalities/Paper/paperDrafts/Figures/Figure5/fig5-5-2-21-MidPoint-labelsCorrected.pdf", p, width = 30, height = 30, units = "cm")
#ggsave("~/Documents/PhD Reports and Documents/ReportsAndFormalities/Paper/paperDrafts/Figures/Figure5/fig5-5-2-21-labelsCorrected.pdf", p, width = 30, height = 30, units = "cm")



#Supplementary figure 2


xaxes<-c("DegreeCV","DegreeCV","DegreeCV")
yaxes<-c("logMeanConvexHull","cvCH","minCHRate")


statTable<-xe
appropriateCols<-colsxe
#For just plotting FRIENDLY, don't run if don't want to exclude

positionsOfFriendly<-which(appropriateCols %in% "red")
positionsOfIndependantsAndTooShortVids<-which(xe$Label %in% c("GFP005","GFP007","INDVID1"))
positionsToRemove<-c(positionsOfFriendly,positionsOfIndependantsAndTooShortVids)
xeNoFr<-xe[-positionsToRemove,]

colsnoFR = ifelse(xeNoFr$Type=="Experimental", "green", "gray")

statTable<-xeNoFr
appropriateCols<-colsnoFR
#12 plots, including 2 (graph 10 and 12) with interesting networks (those that buck the connectivity/heterogeneity realtionship) marked with asterisks

positionsOfSimsOfInterest<-match(c("ST1", "ST11", "ST9", "NM2", "ST2", "S1"),xeNoFr$Label)




plotFigS1 <- function() {
  plotList <- c()
  
  for (i in 1:3) {
    labelx <- xaxes[i]
    labely <- yaxes[i]
    
    if (i == 1 || i == 2 || i == 3) {
      pointsForMarkingX <- c()
      pointsForMarkingY <- c()
      for (r in positionsOfSimsOfInterest) {
        #Creates a list of x or y coordinates based on where the value for the
        #stats in plot 10 or 12 (i) for the network of interest (r) lie
        pointsForMarkingX <-
          c(pointsForMarkingX, statTable[[xaxes[i]]][r])
        pointsForMarkingY <-
          c(pointsForMarkingY, statTable[[yaxes[i]]][r])
      }
      my.data <-
        data.frame(x = statTable[[labelx]], y = statTable[[labely]])
      
      currentPlot <-
        ggplot(data = my.data, aes(x = x, y = y)) + 
        annotate(
          "point",
          x = pointsForMarkingX,
          y = pointsForMarkingY,
          col = "blue",
          size=5
        ) +
        geom_point(
          col = appropriateCols,
          size = 4,
          stroke = 0,
          shape = 16
        ) +
        geom_text(aes(label = statTable$Label), size = 2, color= 'black') + xlab(labelx) + ylab(labely) 
      
      plotList <- c(plotList, list(currentPlot))
      
    } else {
      my.data <- data.frame(x = statTable[[labelx]], y = statTable[[labely]])
      
      currentPlot <-
        ggplot(data = my.data, aes(x = x, y = y)) + geom_point(
          col = appropriateCols,
          size = 4,
          stroke = 0,
          shape = 16
        ) +
        geom_text(aes(label = statTable$Label), size = 2, color= "black") + xlab(labelx) + ylab(labely)
      
      plotList <- c(plotList, list(currentPlot))
      
    }
  }
  return(plotList)
}


p <-ggarrange(plotlist=plotFigS1(), labels = c("A","B","C"),
              nrow = 1,
              ncol=3 ) 
p

ggsave("~/Documents/PhD Reports and Documents/ReportsAndFormalities/Paper/paperDrafts/Figures/Supplement/FigS2-Final-updatedLabelling.pdf", p, width = 30, height = 10, units = "cm")


