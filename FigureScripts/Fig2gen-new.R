#A script to generate what will be Figure 2 in the paper. 
#summary plot: physical statistics (speed, direction, convex hull distn, some stat about inter-mito distance), mean and CV of degree over time
#All same cell sample.
#A -- distribution of speeds in a single cell  -- i.e. nframe * nmito points
#B -- distribution of angles in a single cell -- i.e. nframe * nmito points
#C -- distribution of convex hull sizes in a single cell -- i.e. nmito points
#D -- distribution of minimum inter-mito distances in a single cell -- i.e. nframe * nmito points
#E -- three sample social networks at e.g. times 0+10, 0+50, 0+100
#F -- distribution of degree at those times (3 hists)
#G -- time series of degree and CV
#[associated SI figure, showing equivalents for more cells]

currentCell<-"trackmaterun-nice120"
currentDirectory<- paste("/Users/d1795494/Documents/PIPELINE/MitoGFP-TRACKMATERUNS/",currentCell,sep="")
setwd(currentDirectory)
numberOfFramesInCurrentVideo<- 118
library(ggplot2)
library(jpeg)
library(cowplot)
library(gridExtra)
library(ggpubr)
library(magick)
library(ggdark)
library(ggthemes)
library(svglite)

###### A -- distribution of speeds in a single cell  -- i.e. nframe * nmito points

speedList<-c()
for (i in 1:numberOfFramesInCurrentVideo){
  currentSpeeds<-read.csv(paste("all_speeds/Speedofallmitosinframe",i,".csv",sep=""))
  currentSpeedList<-currentSpeeds$speeds
  speedList<-c(speedList,currentSpeedList)
}
speedframe<-data.frame(speedList)
gA<-ggplot(data = speedframe) + geom_histogram(aes(x=log(speedList)),binwidth=0.5) + ylab("Frequency") + xlab("log Speed (\u03BCm/s)") 

#To do in dark theme for figure 1 ^ :    + dark_theme_linedraw()

###### B -- distribution of angles in a single cell -- i.e. nframe * nmito points
### ANGLE IS NOW 180 - VALUE, as it more accurately represents the chnage in angle of motion, and 180 otherwise might be misleading that the mito is turning back on itself.

allAngles<-read.csv(paste(currentCell,"allanglevector.csv",sep=""))
colnames(allAngles) <- c("Angle")
newAngles<-180-na.omit(allAngles)
gB<-ggplot(data = newAngles) + geom_histogram(aes(x=Angle),binwidth=5) + ylab("Count") + xlab("Angle (degrees)")   +
  dark_theme_linedraw() +
  theme(axis.text=element_text(size=50), axis.title=element_text(size=60))

###### C -- distribution of convex hull sizes in a single cell -- i.e. nmito points

allAreas<- read.csv(paste("areaandlogarealist",currentCell,".csv",sep=""))
gC<-ggplot(data = allAreas) + geom_histogram(aes(x=arealist),binwidth=2.5) + xlab(paste("Area (","\u03BC","m","\u00B2)",sep="")) + ylab("Frequency")

###### D -- distribution of minimum inter-mito distances in a single cell -- i.e. nframe * nmito points

distanceList<-c()
for (i in 1:numberOfFramesInCurrentVideo){
  currentDists<-read.csv(paste("interMitoDistances/",currentCell,"distancesrelatedtoframe",i,".csv",sep=""))
  currentDistsList<-currentDists$shortestdistancesmicrons
  distanceList<-c(distanceList,currentDistsList)
}
distanceFrame<-data.frame(distanceList)
gD<-ggplot(data = distanceFrame) + geom_histogram(aes(x=distanceList),binwidth=0.5) + xlab(paste("Minimum distances ","(\u03BCm)",sep=""))+ylab("Frequency")


#E -- three sample social networks at e.g. times 0+10, 0+50, 0+100
gE1<-ggdraw() + draw_image("Resultstrackmaterun-nice120Frame10.jpg")
gE2<-ggdraw() + draw_image("Resultstrackmaterun-nice120Frame50.jpg")
gE3<-ggdraw() + draw_image("Resultstrackmaterun-nice120Frame100.jpg")

#F -- distribution of degree at those times (3 hists), stacked over each other
degreeByFrame<-read.csv(paste(currentCell,"_D.csv",sep=""))

distributionatPlus10<-t(degreeByFrame[10,3:ncol(degreeByFrame)])
distatPlus10<-na.omit(data.frame(distributionatPlus10[,1]))
colnames(distatPlus10) <- c("Degree")
gF1<-ggplot(data = distatPlus10) + geom_histogram(aes(x=Degree),binwidth=1) + xlab("Degree") + ylab("Frequency") +ggtitle("Degree Distribution at time 0+10 frames")

