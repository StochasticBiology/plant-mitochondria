#Generating a figure for the two independantly caputred videos taken from previous publications

IndVid1<-("/Users/d1795494/Documents/PIPELINE/IndependantVideos-TRACKMATE/ScaledAndCropped-Arimura2004Cotyledon/")
IndVid2<-("/Users/d1795494/Documents/PIPELINE/IndependantVideos-TRACKMATE/ScaledAndCropped-Logan2014Hypocotyl/")

#Arimura (IndVid1) time frame is 0.051 seconds per frame
#Arimura has 498 frames, so 0.051*498=25.398 seconds
#Logan (IndVid2) time frame is 4 seconds per frame, so 25.398/4=6.3495
#So only got 6 frames to work with for Logan. (do frames 1,3,6, that's 4,12,24 seconds)
#In Arimura, that's frame 78,235,471 for 4,12,24 seconds

S1Vid1Net1<-ggdraw() + draw_image(paste(IndVid1,"ResultsScaledAndCropped-Arimura2004CotyledonFrame78.jpg",sep=""),scale=0.80)
S1Vid1Net2<-ggdraw() + draw_image(paste(IndVid1,"ResultsScaledAndCropped-Arimura2004CotyledonFrame235.jpg",sep=""))
S1Vid1Net3<-ggdraw() + draw_image(paste(IndVid1,"ResultsScaledAndCropped-Arimura2004CotyledonFrame471.jpg",sep=""))
S1Vid1Net<-ggarrange(S1Vid1Net1,S1Vid1Net2,S1Vid1Net3, ncol = 3, labels = c("4secs" , "12secs", "24secs"),font.label = list(size = 6),label.y=0.61)
S1Vid1Net


S1Vid2Net1<-ggdraw() + draw_image(paste(IndVid2,"ResultsScaledAndCropped-Logan2014HypocotylFrame1.jpg",sep=""),scale=0.80)
S1Vid2Net2<-ggdraw() + draw_image(paste(IndVid2,"ResultsScaledAndCropped-Logan2014HypocotylFrame3.jpg",sep=""))
S1Vid2Net3<-ggdraw() + draw_image(paste(IndVid2,"ResultsScaledAndCropped-Logan2014HypocotylFrame6.jpg",sep=""))
S1Vid2Net<-ggarrange(S1Vid2Net1,S1Vid2Net2,S1Vid2Net3, ncol = 3, labels = c("4secs" , "12secs", "24secs"),font.label = list(size = 6),label.y=0.61)
S1Vid2Net



#indVid1
meanDegree<-read.csv(paste(IndVid1,"ScaledAndCropped-Arimura2004Cotyledon_MeanD_WS.csv",sep=""))
logMeanDegree1<-signif(log(meanDegree[471+1,2]),digits=3)
InterMitoSummary<- read.csv(paste(IndVid1,"/interMitoDistances/ScaledAndCropped-Arimura2004Cotyledondistancesrelatedtoframe471.csv",sep=""))
InterMitoMean1<-signif(mean(InterMitoSummary$shortestdistancesmicrons),digits=3)
MeanSpeed<-read.csv(paste(IndVid1,"speedMeansOverAllFramesScaledAndCropped-Arimura2004Cotyledon.csv",sep=""))
MeanSpeed1<-signif(MeanSpeed[471,3],digits=3)
degreeCVtable<-read.csv(paste(IndVid1,"ScaledAndCropped-Arimura2004Cotyledon_CoeffVarD_WS.csv",sep=""))
degreeCV1<-signif(degreeCVtable$CoeffVarD[471],digits=3)
NetworkEfficiency<-read.csv(paste(IndVid1,"avNetworkEfficiency_WS.csv",sep=""))
NetworkEfficiency1<-signif(NetworkEfficiency$Network.Efficieny..averagedoverallnodes.incSingletons[471],digits=3)

