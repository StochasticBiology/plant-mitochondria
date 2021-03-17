#A script to generate what will be figure 3 in the paper
#Fig 3: simulation setup and summary illustrations
#A -- illustration of model and parameters
#B -- example traces and social networks for ?? parameterisations
#C -- network statistics for these examples
library(ggplot2)
library(gridExtra)
library(grid)
library(gridExtra)
library(gtable)
library(magick)
library(ggpubr)
library(cowplot)
library(svglite)

#Edit 28-7-20
#MeanDegree, CVDegree, AvDistOverNet have been altered to include singletons. 
#Number of connected networks has been added too. 
#Degree distribution has been altered to be WS too (all have bigger peaks at 0 now)

#B -- example traces and social networks for ?? parameterisations
#B -- example traces and social networks for 3 parameterisations, NM9,NM10,NM11
aRoot<-"~/Documents/PIPELINE/original_nulls/0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.010_0.000_9/" 
bRoot<-"~/Documents/PIPELINE/original_nulls/0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.990_0.000_9/"
cRoot<-"~/Documents/PIPELINE/original_nulls/5_100_0.100_1.000_1.000_0.500_1.000_0.000_0.000_0_0.174_0.000_9/"
dRoot<-"~/Documents/PIPELINE/original_nulls/0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.174_0.000_9/"
  
#traces and rotate
#It's the bit at g3BaTrace<-image_ggplot(g3BaTrace) that puts the big white margins on these traces. If poss, avoid, but ggarrange might demand ggplot format.
g3BaTrace<-image_read(paste(aRoot,"simoutput-0-100-0.100-0.000-0.000-0.000-0.000-0.000-0.000-0-0.010-0.000-9-darkened3.txt.pdf.png",sep="")) 
g3BaTrace<-image_rotate(g3BaTrace,degrees=90)
g3BaTrace<-image_ggplot(g3BaTrace)
g3BbTrace<-image_read(paste(bRoot,"simoutput-0-100-0.100-0.000-0.000-0.000-0.000-0.000-0.000-0-0.990-0.000-9.txt.pdf",sep=""))
g3BbTrace<-image_rotate(g3BbTrace,degrees=90)
g3BbTrace<-image_ggplot(g3BbTrace) 
g3BcTrace<-image_read(paste(cRoot,"simoutput-5-100-0.100-1.000-1.000-0.500-1.000-0.000-0.000-0-0.174-0.000-9.txt.pdf",sep=""))
g3BcTrace<-image_rotate(g3BcTrace,degrees=90)
g3BcTrace<-image_ggplot(g3BcTrace,interpolate=FALSE)
g3BdTrace<-image_read(paste(dRoot,"simoutput-0-100-0.100-0.000-0.000-0.000-0.000-0.000-0.000-0-0.174-0.000-9.txt.pdf",sep=""))
g3BdTrace<-image_rotate(g3BdTrace,degrees=90)
g3BdTrace<-image_ggplot(g3BdTrace) 

grid.arrange(arrangeGrob(g3BaTrace, top = 'title 1'), arrangeGrob(g3BbTrace, top = 'title 2'),arrangeGrob(g3BcTrace, top = 'title 2'),arrangeGrob(g3BdTrace, top = 'title 2'), top = "Global Title", ncol=4)
#networks
#These are whole network images- not that clear when you plot them.
#Chosen 3 networks for each representation, correlating to the three times in figure 2.
#These were
#frame 0 + 10 = 10*1.93818 = 19.38secs
#frame 0 + 50 = 50*1.93818 = 96.91secs
#frame 0 + 100 = 100*1.93818 = 193.82secs
#Which in the sim corresponds to
# 19.38secs/1.1628secs = 16.66 = ~ frame 17
# 96.91secs/1.1628secs = 83.34 = ~ frame 83
# 193.82secs/1.1628secs = 166.68 = ~ frame 166

