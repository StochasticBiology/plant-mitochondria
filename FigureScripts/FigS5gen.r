#The difference between this and trellisPlotting.r is that we choose which stats to include in the trellis plot before we plot it

#Load data table with summary stats for chosen networks, rownames=1 uses first column as row names (can be any column number)
#For early or mid USE THEIR OWN R DOCS (trellisPlotting-earlyframe or trellisPlotting-midpoint)
x<-read.delim("/Users/d1795494/Documents/PIPELINEdocs/SIMSTATSTABLE-24-8-20-labellingUpdate.csv",header=TRUE,sep=",",row.names=1)
#This new table includes experimental videos of length <120, that we cannot accurately compare to those of length 120 (the most common video length, and the value that the models are comparable to)
#So we will colour mark them if they are of a different length, then also single them out later on in the trellis plotting ( for their own little trellis plot of smaller videos. ) 
cols = ifelse(x$Type=="Experimental", ifelse(x$Label=="F1"|x$Label=="F2"|x$Label=="F3"|x$Label=="F4"|x$Label=="F5"|x$Label=="F6"|x$Label=="F7"|x$Label=="F8"|x$Label=="F9"|x$Label=="F10"|x$Label=="F11"|x$Label=="F12"|x$Label=="F13"|x$Label=="F14"|x$Label=="F15"|x$Label=="F16"|x$Label=="F17"|x$Label=="F18"|x$Label=="F19"|x$Label=="F20"|x$Label=="F21"|x$Label=="F01", "red", "green"), "gray")
 
#Make those that have frames < 118 be coloured yellow (blue would be a better high contrast colour- but using it for a different marker right now)
#could also use less automated positionsOfVidsUnder120frames<-match(c("GFP01","GFP02","GFP03","GFP04","GFP05","GFP06","GFP07","GFP08","GFP09","GFP010","GFP011","F01"),x$Label)
#then loop through this list of positions doing cols[i] = yellow. But this way is much more automated (below).

positionsOfVidsUnder120frames<-c()
for(i in 1:nrow(x)){
  if(x$FrameNocollation[i] < 118){
    positionsOfVidsUnder120frames<-c(positionsOfVidsUnder120frames,i)
    cols[i]<-"yellow"
  }
}


#Simulations we're interested in as exceptions to DegreeCV vc logMeanDegree relationship of connectivity dependant being  on heterogeneity
#ST1 ST11 ST9 NM2 ST2 S1
positionsOfSimsOfInterest<-match(c("ST1", "ST11", "ST9", "NM2", "ST2", "S1"),x$Label)
for(i in positionsOfSimsOfInterest){
  cols[i]<-"blue"
}


#Check the labelling is appropriate
data.frame(x$Label,x$FrameNocollation,cols)

#plot trellis
plot(x, col=cols)


#Transform all data, but GO BACK and choose only those that vary over several orders of magnitude
#This process below forms up a new data table, same format as the old on but with some variable logged
#xl = data frame with selectively logged values, and ALL VIDEOS, regardless of length
xl<-c()
xl$NameOfFile = x$FileName
xl$Type = x$Type
xl$Label = x$Label
xl$FrameNumber = x$FrameNocollation
xl$logCCNum = log(x$CCcollation)
xl$PropCC = x$propMaxCCcollation
xl$PropCC. = x$normPropMaxCCcollation
xl$logMaxMin = log(x$MaxMincollation)
xl$MaxMin. = x$normMaxMincollation
xl$logPercolate0.5 = log(x$percolationCollation)
xl$DegreeDrop = x$walkerDegreeCollation
xl$logMeanDeg = log(x$meanDegreeCollation)
xl$DegreeCV = x$cvDegreeCollation
xl$InterMitoMean = x$meanInterMitoDistCollation
xl$InterMitoCV = x$cvInterMitoDistCollation
xl$MeanSpeed = x$meanSpeedCollation
xl$logmaxCH = log(x$maxCHCollation)
xl$logminCH = log(x$minCHCollation)
xl$logmeanCH = log(x$meanCHCollation)
xl$cvCH = x$cvCHCollation
xl$logassocTime = log(x$assocTimeCollation)
xl$maxCHRate = x$maxCHRateCollation
xl$minCHRate = x$minCHRateCollation
xl$meanCHRate = x$meanCHRateCollation
xl$cvCHRate = x$cvCHRateCollation
xl$logAvDistOverNet = log(x$AverageDistscollation)
xl$logAvCnctdNeighbrs = log(x$avConnectedNeighbours)
xl$networkEfficiency = x$NetworkEfficiencyCollation

