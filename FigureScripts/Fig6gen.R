
library(ggplot2)
library(jpeg)
library(cowplot)
library(gridExtra)
library(ggpubr)
library(magick)
library(ggdark)
library(ggthemes)
library(methods)
#Plotting the same graph across multiple frame times from earlier genrated logges sum stast tables
#ensure these tables are up to date
workingdirectory<-"~/Documents/PIPELINEdocs/"
setwd(workingdirectory)

firstFrame<-read.csv("SIMSTATSTABLE-SELECTIVELYLOGGED-FIRSTFRAME-6-11-20-updatedLabelling.csv")
fifthFrame<-read.csv("SIMSTATSTABLE-SELECTIVELYLOGGED-FIFTHFRAME-6-11-20-updatedLabelling.csv")
tenthFrame<-read.csv("SIMSTATSTABLE-SELECTIVELYLOGGED-TENTHFRAME-6-11-20-updatedLabelling.csv")
twentyFrame<-read.csv("SIMSTATSTABLE-SELECTIVELYLOGGED-TWENTIETHFRAME-6-11-20-updatedLabelling.csv")
fiftyFrame<-read.csv("SIMSTATSTABLE-SELECTIVELYLOGGED-FIFTIETHFRAME-6-11-20-updatedLabelling.csv")
hundredFrame<-read.csv("SIMSTATSTABLE-SELECTIVELYLOGGED-HUNDREDTHFRAME-6-11-20-updatedLabelling.csv")




x<-data.frame(firstFrame$X,firstFrame$NameOfFile,firstFrame$Type,firstFrame$Label,firstFrame$logMeanDegree,
              firstFrame$InterMitochondrialMean,fifthFrame$logMeanDegree,fifthFrame$InterMitochondrialMean,
              tenthFrame$logMeanDegree,tenthFrame$InterMitochondrialMean,twentyFrame$logMeanDegree,
              twentyFrame$InterMitochondrialMean,fiftyFrame$logMeanDegree,fiftyFrame$InterMitochondrialMean,
              hundredFrame$logMeanDegree,hundredFrame$InterMitochondrialMean)

colnames(x)[3] <- "Type"
colnames(x)[4] <- "Label"


#So we will colour mark them if they are of a different length, then also single them out later on in the trellis plotting ( for their own little trellis plot of smaller videos. ) 
cols = ifelse(x$Type=="Experimental", ifelse(x$Label=="F1"|x$Label=="F2"|x$Label=="F3"|x$Label=="F4"|x$Label=="F5"|x$Label=="F6"|x$Label=="F7"|x$Label=="F8"|x$Label=="F9"|x$Label=="F10"|x$Label=="F11"|x$Label=="F12"|x$Label=="F13"|x$Label=="F14"|x$Label=="F15"|x$Label=="F16"|x$Label=="F17"|x$Label=="F18"|x$Label=="F19"|x$Label=="F20"|x$Label=="F21"|x$Label=="F01", "red", "green"), "gray") 
#Just specify exactly which videos you don't want (You only want the comprable videos- at frame 1, the simulations and some GFPs and FRs are not comparable in frame times)
a<-c("GFP01","GFP02","GFP03","GFP04","GFP005","GFP007","GFP05","GFP06","GFP07","GFP08","GFP09","GFP010","GFP011","F7","F11","F01","INDVID1","INDVID2")


positionsOfUnWantedVideos<-c()
for(i in 1:length(a)){
  positionsOfUnWantedVideos<-c(positionsOfUnWantedVideos,match(a[i],x$Label))
}


#Simulations we're interested in as exceptions to DegreeCV vc logMeanDegree relationship of connectivity dependant being  on heterogeneity
#ST1 ST11 ST9 NM2 ST2 S1
positionsOfSimsOfInterest<-match(c("ST1", "ST11", "ST9", "NM2", "ST2", "S1"),x$Label)
for(i in positionsOfSimsOfInterest){
  cols[i]<-"blue"
}
xe <- x[-c(positionsOfUnWantedVideos) , ]
colsxe<-cols[-c(positionsOfUnWantedVideos)]