distributionatPlus50<-t(degreeByFrame[50,3:ncol(degreeByFrame)])
distatPlus50<-na.omit(data.frame(distributionatPlus50[,1]))
colnames(distatPlus50) <- c("Degree")
gF2<-ggplot(data = distatPlus50) + geom_histogram(aes(x=Degree),binwidth=1) + xlab("Degree") + ylab("Frequency") +ggtitle("Degree Distribution at time 0+50 frames")

distributionatPlus100<-t(degreeByFrame[100,3:ncol(degreeByFrame)])
distatPlus100<-na.omit(data.frame(distributionatPlus100[,1]))
colnames(distatPlus100) <- c("Degree")
gF3<-ggplot(data = distatPlus100) + geom_histogram(aes(x=Degree),binwidth=1) + xlab("Degree") + ylab("Frequency") +ggtitle("Degree Distribution at time 0+100 frames")

library(reshape2)
bucket<-list(t.10=distatPlus10$Degree,t.50=distatPlus50$Degree,t.100=distatPlus100$Degree) # this puts all values in one list

# the melt command flattens the 'bucket' list into value/vectorname pairs
# the 2 columns are called 'value' and 'L1' by default
# 'fill' will color bars differently depending on L1 group
#Renames value and L1 to Degree and Time
a<-data.frame(melt(bucket))
colnames(a)<-c("Degree","Time")
#Need to reorder times, or 193s (t.100) appears in legend above 93s (t.50)
a$TimeOrdered <- factor(a$Time, levels=c("t.10", "t.50", "t.100"), labels=c("t = 19s",  "t = 93s","t = 193s"))

#We actually want a chart with probability, not frequency for the y-axis, so use this
gF<- ggplot(a, aes(x=Degree)) + 
  #call geom_histogram with position="dodge" to offset the bars and manual binwidth of 2
  geom_histogram(aes(y=..density..,fill = Time),position = "dodge", binwidth=1) + ylab("Probability") +
  theme(legend.position = "none")

###### G -- time series of degree and CV
degreeMeanOverTime<-read.csv(paste(currentCell,"_MeanD.csv",sep=""))
cvDegreeOverTime<-read.csv(paste(currentCell,"_CoeffVarD.csv",sep=""))
degreeOverTime<-read.csv(paste(currentCell,"_D.csv",sep=""))

timeSeriesData<-data.frame(degreeMeanOverTime,cvDegreeOverTime$CoeffVarD)
colnames(timeSeriesData)[3] <- c("CoefficientOfVariation")

#Collect the SD for all the degree values over time. 
sdTableGen<-function(){
  stdevList<-c()
  for (i in 1:nrow(degreeOverTime)){
    stdev <- sd(as.numeric(degreeOverTime[i,3:ncol(degreeOverTime)]),na.rm = TRUE)
    stdevList<-c(stdevList,stdev)
  }
  sdTable<-data.frame(degreeOverTime$Frame,stdevList)
  return(sdTable)
}
sdTable<-sdTableGen()
degreeMeanAndSD<-data.frame(degreeMeanOverTime,sdTable$stdevList)

#Plot of degree and SD shadow over time
gGa2 <- ggplot(data=degreeMeanAndSD)  +
  geom_ribbon(aes(y=Mean.Degree,x=Frame,ymin=Mean.Degree-sdTable.stdevList,ymax= Mean.Degree+sdTable.stdevList),fill="grey") +ylab("Degree")+
  geom_line(aes(x=Frame,y=Mean.Degree),col="red",size=3) +
  theme(axis.text = element_text(size=30),
        axis.title=element_text(size=35),
        panel.grid.minor = element_line(size = 1),
        panel.grid.major = element_line(size = 1.5)) +
  scale_x_continuous(expand = c(0, 0),breaks = seq(0, 120, by = 60), limits = c(0, NA),minor_breaks = seq(0, 120, 10)) + 
  scale_y_continuous(expand = c(0, 0),breaks = seq(0, 10, by = 5),minor_breaks = seq(0, 10, 1),limits = c(0, (max(degreeMeanAndSD$Mean.Degree)+max(degreeMeanAndSD$sdTable.stdevList))+1))
gGa2

gGb<-ggplot(data=timeSeriesData) + geom_line(aes(x=Frame,y=CoefficientOfVariation),col="Blue", size =2.5) + ylab("CV (Degree)") +
  theme(axis.title.x=element_text(size=25),
        axis.title.y=element_text(size=20),
        axis.text=element_text(size=20),
        panel.grid.minor = element_line(size = 1),
        panel.grid.major = element_line(size = 1.5),
        plot.background = element_rect(fill = "transparent",colour = NA)) +
  scale_y_continuous(breaks = seq(0, max(timeSeriesData$CoefficientOfVariation), by = 0.15)) + 
  scale_x_continuous(breaks = seq(0, 120, by = 60))
gGb