#If you want figure labels at the bottom of each network do + draw_figure_label(c("3min 3secs"),position="bottom")
#Scaling option in draw_image is to reduce the size of the smallest networks so their dimers are comparable to the larger ones.
#NM9
g3BaNet1<-ggdraw() + draw_image(paste(aRoot,"Results0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.010_0.000_9Frame17.jpg",sep=""),scale=0.50)
g3BaNet2<-ggdraw() + draw_image(paste(aRoot,"Results0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.010_0.000_9Frame83.jpg",sep=""))
g3BaNet3<-ggdraw() + draw_image(paste(aRoot,"Results0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.010_0.000_9Frame166.jpg",sep=""))
g3BaNet<-ggarrange(g3BaNet1,g3BaNet2,g3BaNet3, ncol = 3, labels = c("19secs" , "96secs", "193secs"),font.label = list(size = 6),label.y=0.75)
g3BaNet
#NM10
g3BbNet1<-ggdraw() + draw_image(paste(bRoot,"Results0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.990_0.000_9Frame17.jpg",sep=""),scale=0.60)
g3BbNet2<-ggdraw() + draw_image(paste(bRoot,"Results0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.990_0.000_9Frame83.jpg",sep=""))
g3BbNet3<-ggdraw() + draw_image(paste(bRoot,"Results0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.990_0.000_9Frame166.jpg",sep=""))
g3BbNet<-ggarrange(g3BbNet1,g3BbNet2,g3BbNet3, ncol = 3, labels = c("19secs" , "96secs", "193secs"),font.label = list(size = 6),label.y=0.61)
g3BbNet
#NM11
g3BcNet1<-ggdraw() + draw_image(paste(cRoot,"Results5_100_0.100_1.000_1.000_0.500_1.000_0.000_0.000_0_0.174_0.000_9Frame17.jpg",sep=""),scale = 0.55)
g3BcNet2<-ggdraw() + draw_image(paste(cRoot,"Results5_100_0.100_1.000_1.000_0.500_1.000_0.000_0.000_0_0.174_0.000_9Frame83.jpg",sep=""))
g3BcNet3<-ggdraw() + draw_image(paste(cRoot,"Results5_100_0.100_1.000_1.000_0.500_1.000_0.000_0.000_0_0.174_0.000_9Frame166.jpg",sep=""))
g3BcNet<-ggarrange(g3BcNet1,g3BcNet2,g3BcNet3, ncol = 3, labels = c("19secs" , "96secs", "193secs"),font.label = list(size = 6),label.y=0.72)
g3BcNet
#NM12
g3BdNet1<-ggdraw() + draw_image(paste(dRoot,"Results0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.174_0.000_9Frame17.jpg",sep=""),scale=0.55)
g3BdNet2<-ggdraw() + draw_image(paste(dRoot,"Results0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.174_0.000_9Frame83.jpg",sep=""))
g3BdNet3<-ggdraw() + draw_image(paste(dRoot,"Results0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.174_0.000_9Frame166.jpg",sep=""))
g3BdNet<-ggarrange(g3BdNet1,g3BdNet2,g3BdNet3, ncol = 3, labels = c("19secs" , "96secs", "193secs"),font.label = list(size = 6),label.y=0.7)
g3BdNet


#C -- network statistics for these examples
#degree distribution
#NM9
NM9Degree<-read.csv(paste(aRoot,"0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.010_0.000_9_D_WS.csv",sep=""))
NM9Distribution<-data.frame(NM9Degree[,3:ncol(NM9Degree)])
NM9DistributionAsList<-c()
for (i in 1:ncol(NM9Distribution)){ 
  NM9DistributionAsList<-c(NM9DistributionAsList,na.omit(NM9Distribution[,i]))
}
NM9DistributionAsFrame<-data.frame(NM9DistributionAsList)
g3Ca<-ggplot(data = NM9DistributionAsFrame) + geom_histogram(aes(x=NM9DistributionAsList),binwidth=1,fill="dodgerblue4") + xlab("Degree") + ylab("Frequency") + scale_y_continuous(labels = scales::scientific) + scale_x_continuous(limits=c(-1, 15))
g3Ca