#indVid2
meanDegree<-read.csv(paste(IndVid2,"ScaledAndCropped-Logan2014Hypocotyl_MeanD_WS.csv",sep=""))
logMeanDegree2<-signif(log(meanDegree[6+1,2]),digits=3)
InterMitoSummary<- read.csv(paste(IndVid2,"/interMitoDistances/ScaledAndCropped-Logan2014Hypocotyldistancesrelatedtoframe6.csv",sep=""))
InterMitoMean2<-signif(mean(InterMitoSummary$shortestdistancesmicrons),digits=3)
MeanSpeed<-read.csv(paste(IndVid2,"speedMeansOverAllFramesScaledAndCropped-Logan2014Hypocotyl.csv",sep=""))
MeanSpeed2<-signif(MeanSpeed[6,3],digits=3)
degreeCVtable<-read.csv(paste(IndVid2,"ScaledAndCropped-Logan2014Hypocotyl_CoeffVarD_WS.csv",sep=""))
degreeCV2<-signif(degreeCVtable$CoeffVarD[6],digits=3)
NetworkEfficiency<-read.csv(paste(IndVid2,"avNetworkEfficiency_WS.csv",sep=""))
NetworkEfficiency2<-signif(NetworkEfficiency$Network.Efficieny..averagedoverallnodes.incSingletons[6],digits=3)


#Plotting tables of summary statistics for 1, 2
table1<-c(logMeanDegree1,InterMitoMean1,MeanSpeed1,degreeCV1,NetworkEfficiency1)
table2<-c(logMeanDegree2,InterMitoMean2,MeanSpeed2,degreeCV2,NetworkEfficiency2)
#transpose
SummaryTable<-t(data.frame(table1,table2))
colnames(SummaryTable)<-c( paste("logMeanDegree","\n","(at 24 seconds)"), paste("InterMitoMean","\n","(at 24 seconds)"),paste("MeanSpeed","\n","(0-24 seconds)"), paste("DegreeCV","\n","(at 24 seconds)"),paste("Network Efficiency","\n","(at 24 seconds)"))
rownames(SummaryTable)<-c("Independent Video 1","Independent Video 2")
SummaryTble<-tableGrob(data.frame(SummaryTable),theme=ttheme_minimal(base_size = 7, padding= unit(c(1,1),"mm")) ,cols = colnames(SummaryTable),rows = rownames(SummaryTable)) 
ggarrange(SummaryTble)

#ggarrange(tableGrob(data.frame(t(SummaryTable)),theme=ttheme_minimal(base_size = , padding= unit(c(1,1),"mm")),cols = colnames(SummaryTable),rows = rownames(SummaryTable))  )

mytheme <- gridExtra::ttheme_minimal(
  core = list(fg_params=list(cex = 1.1)),
  colhead = list(fg_params=list(cex = 0.8)),
  rowhead = list(fg_params=list(cex = 0.8)))
#You can transpose the table just by doing t(SummaryTable), and cols=rownames, and rows=colnames
SummaryTble<-ggarrange(gridExtra::tableGrob(data.frame(SummaryTable), theme = mytheme,cols = colnames(SummaryTable),rows = rownames(SummaryTable)))
ggarrange(SummaryTble)

# Arrange plots using ggarrange
#old
p <-ggarrange(ggarrange(S1Vid1Net1,S1Vid1Net2,S1Vid1Net3, ncol = 3, labels = c("A(i)", "(ii)","(iii)")), 
              ggarrange(S1Vid2Net1,S1Vid2Net2,S1Vid2Net3, ncol = 3, labels = c("B(i)", "(ii)","(iii)")),
              ggarrange(SummaryTble,ncol = 1, labels =c("C")),
              nrow = 3, heights = c(2,2,3)                                      
) 
p
ggsave("~/Documents/PhD Reports and Documents/ReportsAndFormalities/Paper/paperDrafts/Figures/Supplement/IndependantVideosSummary-updatedLogging.pdf", p, width = 20, height = 20, units = "cm")