xl=data.frame(xl)
colsxl=cols
plot(xl, col=cols)

#write.csv(xl,"/Users/d1795494/Documents/PIPELINEdocs/SIMSTATSTABLE-SELECTIVELYLOGGED-24-8-20-labellingUpdate.csv")

#xe = dataframe with selectively logged data, BUT with all videos < 120 frames length excluded
#Must have the cols list changed to reflect the shortened data frame 'Labels'
xe <- xl[-c(positionsOfVidsUnder120frames) , ]
colsxe<-cols[ - c(positionsOfVidsUnder120frames)]

#xi = data frame with selectively logged data, but only those videos that DO have < 120 frames (included)
xi <- xl[ c(positionsOfVidsUnder120frames) , ]
colsxi<-cols[c(positionsOfVidsUnder120frames)]

#xm = data frame with JUST the Theoretical data in. 
xm = xl[xl$Type=="Theoretical",]
colsxm = cols[cols=="gray"]


library(psych)

#CORRELATION TESTING
#Its a pearson correlation with a bonferroni adjustment for multiple tests.
#Seperating just experimental results
expt = x[x$Type=="Experimental",]
exptl = xl[xl$Type=="Experimental",]

corr.test(x[,3:19])
corr.test(xl[,3:19])
corr.test(expt[,3:19])
corr.test(exptl[,3:19])

xp<- corr.test(x[,3:19])$p
write.csv(xp,"/Users/d1795494/Documents/PIPELINE/p-values-allx.csv")

xlp<- corr.test(xl[,3:19])$p
write.csv(xlp,"/Users/d1795494/Documents/PIPELINE/p-values-allxlog.csv")

exptp<- corr.test(expt[,3:19])$p
write.csv(exptp,"/Users/d1795494/Documents/PIPELINE/p-values-experimental.csv")

exptlp<- corr.test(exptl[,3:19])$p
write.csv(exptlp,"/Users/d1795494/Documents/PIPELINE/p-values-experimentallog.csv")


#extract the p-values from the correlation testing
corr.test(newx[,3:19])
newxP<- corr.test(newx[,3:19])$p
write.csv(newxP,"/Users/d1795494/Documents/PIPELINE/p-values-selectivelylogged.csv")

#Extract the r-values (correlation values) from the correlation testing. 
# + or - gives indication of direction of relationship.
newxR<- corr.test(newx[,3:19])$r
write.csv(newxR,"/Users/d1795494/Documents/PIPELINE/corr-values-selectivelylogged.csv")

#Gathering those that have been selectively logged for just experimental networks
exptsl = xe[xe$Type=="Experimental",]
exptslP<- corr.test(exptsl[,5:26])$p
write.csv(exptslP,"/Users/d1795494/Documents/PIPELINE/p-values-experimental-selectivelylogged.csv")
exptslR<- corr.test(exptsl[,5:26])$r
write.csv(exptslR,"/Users/d1795494/Documents/PIPELINE/corr-values-experimental-selectivelylogged.csv")



#Fresh correlation testing for bigger new stats table
#You cannot compare videos with differing frame lengths, so will use two tables, those with = 120 frames, or < 120 frames.

#Those with = 120 frames
#extract the p-values from the correlation testing
corr.test(xe[,5:26])
newxP<- corr.test(xe[,5:26])$p
write.csv(newxP,"/Users/d1795494/Documents/PIPELINE/p-values-selectivelylogged-Onlyvideoswith120frames.csv")

#Extract the r-values (correlation values) from the correlation testing. 
# + or - gives indication of direction of relationship.
newxR<- corr.test(xe[,5:26])$r
write.csv(newxR,"/Users/d1795494/Documents/PIPELINE/corr-values-selectivelylogged-Onlyvideoswith120frames.csv")