#NM10
NM10Degree<-read.csv(paste(bRoot,"0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.990_0.000_9_D_WS.csv",sep=""))
NM10Distribution<-data.frame(NM10Degree[,3:ncol(NM10Degree)])
NM10DistributionAsList<-c()
for (i in 1:ncol(NM10Distribution)){ 
  NM10DistributionAsList<-c(NM10DistributionAsList,na.omit(NM10Distribution[,i]))
}
NM10DistributionAsFrame<-data.frame(NM10DistributionAsList)
g3Cb<-ggplot(data = NM10DistributionAsFrame) + geom_histogram(aes(x=NM10DistributionAsList),binwidth=1,fill="dodgerblue4") + xlab("Degree") + ylab("Frequency") + scale_y_continuous(labels = scales::scientific) + scale_x_continuous(limits=c(-1, 15))

#NM11
NM11Degree<-read.csv(paste(cRoot,"5_100_0.100_1.000_1.000_0.500_1.000_0.000_0.000_0_0.174_0.000_9_D_WS.csv",sep=""))
NM11Distribution<-data.frame(NM11Degree[,3:ncol(NM11Degree)])
NM11DistributionAsList<-c()
for (i in 1:ncol(NM11Distribution)){ 
  NM11DistributionAsList<-c(NM11DistributionAsList,na.omit(NM11Distribution[,i]))
}
NM11DistributionAsFrame<-data.frame(NM11DistributionAsList)
g3Cc<-ggplot(data = NM11DistributionAsFrame) + geom_histogram(aes(x=NM11DistributionAsList),binwidth=1,fill="dodgerblue4") + xlab("Degree") + ylab("Frequency") + scale_y_continuous(labels = scales::scientific) + scale_x_continuous(limits=c(-1, 15))

#NM12
NM12Degree<-read.csv(paste(dRoot,"0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.174_0.000_9_D_WS.csv",sep=""))
NM12Distribution<-data.frame(NM12Degree[,3:ncol(NM12Degree)])
NM12DistributionAsList<-c()
for (i in 1:ncol(NM12Distribution)){ 
  NM12DistributionAsList<-c(NM12DistributionAsList,na.omit(NM12Distribution[,i]))
}
NM12DistributionAsFrame<-data.frame(NM12DistributionAsList)
g3Cd<-ggplot(data = NM12DistributionAsFrame) + geom_histogram(aes(x=NM12DistributionAsList),binwidth=1,fill="dodgerblue4") + xlab("Degree") + ylab("Frequency") + scale_y_continuous(labels = scales::scientific) + scale_x_continuous(limits=c(-1, 15))


#Summary stats for i or ii or iii or iv
#AVERAGE DISTANCES OVER NETWORKS NEEDS TO BE ALTERED TO NUMBER OF CONNECTED NEIGHBOURS
#We want the statistics that are prominent in the rhetoric
#These are : logMeanDegree (frame 198), InterMitoMean (overall), logMeanCH (overall), AvDistOverNet (frame 198), DegreeCV (frame 198).
#MeanDegree is taken from the last from of the time series, as this is what it is fro trellis plots, and the whole newtrok reprents the history of the system anyway. 
#its not the mean of the distribution above it. Probably need to make that clear in the figure legend.
#i
meanDegree.a<-read.csv(paste(aRoot,"0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.010_0.000_9_MeanD_WS.csv",sep=""))
logMeanDegree.a<-signif(log(meanDegree.a[198,2]),digits=3)
InterMitoSummary.a<- read.csv(paste(aRoot,"/interMitoDistances/summaryStatsInterMitoDist0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.010_0.000_9.csv",sep=""))
InterMitoMean.a<-signif(InterMitoSummary.a$overallMean,digits=3)
MeanCHSummary.a<-read.csv(paste(aRoot,"ConvexHullSummStats_0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.010_0.000_9.csv",sep=""))
logMeanCH.a<-signif(log(MeanCHSummary.a$meanArea),digits=3)
degreeCVtable.a<-read.csv(paste(aRoot,"0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.010_0.000_9_CoeffVarD_WS.csv",sep=""))
degreeCV.a<-signif(degreeCVtable.a$CoeffVarD[198],digits=3)
AvNoConnNeigbours.a<-read.csv(paste(aRoot,"0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.010_0.000_9_averageNumberOfConnectedNeighbours.csv",sep=""))
AvNoConnN.a<-signif(AvNoConnNeigbours.a$AvNoConnectedNeighboursList[198],digits=3)
NetworkEfficiencya<-read.csv(paste(aRoot,"avNetworkEfficiency_WS.csv",sep=""))
NetworkEfficiency.a<-signif(NetworkEfficiencya$Network.Efficieny..averagedoverallnodes.incSingletons[198],digits=3)