statTable<-xe
appropriateCols<-colsxe


#If you just want GFP and FR
positionsOfTheoretical<-which(statTable$Type %in% "Theoretical")
positionsOfIndependantsAndTooShortVids<-which(statTable$Label %in% c("GFP005","GFP007","INDVID1","F7","F11","F01"))
positionsToRemove<-c(positionsOfTheoretical,positionsOfIndependantsAndTooShortVids)
limitedTableNoTheory<-statTable[-positionsToRemove,]
appropriateCols<-appropriateCols[-positionsToRemove]


positionsOfSimsOfInterest<-match(c("ST1", "ST11", "ST9", "NM2", "ST2", "S1"),limitedTableNoTheory$Label)
for(i in positionsOfSimsOfInterest){
  appropriateCols[i]<-"blue"
}

statTable<-limitedTableNoTheory


#Just double check these labellings are correct, and that the right videos have been removed.
data.frame(statTable$Label,appropriateCols)

#What relationships do we want plotted?
#All frame plots
xaxes= c("firstFrame.logMeanDeg","fifthFrame.logMeanDeg","tenthFrame.logMeanDeg","twentyFrame.logMeanDeg","fiftyFrame.logMeanDeg","hundredFrame.logMeanDeg")
yaxes= c("firstFrame.InterMitoMean","fifthFrame.InterMitoMean","tenthFrame.InterMitoMean","twentyFrame.InterMitoMean","fiftyFrame.InterMitoMean","hundredFrame.InterMitoMean")
#just first, twenty, fifty, hundred
xaxes= c("firstFrame.logMeanDegree","twentyFrame.logMeanDegree","fiftyFrame.logMeanDegree","hundredFrame.logMeanDegree")
yaxes= c("firstFrame.InterMitochondrialMean","twentyFrame.InterMitochondrialMean","fiftyFrame.InterMitochondrialMean","hundredFrame.InterMitochondrialMean")



maxOFallMeanDegrees<-max(c(statTable$firstFrame.logMeanDegree,statTable$twentyFrame.logMeanDegree,statTable$fiftyFrame.logMeanDegree,statTable$hundredFrame.logMeanDegree))

maxOFallIntermitoMeans<-max(c(statTable$firstFrame.InterMitochondrialMean,statTable$twentyFrame.InterMitochondrialMean,statTable$fiftyFrame.InterMitochondrialMean,statTable$hundredFrame.InterMitochondrialMean))

plotFig4 <- function() {
  plotList <- c()
  
  for (i in 1:4) {
    #for (i in 1:12) {
    labelx <- xaxes[i]
    labely <- yaxes[i]
    namex <- "logMeanDegree"
    namey <- "InterMitochondrialMean"

      my.data <- data.frame(x = statTable[[labelx]], y = statTable[[labely]])
      
      currentPlot <-
        ggplot(data = my.data, aes(x = x, y = y)) + geom_point(
          col = appropriateCols,
          size = 4,
          stroke = 0,
          shape = 16
        ) +
        xlim(c(min(my.data$x),max(my.data$x))) +
        ylim(c(0,max(my.data$y))) +
        geom_text(aes(label = statTable$Label), alpha = 0.5 ,size = 2, color= "black") + xlab(namex) + ylab(namey) 
      
      
      plotList <- c(plotList, list(currentPlot))
  }
  return(plotList)
}



#p <-ggarrange(plotlist=plotFig4(), labels = c("A","B","C","D","E","F"),
#              nrow = 2,
#              ncol = 3 ) 
p <-ggarrange(plotlist=plotFig4(), nrow=1,ncol=4 ) 
p

ggsave("~/Documents/PhD Reports and Documents/ReportsAndFormalities/Paper/paperDrafts/Figures/Figure6/figure6-partB-updatedLabelling.pdf", p, width = 40, height = 17, units = "cm")

