#Those with < 120 frames
#extract the p-values from the correlation testing
corr.test(xi[,5:26])
newxP<- corr.test(xi[,5:26])$p
write.csv(newxP,"/Users/d1795494/Documents/PIPELINE/p-values-selectivelylogged-VideoswithLessThan120frames.csv")

#Extract the r-values (correlation values) from the correlation testing. 
# + or - gives indication of direction of relationship.
newxR<- corr.test(xi[,5:26])$r
write.csv(newxR,"/Users/d1795494/Documents/PIPELINE/corr-values-selectivelylogged-VideoswithLessThan120frames.csv")

#For JUST theoretical data
#extract the p-values from the correlation testing
corr.test(xm[,5:26])
newxP<- corr.test(xm[,5:26])$p
write.csv(newxP,"/Users/d1795494/Documents/PIPELINE/p-values-selectivelylogged-JustTheoretical.csv")

#Extract the r-values (correlation values) from the correlation testing. 
# + or - gives indication of direction of relationship.
newxR<- corr.test(xm[,5:26])$r
write.csv(newxR,"/Users/d1795494/Documents/PIPELINE/corr-values-selectivelylogged-JustTheoretical.csv")

#For JUST mtGFP data, of 120 frames in length
exptsl120= xe[xe$Type=="Experimental",]
exptsMitoGFP = subset(exptsl120, grepl("GFP", Label))
newxP<- corr.test(exptsMitoGFP[,5:26])$p
write.csv(newxP,"/Users/d1795494/Documents/PIPELINE/p-values-selectivelylogged-JustMitoGFP.csv")

#For JUST FRIENDLY data, of 120 frames in length
exptsFRIENDLY = subset(exptsl120, grepl("F[0-9]", Label))
newxP<- corr.test(exptsFRIENDLY[,5:26])$p
write.csv(newxP,"/Users/d1795494/Documents/PIPELINE/p-values-selectivelylogged-JustFRIENDLY.csv")




#TRELLIS PLOTTING
#Labelling the points on the summary statistic plots by the name of the video/simulation from which they came

#THIS ONE
library(ggplot2)
library(gridExtra)
library(psych)

statTable<-xe
appropriateCols<-colsxe

#Isolate the statistics that we want in the trellis plots:

StatsToKeep<-c("NameOfFile","Type","Label","FrameNumber","logCCNum","PropCC","logPercolate0.5","DegreeDrop","logMeanDeg","DegreeCV","InterMitoMean","InterMitoCV","MeanSpeed","logmeanCH","cvCH","logassocTime","logAvCnctdNeighbrs","networkEfficiency")


generateLimitedStatsTable<-function(xe,StatsToKeep){
  limitedTable<-c()
  for(i in 1:length(StatsToKeep)){
    limitedTable<-rbind(limitedTable,xe[[StatsToKeep[i]]])
  }
  polishedLimitedTable<-data.frame(t(limitedTable))
  colnames(polishedLimitedTable)<-StatsToKeep
  return(polishedLimitedTable)
}

limitedTable<-generateLimitedStatsTable(xe,StatsToKeep)

#if you DON'T WANT friendly, use this set of instructions
positionsOfFriendly<-which(appropriateCols %in% "red")
positionsOfIndependantsAndTooShortVids<-which(limitedTable$Label %in% c("GFP005","GFP007","INDVID1","F7","F11","F01"))
positionsToRemove<-c(positionsOfFriendly,positionsOfIndependantsAndTooShortVids)
limitedTableNoFr<-limitedTable[-positionsToRemove,]

colsnoFR = ifelse(limitedTableNoFr$Type=="Experimental", "green", "gray")

positionsOfSimsOfInterest<-match(c("ST1", "ST11", "ST9", "NM2", "ST2", "S1"),limitedTableNoFr$Label)
for(i in positionsOfSimsOfInterest){
  colsnoFR[i]<-"blue"
}

statTable<-limitedTableNoFr
appropriateCols<-colsnoFR

#If you WANT Friendly, use this set of instructions