#ii
meanDegree.b<-read.csv(paste(bRoot,"0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.990_0.000_9_MeanD_WS.csv",sep=""))
logMeanDegree.b<-signif(log(meanDegree.b[198,2]),digits=3)
InterMitoSummary.b<- read.csv(paste(bRoot,"/interMitoDistances/summaryStatsInterMitoDist0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.990_0.000_9.csv",sep=""))
InterMitoMean.b<-signif(InterMitoSummary.b$overallMean,digits=3)
MeanCHSummary.b<-read.csv(paste(bRoot,"ConvexHullSummStats_0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.990_0.000_9.csv",sep=""))
logMeanCH.b<-signif(log(MeanCHSummary.b$meanArea),digits=3)
degreeCVtable.b<-read.csv(paste(bRoot,"0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.990_0.000_9_CoeffVarD_WS.csv",sep=""))
degreeCV.b<-signif(degreeCVtable.b$CoeffVarD[198],digits=3)
AvNoConnNeigbours.b<-read.csv(paste(bRoot,"0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.990_0.000_9_averageNumberOfConnectedNeighbours.csv",sep=""))
AvNoConnN.b<-signif(AvNoConnNeigbours.b$AvNoConnectedNeighboursList[198],digits=3)
NetworkEfficiencyb<-read.csv(paste(bRoot,"avNetworkEfficiency_WS.csv",sep=""))
NetworkEfficiency.b<-signif(NetworkEfficiencyb$Network.Efficieny..averagedoverallnodes.incSingletons[198],digits=3)

#iii
meanDegree.c<-read.csv(paste(cRoot,"5_100_0.100_1.000_1.000_0.500_1.000_0.000_0.000_0_0.174_0.000_9_MeanD_WS.csv",sep=""))
logMeanDegree.c<-signif(log(meanDegree.c[198,2]),digits=3)
InterMitoSummary.c<- read.csv(paste(cRoot,"/interMitoDistances/summaryStatsInterMitoDist5_100_0.100_1.000_1.000_0.500_1.000_0.000_0.000_0_0.174_0.000_9.csv",sep=""))
InterMitoMean.c<-signif(InterMitoSummary.c$overallMean,digits=3)
MeanCHSummary.c<-read.csv(paste(cRoot,"ConvexHullSummStats_5_100_0.100_1.000_1.000_0.500_1.000_0.000_0.000_0_0.174_0.000_9.csv",sep=""))
logMeanCH.c<-signif(log(MeanCHSummary.c$meanArea),digits=3)
degreeCVtable.c<-read.csv(paste(cRoot,"5_100_0.100_1.000_1.000_0.500_1.000_0.000_0.000_0_0.174_0.000_9_CoeffVarD_WS.csv",sep=""))
degreeCV.c<-signif(degreeCVtable.c$CoeffVarD[198],digits=3)
AvNoConnNeigbours.c<-read.csv(paste(cRoot,"5_100_0.100_1.000_1.000_0.500_1.000_0.000_0.000_0_0.174_0.000_9_averageNumberOfConnectedNeighbours.csv",sep=""))
AvNoConnN.c<-signif(AvNoConnNeigbours.c$AvNoConnectedNeighboursList[198],digits=3)
NetworkEfficiencyc<-read.csv(paste(cRoot,"avNetworkEfficiency_WS.csv",sep=""))
NetworkEfficiency.c<-signif(NetworkEfficiencyc$Network.Efficieny..averagedoverallnodes.incSingletons[198],digits=3)

