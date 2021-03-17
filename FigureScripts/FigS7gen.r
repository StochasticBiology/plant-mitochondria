library(ggplot2)
library(jpeg)
library(cowplot)
library(gridExtra)
library(ggpubr)
library(magick)
library(ggdark)
library(ggthemes)
library(methods)

#Load data table with summary stats for chosen networks 
x<-read.delim("/Users/d1795494/Documents/PIPELINEdocs/SIMSTATSTABLE-reducedColocDist-3-2-20.csv",header=TRUE,sep=",")
#This new table includes experimental videos of length <120, that we cannot accurately compare to those of length 120 (the most common video length, and the value that the models are comparable to)
#So we will colour mark them if they are of a different length, then also single them out later on in the trellis plotting ( for their own little trllis plot of smaller videos. ) 

#3/2/21 GFP5,7 -> gfp005,007 to neaten up labelling. Also for reduced coloc dist I took out S5,NM1,ST6,ST4,ST10,ST14,ST12 as their networks did not build up at all.
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
   if(x$FrameNocollation[i] < 5){
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
#xl$logMaxMin = log(x$MaxMincollation)
#xl$MaxMin. = x$normMaxMincollation
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
xl$logNetworkEfficiency = log(x$NetworkEfficiencyCollation)

xl=data.frame(xl)
colsxl=cols

#for early plots
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

#Extended labelling

xaxes= c("InterMitochondrialMean","logAssociationTime", "logAssociationTime","MeanSpeed","logMeanDegree","InterMitochondrialCV","logMeanDegree", "MeanSpeed","logMeanConvexHull","logMeanDegree","MeanSpeed","logConnectedComponentNo.")
yaxes= c("logMeanDegree", "logConnectedComponentNo.","logMeanDegree", "logMeanConvexHull", "logMeanConvexHull", "logMeanConvexHull", "logNetworkEfficiency", "logNetworkEfficiency", "logNetworkEfficiency", "DegreeCV","DegreeCV","DegreeCV") 

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


plotFig4 <- function() {
  plotList <- c()
  
  #for (i in 1:8) {
  for (i in 1:12) {
    labelx <- xaxes[i]
    labely <- yaxes[i]
    
   # if (i == 6 || i==7 || i == 8) {
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
         geom_text(aes(label = statTable$Label), alpha = 0.5 , size = 2, color= 'black') + xlab(labelx) + ylab(labely) 
      
      #^These lim commands look through namesAndMaxValues, matching the names of x and y
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
#ggsave("~/Documents/PhD Reports and Documents/ReportsAndFormalities/Paper/paperDrafts/Figures/Figure4/fig4rearrangedOpacityHighlights-withfriendly-EarlyFrame-Final-NoDegreeDrop.pdf", p, width = 30, height = 30, units = "cm")
#ggsave("~/Documents/PhD Reports and Documents/ReportsAndFormalities/Paper/paperDrafts/Figures/Figure4/fig4rearrangedOpacityHighlights-withfriendly-MidFrame-Final-NoDegreeDrop.pdf", p, width = 30, height = 30, units = "cm")
#ggsave("~/Documents/PhD Reports and Documents/ReportsAndFormalities/Paper/paperDrafts/Figures/Figure4/fig4-TheoryandWTandFR-firstFrame.pdf", p, width = 30, height = 30, units = "cm")
ggsave("~/Documents/PhD Reports and Documents/ReportsAndFormalities/Paper/paperDrafts/Figures/Figures-reducedColocDist/Fig5-RCD-updatedLabelling.pdf", p, width = 30, height = 30, units = "cm")