positionsOfIndependantsAndTooShortVids<-which(limitedTable$Label %in% c("GFP005","GFP007","INDVID1","F7","F11","F01"))
positionsToRemove<-c(positionsOfIndependantsAndTooShortVids)
limitedTableWithFr<-limitedTable[-positionsToRemove,]
appropriateCols<-appropriateCols[-positionsToRemove]

positionsOfSimsOfInterest<-match(c("ST1", "ST11", "ST9", "NM2", "ST2", "S1"),limitedTableWithFr$Label)
for(i in positionsOfSimsOfInterest){
  appropriateCols[i]<-"blue"
}

statTable<-limitedTableWithFr

#If you just want friendly and mtGFP, use this
positionsOfTheoretical<-which(limitedTable$Type %in% "Theoretical")
positionsOfIndependantsAndTooShortVids<-which(limitedTable$Label %in% c("GFP005","GFP007","INDVID1","F7","F11","F01"))
positionsToRemove<-c(positionsOfTheoretical,positionsOfIndependantsAndTooShortVids)
limitedTableNoTheory<-limitedTable[-positionsToRemove,]
appropriateCols<-appropriateCols[-positionsToRemove]


positionsOfSimsOfInterest<-match(c("ST1", "ST11", "ST9", "NM2", "ST2", "S1"),limitedTableNoTheory$Label)
for(i in positionsOfSimsOfInterest){
  appropriateCols[i]<-"blue"
}

statTable<-limitedTableNoTheory


#Just double check these labellings are correct, and that the right videos have been removed.
data.frame(statTable$Label,appropriateCols,statTable$FrameNumber)

#pdf("~/Documents/PIPELINEdocs/trellisPlotAllVideosComparableLengths-withSmallLabels-interestingHighlighted-28-4-20.pdf")
columnname<-colnames(statTable)
swaglist<-c()
swag<-c()
#This has changed from 5:28 to 5:18 as we've weeded out statistics to reduce size of trellis
for(j in 5:18){
  for (k in 5:18) {
    my.data <- data.frame(x=as.numeric(statTable[,k]),y=as.numeric(statTable[,j]))
    
    #This pulls the appropriate correlation value for the current relationship you're looking at. later used in title.
    corrvalue = corr.test(my.data)$r[2]
    
    swag<-ggplot(data=my.data, aes(x=x,y=y))+ geom_point(col=appropriateCols, size = 3, stroke = 0, shape = 16) + 
      geom_text(aes(label=statTable$Label),size = 1,col="Black") +
      xlab(columnname[[k]]) +
      ylab(columnname[[j]]) + 
      theme(plot.title=element_text(size = 4, margin = unit(c(0,0,0,0),"mm"), face = "bold"),
            axis.text=element_text(size = 8, margin = margin(c(0,0,0,0),"mm")), 
            axis.title.x = element_text(size = 10,margin = unit(c(0,0,0.5,0),"mm")),
            axis.title.y = element_text(size = 10,margin = unit(c(0,0,0,0.5),"mm")), 
            axis.ticks = element_blank(),
            panel.margin=unit(c(0,0,0,0), "null"),
            plot.margin=unit(c(0,0,0,0), "null"),
            panel.border=element_blank())+
      
      ggtitle(paste("correlation (r) value =",corrvalue))
    swaglist<-c(swaglist, list(swag))
  }
}

n <- length(swaglist)
nCol <- floor(sqrt(n))
#do.call("grid.arrange", c(swaglist, ncol=nCol))
#dev.off()
#running the output with ggsave lets you define the pdf plot area in cm, so it doesn't shrink, and each graph comes out much bigger, letting the points be smaller. 
ml <- marrangeGrob(swaglist, nrow=nCol, ncol=nCol)
ggsave("~/Documents/PIPELINEdocs/trellisPlotAllVideosComparableLengths-interestingHighlighted-justFRandMTGFP-limitedStats-FINALFRAME-28-4-20-testingstillsame-5-2-20-labellingUpdate.pdf", ml, width = 100, height = 100, units = "cm")

pdf("layout2.pdf")
plot(statTable[5:26], col=cols)
dev.off()