#iv
meanDegree.d<-read.csv(paste(dRoot,"0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.174_0.000_9_MeanD_WS.csv",sep=""))
logMeanDegree.d<-signif(log(meanDegree.d[198,2]),digits=3)
InterMitoSummary.d<- read.csv(paste(dRoot,"/interMitoDistances/summaryStatsInterMitoDist0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.174_0.000_9.csv",sep=""))
InterMitoMean.d<-signif(InterMitoSummary.d$overallMean,digits=3)
MeanCHSummary.d<-read.csv(paste(dRoot,"ConvexHullSummStats_0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.174_0.000_9.csv",sep=""))
logMeanCH.d<-signif(log(MeanCHSummary.d$meanArea),digits=3)
degreeCVtable.d<-read.csv(paste(dRoot,"0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.174_0.000_9_CoeffVarD_WS.csv",sep=""))
degreeCV.d<-signif(degreeCVtable.d$CoeffVarD[198],digits=3)
AvNoConnNeigbours.d<-read.csv(paste(dRoot,"0_100_0.100_0.000_0.000_0.000_0.000_0.000_0.000_0_0.174_0.000_9_averageNumberOfConnectedNeighbours.csv",sep=""))
AvNoConnN.d<-signif(AvNoConnNeigbours.d$AvNoConnectedNeighboursList[198],digits=3)
NetworkEfficiency.d<-read.csv(paste(dRoot,"avNetworkEfficiency_WS.csv",sep=""))
NetworkEfficiency.d<-signif(NetworkEfficiency.d$Network.Efficieny..averagedoverallnodes.incSingletons[198],digits=3)


#Plotting tables of summary statistics for i, ii, iii, iv
tablea<-c(logMeanDegree.a,InterMitoMean.a,logMeanCH.a,degreeCV.a,NetworkEfficiency.a)
tableb<-c(logMeanDegree.b,InterMitoMean.b,logMeanCH.b,degreeCV.b,NetworkEfficiency.b)
tablec<-c(logMeanDegree.c,InterMitoMean.c,logMeanCH.c,degreeCV.c,NetworkEfficiency.c)
tabled<-c(logMeanDegree.d,InterMitoMean.d,logMeanCH.d,degreeCV.d,NetworkEfficiency.d)
#transpose
SummaryTable<-t(data.frame(tablea,tableb,tablec,tabled))
colnames(SummaryTable)<-c( paste("logMeanDegree","\n","(final frame)"), paste("InterMitoMean","\n","(overall)"),paste("logMeanCH","\n","(overall)"), paste("DegreeCV","\n","(final frame)"),paste("Network Efficiency","\n","(final frame)"))
rownames(SummaryTable)<-c("network (A)","network (B)","network (C)", "network (D)")
SummaryTble<-tableGrob(data.frame(SummaryTable),theme=ttheme_minimal(base_size = 7, padding= unit(c(1,1),"mm")) ,cols = colnames(SummaryTable),rows = rownames(SummaryTable)) 
ggarrange(SummaryTble)

#ggarrange(tableGrob(data.frame(t(SummaryTable)),theme=ttheme_minimal(base_size = , padding= unit(c(1,1),"mm")),cols = colnames(SummaryTable),rows = rownames(SummaryTable))  )

mytheme <- gridExtra::ttheme_minimal(
  core = list(fg_params=list(cex = 1.0)),
  colhead = list(fg_params=list(cex = 0.5)),
  rowhead = list(fg_params=list(cex = 0.5)))
#You can transpose the table just by doing t(SummaryTable), and cols=rownames, and rows=colnames
SummaryTble<-ggarrange(gridExtra::tableGrob(data.frame(SummaryTable), theme = mytheme,cols = colnames(SummaryTable),rows = rownames(SummaryTable)))
ggarrange(SummaryTble)

# Arrange plots using ggarrange