#Function to add line break to the axis, to detail it not beginning from 0
addAxisBreaks<-function(){
  plt<- gGb  +
    theme(axis.line = element_line())
  #Then, we'll make this into a gtable and grab the y-axis line:
  gt <- ggplotGrob(plt)
  
  is_yaxis <- which(gt$layout$name == "axis-l")
  yaxis <- gt$grobs[[is_yaxis]]
  
  #grab the polyline child
  yline <- yaxis$children[[1]]
  
  #Now we can edit the line as we see fit:
  yline$x <- unit(rep(1, 4), "npc")
  #The difference between the 2nd and 3rd numbers here dictate how far apart the two splits are
  yline$y <- unit(c(0, 0.1, 1, 0.13), "npc")
  yline$id <- c(1, 1, 2, 2)
  #This is important- the width of the break lines is defined here
  yline$arrow <- arrow(angle = 90, length= unit(2,"mm"))
  #Place it back into the gtable object and plot it:
  yaxis$children[[1]] <- yline
  gt$grobs[[is_yaxis]] <- yaxis
  return(gt)
}
gt<-addAxisBreaks()

#Plot an inset graph of mean degree over time, and the cv over time.
dualCVandMeanDegreeSDPlot<-function(){
  ggdraw() +
    draw_plot(gGa2) +
    draw_plot(gt , x = 0.1, y = .72, width = .35, height = .26)
}

dualCVandMeanDegreeSDPlot()
#Sized mess up of go straigh from plot->grid, so will export and reimport
ggsave("~/Documents/PIPELINEdocs/Figure2G.png", dualCVandMeanDegreeSDPlot(), width = 30, height = 20, units = "cm")
gG<-ggdraw() + draw_image("~/Documents/PIPELINEdocs/Figure2G.png")


# To plot as one image   
#c(gA,gB,gC,gD,gE1,gE2,gE3,gF1,gF2,gF3,gGa,gGb))
#Bring all of them down 
gA<-ggplot(data = speedframe) + geom_histogram(aes(x=log(speedList)),binwidth=0.5,fill="dodgerblue4") + ylab("Frequency") + xlab(expression(log(Speed/μms^-1))) + theme(axis.text=element_text(size=40),axis.title=element_text(size=40))
gB<-ggplot(data = newAngles) + geom_histogram(aes(x=Angle),binwidth=10,fill="dodgerblue4") + ylab("Frequency") + xlab("Angle (Degrees)")  + theme(axis.text=element_text(size=40),axis.title=element_text(size=40))
gC<-ggplot(data = allAreas) + geom_histogram(aes(x=log(arealist)),binwidth=0.5,fill="dodgerblue4") + xlab(paste("log(Area/\u03BC","m","\u00B2)",sep="")) + ylab("Frequency")  + theme(axis.text=element_text(size=40),axis.title=element_text(size=40))
gD<-ggplot(data = distanceFrame) + geom_histogram(aes(x=distanceList),binwidth=0.5,fill="dodgerblue4") + xlab(paste("Minimum distances ","(\u03BCm)",sep=""))+ylab("Frequency")  + theme(axis.text=element_text(size=40),axis.title=element_text(size=40))
gE1<-ggdraw() + draw_image("Resultstrackmaterun-nice120Frame10.jpg",scale = 0.55)
gE2<-ggdraw() + draw_image("Resultstrackmaterun-nice120Frame50.jpg")
gE3<-ggdraw() + draw_image("Resultstrackmaterun-nice120Frame100.jpg")
gF<- ggplot(a, aes(x=Degree)) + geom_histogram(aes(y=..density..,fill = TimeOrdered),position = "dodge", binwidth=1) + ylab("Probability")   + theme(legend.title = element_blank(), legend.key.size = unit(2,"cm"),  legend.position=c(0.80, 0.8),legend.background = element_blank(),legend.key = element_blank())+ theme(axis.text=element_text(size=40),axis.title=element_text(size=40),legend.text=element_text(size=40))
gG<-ggdraw() + draw_image("~/Documents/PIPELINEdocs/Figure2G.png",scale=0.99)
# Arrange plots using ggarrange
p <-ggarrange(ggarrange(gA, gB,gC, gD, ncol = 4, labels = c("A", "B","C", "D"),font.label = list(size = 50)),
              ggarrange(gE1,gE2,gE3, ncol = 3, labels = c("E(i)","(ii) ","(iii)"),font.label = list(size = 50)),
              ggarrange(gF,gG ,ncol = 2, labels = c("F","G"),font.label = list(size = 50)),
              nrow = 4                                     
) 
p

#Export and save
#pdf (the special symbols don't export properly in pdf format)
ggsave("~/Documents/PIPELINEdocs/Figure2.pdf", p, width = 20, height = 20, units = "cm")
ggsave("~/Documents/PhD Reports and Documents/ReportsAndFormalities/Paper/paperDrafts/Figures/Figure2.pdf", p, width = 25, height = 20, units = "cm")
#png
ggsave("~/Documents/PIPELINEdocs/Figure2.png", p, width = 20, height = 27, units = "cm")
ggsave("~/Documents/PhD Reports and Documents/ReportsAndFormalities/Paper/paperDrafts/Figures/Figure2new.svg", p, width = 100, height = 90, units = "cm")