#This is the code for adding labels over the points on the trellis plots
#geom_text(aes(label=statTable$Label),size=1/5) +


#Plots for individual graphs in same style as trellis


#statTable<-xe
#appropriateCols<-colsxe
labelx<-"logMeanDeg"
labely<-"InterMitoMean"

my.data <- data.frame(x=statTable[[labelx]],y=statTable[[labely]])

pdf(paste("/Users/d1795494/Documents/PIPELINEdocs/plot-",labelx,"vs",labely,".pdf",sep=""))
ggplot(data=my.data, aes(x=x,y=y))+ geom_point(col=appropriateCols, size = 4, stroke = 0, shape = 16) + 
  geom_text(aes(label=statTable$Label),size = 2) + xlab(labelx) + ylab(labely) +
  ggtitle(paste("Generated using experimental (mtGFP (green),","\n","FRIENDLY (red)) 120 frames in length, and theoretical data (grey)",sep=""))
dev.off()





####################################################################################

#JUST SIGNIFICANT THEORETICAL RELATIONSHIPS THAT HAVE PASSED, NOW PLOTTED WITH MTGFP AND FRIENDLY
#So we've gone through the p-values from the just theoretical analysis. We've picked out the realtionships that were significant.
#We wil now plot a trellis of only those realtionships that were significant, in order to further divide them into i-iv
#classes based on where the genotypes sit relative to the theoretical data.

#For a string of strings of all the relationships that are significant in the theoretical data,
#go to the r sheet 'trellisPlottingStringJustTheoreticalSigs.r', define it there.
#Check it's defined
listOfTheoreticalSigRels

#loop through these strings, split by space into labelx and labels y each time.
pdf("~/Documents/PIPELINEdocs/trellisPlotsAllSignificantTheoreticalRealtionshipsWFRandMTGFP.pdf")
swaglist<-c()
for (i in 1:length(listOfTheoreticalSigRels)){
  currentRelationship<-strsplit(listOfTheoreticalSigRels[i]," ")
  labelx<-currentRelationship[[1]][1]
  labely<-currentRelationship[[1]][2]
  
  my.data <- data.frame(x=statTable[[labelx]],y=statTable[[labely]])
  
  #This pulls the appropriate correlation value for the current relationship you're looking at. later used in title.
  corrvalue = corr.test(my.data)$r[2]

  swag<-ggplot(data=my.data, aes(x=x,y=y))+ geom_point(col=appropriateCols, size = 1, stroke = 0, shape = 16) + 
    geom_text(aes(label=statTable$Label),size = 0.5) + xlab(labelx) + ylab(labely) +
    theme(plot.title=element_text(size = 4, margin = unit(c(0,0,0,0),"mm"), face = "bold"),
          axis.text=element_text(size = 1, margin = margin(c(0,0,0,0),"null")), 
          axis.title.x = element_text(size = 4,margin = unit(c(0,0,1,0),"mm")),
          axis.title.y = element_text(size = 4,margin = unit(c(0,0,0,1),"mm")), 
          axis.ticks = element_blank(),
          panel.margin=unit(c(0,0,0,0), "null"),
          plot.margin=unit(c(0,0,0,0), "null"),
          panel.border=element_blank()) +
          ggtitle(paste("correlation (r) value =",corrvalue))
    
   swaglist<-c(swaglist, list(swag))
 }
n <- length(swaglist)
nCol <- floor(sqrt(n))
do.call("grid.arrange", c(swaglist, ncol=nCol))
dev.off()



#If you want instead to have the corr value imbedded onto the graph space, look at:
#https://stackoverflow.com/questions/7549694/add-regression-line-equation-and-r2-on-graph
#or use the below code
lm_eqn <- function(my.data){
  m <- lm(y ~ x, my.data);
  eq <- substitute(italic("corrvalue")~"="~corrvalue, 
                   list(corrvalue = corr.test(my.data)$r[2], digits = 3))
  as.character(as.expression(eq));
}

p1 <- p + geom_text(x = 25, y = 300, label = lm_eqn(my.data), parse = TRUE)
# or   + geom_text(x = 1, y = 1, label = lm_eqn(my.data), parse = TRUE)