#NM9
g3BaNet<-ggarrange(g3BaNet1,g3BaNet2,g3BaNet3, ncol = 3, labels = c("19secs" , "96secs", "193secs"),font.label = list(size = 6),label.y=c(0.85,1,1),label.x=c(0.3,0.2,0.1))
g3BaNet
#NM10
g3BbNet<-ggarrange(g3BbNet1,g3BbNet2,g3BbNet3, ncol = 3, labels = c("19secs" , "96secs", "193secs"),font.label = list(size = 6),label.y=0.8,label.x=c(0.3,0,0))
g3BbNet
#NM11
g3BcNet<-ggarrange(g3BcNet1,g3BcNet2,g3BcNet3, ncol = 3, labels = c("19secs" , "96secs", "193secs"),font.label = list(size = 6),label.y=c(0.85,1,1),label.x=c(0.3,0.2,0.1))
g3BcNet
#NM12
g3BdNet<-ggarrange(g3BdNet1,g3BdNet2,g3BdNet3, ncol = 3, labels = c("19secs" , "96secs", "193secs"),font.label = list(size = 6),label.y=c(0.85,0.99,1),label.x=c(0.3,0,0))
g3BdNet
#new
p<- ggarrange(ggarrange(ggarrange(g3BaTrace,g3Ca,nrow=2,heights=c(1,2)),g3BaNet,ncol=2,labels=c("A(i)","(iii)"),label.y=c(1.14,1),label.x=c(0.01,0.055),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BbTrace,g3Cb,nrow=2,heights=c(1,2)),g3BbNet,ncol=2,labels=c("B(i)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BcTrace,g3Cc,nrow=2,heights=c(1,2)),g3BcNet,ncol=2,labels=c("C(i)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BdTrace,g3Cd,nrow=2,heights=c(1,2)),g3BdNet,ncol=2,labels=c("D(i)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(SummaryTble,ncol = 1, labels =c("E"),label.y=0.89),
              nrow=5,labels =c("(ii)","(ii)","(ii)","(ii)"))
p

#Export and save
#png
ggsave("~/Documents/PhD Reports and Documents/ReportsAndFormalities/Paper/paperDrafts/Figures/Figure4New.svg", p, width = 20, height = 28, units = "cm")

#pdf
ggsave("~/Documents/PhD Reports and Documents/ReportsAndFormalities/Paper/paperDrafts/Figures/Figure4New.pdf", p, width = 20, height = 28, units = "cm")







##########################################################################################
#If you instead wanted the summary statistics for the last table over time, you could use:

#The input to these stats change with each video- to save space copying this for loop three times.
degreeCvs<-c()
CCNumbers<-c()
AvDists<-c()
NormMaxMins<-c()
degreeDrops<-c()
#These numbers are the frame times correlating  to frame time 10 50 100 in the experimentals.
#(19secs , 1min 36secs, 3min 23secs respectively)
for (i in c(17,117,166)){
  degreeCvs<-c(degreeCvs,signif(degreeCV[i,2],digits=3))
  CCNumbers<-c(CCNumbers,CCNumber[i,2])
  AvDists<-c(AvDists,signif(AvDistOverNet[i,2],digits=3))
  NormMaxMins<-c(NormMaxMins,signif(NormMaxMin[i,4],digits=3))
  degreeDrops<-c(degreeDrops,signif(DegreeDrop[i,2],digits=3))

}

#Plotting tables of summary statistics for i, ii, c
#i
colnames(SummaryTablea) <- c("a.19secs" , "a.1min 36secs", "a.3min 23secs")
row.names(SummaryTablea) <-c("Degree CV","CC Number", "NormMaxMin","DegreeDrop")
tbli <- tableGrob(SummaryTablea) 
#ii
colnames(SummaryTableb) <- c("b.19secs" , "b.1min 36secs", "b.3min 23secs")
row.names(SummaryTableb) <-c("Degree CV","CC Number", "NormMaxMin","DegreeDrop")
tblii <- tableGrob(SummaryTableb) 
#c
colnames(SummaryTablec) <- c("c.19secs" , "c.1min 36secs", "c.3min 23secs")
row.names(SummaryTablec) <-c("Degree CV","CC Number", "NormMaxMin","DegreeDrop")
tblc <- tableGrob(SummaryTablec) 
