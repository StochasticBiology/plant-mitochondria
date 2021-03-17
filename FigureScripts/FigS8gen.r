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

#28/01/21 These are the new models that are going in the supplement in response to reviewer comments 
a<-"5_100_0.010_1.000_1.000_0.500_1.000_0.000_0.000_0_0.500_0.000_9"
b<-"5_100_0.900_1.000_1.000_0.500_1.000_0.000_0.000_0_0.500_0.000_9"

c<-"5_100_0.100_1.000_0.200_0.100_1.000_0.000_0.000_0_0.500_0.000_9"
d<-"5_100_0.100_1.000_0.100_0.200_1.000_0.000_0.000_0_0.500_0.000_9"

e<-"5_100_0.100_1.000_1.000_0.500_1.000_0.000_0.000_0_0.500_0.000_9"
f<-"5_100_0.100_1.000_0.500_1.000_1.000_0.000_0.000_0_0.500_0.000_9"

g<-"5_100_0.100_1.000_1.000_0.200_1.000_0.000_0.000_0_0.500_0.000_9"
h<-"5_100_0.100_1.000_0.200_1.000_1.000_0.000_0.000_0_0.500_0.000_9"


i<-"5_100_0.100_1.000_1.000_0.500_1.000_0.000_0.000_0_0.500_0.990_9"
j<-"5_100_0.100_1.000_1.000_0.500_1.000_0.000_0.000_0_0.500_0.010_9"
k<-"5_100_0.100_1.000_1.000_0.500_0.990_0.000_0.000_0_0.500_0.000_9"
l<-"5_100_0.100_1.000_1.000_0.500_0.010_0.000_0.000_0_0.500_0.000_9"
m<-"5_100_0.100_1.000_1.000_0.500_1.000_0.000_0.990_0_0.500_0.000_9"
n<-"5_100_0.100_1.000_1.000_0.500_1.000_0.000_0.010_0_0.500_0.000_9"
o<-"5_100_0.100_1.000_1.000_0.500_1.000_0.990_0.000_0_0.500_0.000_9"
p<-"5_100_0.100_1.000_1.000_0.500_1.000_0.010_0.000_0_0.500_0.000_9"

q<-"5_100_0.100_1.000_1.000_0.500_1.000_5.000_0.000_0_0.500_0.000_9"
r<-"5_100_0.100_1.000_1.000_0.500_1.000_5.000_0.200_0_0.500_0.000_9"
s<-"5_100_0.100_1.000_1.000_0.500_1.000_5.000_0.500_0_0.500_0.000_9"
t<-"5_100_0.100_1.000_1.000_0.500_1.000_10.000_0.000_0_0.500_0.000_9"
u<-"5_100_0.100_1.000_1.000_0.500_1.000_10.000_0.200_0_0.500_0.000_9"
v<-"5_100_0.100_1.000_1.000_0.500_1.000_10.000_0.500_0_0.500_0.000_9"
w<-"5_100_0.100_1.000_1.000_0.500_1.000_0.000_1.000_0_0.500_0.000_9"

#B -- example traces and social networks for 4 new parameterisations, NM13,14,15,16
aRoot<-paste("~/Documents/PIPELINE/supplement_models/",a,"/",sep="")
bRoot<-paste("~/Documents/PIPELINE/supplement_models/",b,"/",sep="")
cRoot<-paste("~/Documents/PIPELINE/supplement_models/",c,"/",sep="")
dRoot<-paste("~/Documents/PIPELINE/supplement_models/",d,"/",sep="")

eRoot<-paste("~/Documents/PIPELINE/supplement_models/",e,"/",sep="") 
fRoot<-paste("~/Documents/PIPELINE/supplement_models/",f,"/",sep="")
gRoot<-paste("~/Documents/PIPELINE/supplement_models/",g,"/",sep="")
hRoot<-paste("~/Documents/PIPELINE/supplement_models/",h,"/",sep="")

iRoot<-paste("~/Documents/PIPELINE/supplement_models/",i,"/",sep="")
jRoot<-paste("~/Documents/PIPELINE/supplement_models/",j,"/",sep="")
kRoot<-paste("~/Documents/PIPELINE/supplement_models/",k,"/",sep="")
lRoot<-paste("~/Documents/PIPELINE/supplement_models/",l,"/",sep="")

mRoot<-paste("~/Documents/PIPELINE/supplement_models/",m,"/",sep="")
nRoot<-paste("~/Documents/PIPELINE/supplement_models/",n,"/",sep="")
oRoot<-paste("~/Documents/PIPELINE/supplement_models/",o,"/",sep="")
pRoot<-paste("~/Documents/PIPELINE/supplement_models/",p,"/",sep="")

qRoot<-paste("~/Documents/PIPELINE/supplement_models/",q,"/",sep="")
rRoot<-paste("~/Documents/PIPELINE/supplement_models/",r,"/",sep="")
sRoot<-paste("~/Documents/PIPELINE/supplement_models/",s,"/",sep="")

tRoot<-paste("~/Documents/PIPELINE/supplement_models/",t,"/",sep="")
uRoot<-paste("~/Documents/PIPELINE/supplement_models/",u,"/",sep="")
vRoot<-paste("~/Documents/PIPELINE/supplement_models/",v,"/",sep="") 
wRoot<-paste("~/Documents/PIPELINE/supplement_models/",w,"/",sep="")


#traces and rotate
#It's the bit at g3BaTrace<-image_ggplot(g3BaTrace) that puts the big white margins on these traces. If poss, avoid, but ggarrange might demand ggplot format.
g3BaTrace<-image_read(paste(aRoot,"simoutput-5-100-0.010-1.000-1.000-0.500-1.000-0.000-0.000-0-0.500-0.000-9.txt.pdf",sep="")) 
g3BaTrace<-image_ggplot(image_rotate(g3BaTrace,degrees=90))
g3BbTrace<-image_read(paste(bRoot,"simoutput-5-100-0.900-1.000-1.000-0.500-1.000-0.000-0.000-0-0.500-0.000-9.txt.pdf",sep=""))
g3BbTrace<-image_ggplot(image_rotate(g3BbTrace,degrees=90))
g3BcTrace<-image_read(paste(cRoot,"simoutput-5-100-0.100-1.000-0.200-0.100-1.000-0.000-0.000-0-0.500-0.000-9.txt.pdf",sep=""))
g3BcTrace<-image_ggplot(image_rotate(g3BcTrace,degrees=90))
g3BdTrace<-image_read(paste(dRoot,"simoutput-5-100-0.100-1.000-0.100-0.200-1.000-0.000-0.000-0-0.500-0.000-9.txt.pdf",sep=""))
g3BdTrace<-image_ggplot(image_rotate(g3BdTrace,degrees=90))
g3BeTrace<-image_read(paste(eRoot,"simoutput-5-100-0.100-1.000-1.000-0.500-1.000-0.000-0.000-0-0.500-0.000-9.txt.pdf",sep=""))
g3BeTrace<-image_ggplot(image_rotate(g3BeTrace,degrees=90))


g3BfTrace<-image_read(paste(fRoot,"simoutput-5-100-0.100-1.000-0.500-1.000-1.000-0.000-0.000-0-0.500-0.000-9.txt.pdf",sep=""))
g3BfTrace<-image_ggplot(image_rotate(g3BfTrace,degrees=90))
g3BgTrace<-image_read(paste(gRoot,"simoutput-5-100-0.100-1.000-1.000-0.200-1.000-0.000-0.000-0-0.500-0.000-9.txt.pdf",sep="")) 
g3BgTrace<-image_ggplot(image_rotate(g3BgTrace,degrees=90))
g3BhTrace<-image_read(paste(hRoot,"simoutput-5-100-0.100-1.000-0.200-1.000-1.000-0.000-0.000-0-0.500-0.000-9.txt.pdf",sep=""))
g3BhTrace<-image_ggplot(image_rotate(g3BhTrace,degrees=90))


g3BiTrace<-image_read(paste(iRoot,"simoutput-5-100-0.100-1.000-1.000-0.500-1.000-0.000-0.000-0-0.500-0.990-9.txt.pdf",sep=""))
g3BiTrace<-image_ggplot(image_rotate(g3BiTrace,degrees=90))
g3BjTrace<-image_read(paste(jRoot,"simoutput-5-100-0.100-1.000-1.000-0.500-1.000-0.000-0.000-0-0.500-0.010-9.txt.pdf",sep=""))
g3BjTrace<-image_ggplot(image_rotate(g3BjTrace,degrees=90))


g3BkTrace<-image_read(paste(kRoot,"simoutput-5-100-0.100-1.000-1.000-0.500-0.990-0.000-0.000-0-0.500-0.000-9.txt.pdf",sep=""))
g3BkTrace<-image_ggplot(image_rotate(g3BkTrace,degrees=90))

g3BlTrace<-image_read(paste(lRoot,"simoutput-5-100-0.100-1.000-1.000-0.500-0.010-0.000-0.000-0-0.500-0.000-9.txt.pdf",sep="")) 
g3BlTrace<-image_ggplot(image_rotate(g3BlTrace,degrees=90))
g3BmTrace<-image_read(paste(mRoot,"simoutput-5-100-0.100-1.000-1.000-0.500-1.000-0.000-0.990-0-0.500-0.000-9.txt.pdf",sep=""))
g3BmTrace<-image_ggplot(image_rotate(g3BmTrace,degrees=90))
g3BnTrace<-image_read(paste(nRoot,"simoutput-5-100-0.100-1.000-1.000-0.500-1.000-0.000-0.010-0-0.500-0.000-9.txt.pdf",sep=""))
g3BnTrace<-image_ggplot(image_rotate(g3BnTrace,degrees=90))
g3BoTrace<-image_read(paste(oRoot,"simoutput-5-100-0.100-1.000-1.000-0.500-1.000-0.990-0.000-0-0.500-0.000-9.txt.pdf",sep=""))
g3BoTrace<-image_ggplot(image_rotate(g3BoTrace,degrees=90))

g3BpTrace<-image_read(paste(pRoot,"simoutput-5-100-0.100-1.000-1.000-0.500-1.000-0.010-0.000-0-0.500-0.000-9.txt.pdf",sep="")) 
g3BpTrace<-image_ggplot(image_rotate(g3BpTrace,degrees=90))
g3BqTrace<-image_read(paste(qRoot,"simoutput-5-100-0.100-1.000-1.000-0.500-1.000-5.000-0.000-0-0.500-0.000-9.txt.pdf",sep=""))
g3BqTrace<-image_ggplot(image_rotate(g3BqTrace,degrees=90))
g3BrTrace<-image_read(paste(rRoot,"simoutput-5-100-0.100-1.000-1.000-0.500-1.000-5.000-0.200-0-0.500-0.000-9.txt.pdf",sep=""))
g3BrTrace<-image_ggplot(image_rotate(g3BrTrace,degrees=90))
g3BsTrace<-image_read(paste(sRoot,"simoutput-5-100-0.100-1.000-1.000-0.500-1.000-5.000-0.500-0-0.500-0.000-9.txt.pdf",sep=""))
g3BsTrace<-image_ggplot(image_rotate(g3BsTrace,degrees=90))

g3BtTrace<-image_read(paste(tRoot,"simoutput-5-100-0.100-1.000-1.000-0.500-1.000-10.000-0.000-0-0.500-0.000-9.txt.pdf",sep="")) 
g3BtTrace<-image_ggplot(image_rotate(g3BtTrace,degrees=90))
g3BuTrace<-image_read(paste(uRoot,"simoutput-5-100-0.100-1.000-1.000-0.500-1.000-10.000-0.200-0-0.500-0.000-9.txt.pdf",sep=""))
g3BuTrace<-image_ggplot(image_rotate(g3BuTrace,degrees=90))
g3BvTrace<-image_read(paste(vRoot,"simoutput-5-100-0.100-1.000-1.000-0.500-1.000-10.000-0.500-0-0.500-0.000-9.txt.pdf",sep=""))
g3BvTrace<-image_ggplot(image_rotate(g3BvTrace,degrees=90))

g3BwTrace<-image_read(paste(wRoot,"simoutput-5-100-0.100-1.000-1.000-0.500-1.000-0.000-1.000-0-0.500-0.000-9.txt.pdf",sep=""))
g3BwTrace<-image_ggplot(image_rotate(g3BwTrace,degrees=90))



grid.arrange(arrangeGrob(g3BaTrace), arrangeGrob(g3BbTrace),arrangeGrob(g3BcTrace),arrangeGrob(g3BdTrace),
             arrangeGrob(g3BeTrace), arrangeGrob(g3BfTrace),arrangeGrob(g3BgTrace),arrangeGrob(g3BhTrace),
             arrangeGrob(g3BiTrace), arrangeGrob(g3BjTrace),arrangeGrob(g3BkTrace),arrangeGrob(g3BlTrace),
             arrangeGrob(g3BmTrace), arrangeGrob(g3BnTrace),arrangeGrob(g3BoTrace),arrangeGrob(g3BpTrace),
             arrangeGrob(g3BqTrace), arrangeGrob(g3BrTrace),arrangeGrob(g3BsTrace),arrangeGrob(g3BtTrace),
             arrangeGrob(g3BuTrace),
             top = "Global Title", ncol=4,nrow=6)
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

makeNet<-function(simRoot,simName){
  net1<-ggdraw() + draw_image(paste(simRoot,"Results",simName,"Frame17.jpg",sep=""),scale=0.50)
  net2<-ggdraw() + draw_image(paste(simRoot,"Results",simName,"Frame83.jpg",sep=""))
  net3<-ggdraw() + draw_image(paste(simRoot,"Results",simName,"Frame166.jpg",sep=""))
  net<-ggarrange(net1,net2,net3, ncol = 3, labels = c("19secs" , "96secs", "193secs"),font.label = list(size = 6),label.y=c(0.85,1,1),label.x=c(0.3,0.2,0.1))
  return(net)
}

netA<-makeNet(aRoot,a)
netB<-makeNet(bRoot,b)
netC<-makeNet(cRoot,c)
netD<-makeNet(dRoot,d)
netE<-makeNet(eRoot,e)
netF<-makeNet(fRoot,f)
netG<-makeNet(gRoot,g)
netH<-makeNet(hRoot,h)
netI<-makeNet(iRoot,i)
netJ<-makeNet(jRoot,j)
netK<-makeNet(kRoot,k)
netL<-makeNet(lRoot,l)
netM<-makeNet(mRoot,m)
netN<-makeNet(nRoot,n)
netO<-makeNet(oRoot,o)
netP<-makeNet(pRoot,p)
netQ<-makeNet(qRoot,q)
netR<-makeNet(rRoot,r)
netS<-makeNet(sRoot,s)
netT<-makeNet(tRoot,t)
netU<-makeNet(uRoot,u)
netV<-makeNet(vRoot,v)
netW<-makeNet(wRoot,w)


#C -- network statistics for these examples
#degree distribution

makeDegreeDist<-function(simRoot,simName){
  degree<-read.csv(paste(simRoot,simName,"_D_WS.csv",sep=""))
  distribution<-data.frame(degree[,3:ncol(degree)])
  distributionAsList<-c()
  for (i in 1:ncol(distribution)){ 
    distributionAsList<-c(distributionAsList,na.omit(distribution[,i]))
  }
  distributionAsFrame<-data.frame(distributionAsList)
  degreePlot<-ggplot(distributionAsFrame) + geom_histogram(aes(x=distributionAsList),binwidth=1,fill="dodgerblue4") + xlab("Degree") + ylab("Frequency") + scale_y_continuous(labels = scales::scientific) + scale_x_continuous(limits=c(-1, 15))
  return(degreePlot)
}

degreeA<-makeDegreeDist(aRoot,a)
degreeB<-makeDegreeDist(bRoot,b)
degreeC<-makeDegreeDist(cRoot,c)
degreeD<-makeDegreeDist(dRoot,d)
degreeE<-makeDegreeDist(eRoot,e)
degreeF<-makeDegreeDist(fRoot,f)
degreeG<-makeDegreeDist(gRoot,g)
degreeH<-makeDegreeDist(hRoot,h)
degreeI<-makeDegreeDist(iRoot,i)
degreeJ<-makeDegreeDist(jRoot,j)
degreeK<-makeDegreeDist(kRoot,k)
degreeL<-makeDegreeDist(lRoot,l)
degreeM<-makeDegreeDist(mRoot,m)
degreeN<-makeDegreeDist(nRoot,n)
degreeO<-makeDegreeDist(oRoot,o)
degreeP<-makeDegreeDist(pRoot,p)
degreeQ<-makeDegreeDist(qRoot,q)
degreeR<-makeDegreeDist(rRoot,r)
degreeS<-makeDegreeDist(sRoot,s)
degreeT<-makeDegreeDist(tRoot,t)
degreeU<-makeDegreeDist(uRoot,u)
degreeV<-makeDegreeDist(vRoot,v)
degreeW<-makeDegreeDist(wRoot,w)



#Summary stats for the models.
#We want the statistics that are prominent in the rhetoric
#These are : logMeanDegree (frame 198), InterMitoMean (overall), logMeanCH (overall), AvDistOverNet (frame 198), DegreeCV (frame 198).
#MeanDegree is taken from the last from of the time series, as this is what it is fro trellis plots, and the whole newtrok reprents the history of the system anyway. 
#its not the mean of the distribution above it. Probably need to make that clear in the figure legend.

makeMiniTable<-function(simRoot,simName){
  meanDegree<-read.csv(paste(simRoot,simName,"_MeanD_WS.csv",sep=""))
  logMeanDegree<-signif(log(meanDegree[198,2]),digits=3)
  InterMitoSummary<- read.csv(paste(simRoot,"/interMitoDistances/summaryStatsInterMitoDist",simName,".csv",sep=""))
  InterMitoMean<-signif(InterMitoSummary$overallMean,digits=3)
  meanCHSummary<-read.csv(paste(simRoot,"ConvexHullSummStats_",simName,".csv",sep=""))
  logMeanCH<-signif(log(meanCHSummary$meanArea),digits=3)
  degreeCVtable<-read.csv(paste(simRoot,simName,"_CoeffVarD_WS.csv",sep=""))
  degreeCV<-signif(degreeCVtable$CoeffVarD[198],digits=3)
  AvNoConnNeigbours<-read.csv(paste(simRoot,simName,"_averageNumberOfConnectedNeighbours.csv",sep=""))
  AvNoConnN<-signif(AvNoConnNeigbours$AvNoConnectedNeighboursList[198],digits=3)
  NetworkEfficiency<-read.csv(paste(simRoot,"avNetworkEfficiency_WS.csv",sep=""))
  NetworkEfficiency<-signif(NetworkEfficiency$Network.Efficieny..averagedoverallnodes.incSingletons[198],digits=3)
  miniTable<-c(logMeanDegree,InterMitoMean,logMeanCH,degreeCV,NetworkEfficiency)
  return(miniTable)
}

aTable<-makeMiniTable(aRoot,a)
bTable<-makeMiniTable(bRoot,b)
cTable<-makeMiniTable(cRoot,c)
dTable<-makeMiniTable(dRoot,d)
eTable<-makeMiniTable(eRoot,e)
fTable<-makeMiniTable(fRoot,f)
gTable<-makeMiniTable(gRoot,g)
hTable<-makeMiniTable(hRoot,h)
iTable<-makeMiniTable(iRoot,i)
jTable<-makeMiniTable(jRoot,j)
kTable<-makeMiniTable(kRoot,k)
lTable<-makeMiniTable(lRoot,l)
mTable<-makeMiniTable(mRoot,m)
nTable<-makeMiniTable(nRoot,n)
oTable<-makeMiniTable(oRoot,o)
pTable<-makeMiniTable(pRoot,p)
qTable<-makeMiniTable(qRoot,q)
rTable<-makeMiniTable(rRoot,r)
sTable<-makeMiniTable(sRoot,s)
tTable<-makeMiniTable(tRoot,t)
uTable<-makeMiniTable(uRoot,u)
vTable<-makeMiniTable(vRoot,v)
wTable<-makeMiniTable(wRoot,w)



#transpose
SummaryTable<-t(data.frame(aTable,bTable,cTable,dTable,eTable,fTable,gTable,hTable,iTable,jTable,kTable,lTable,mTable,nTable,oTable,pTable,qTable,rTable,sTable,tTable,uTable,vTable,wTable))
colnames(SummaryTable)<-c( paste("logMeanDegree","\n","(final frame)"), paste("InterMitoMean","\n","(overall)"),paste("logMeanCH","\n","(overall)"), paste("DegreeCV","\n","(final frame)"),paste("Network Efficiency","\n","(final frame)"))
rownames(SummaryTable)<-c("network (A)","network (B)","network (C)", "network (D)","network (E)","network (F)","network (G)", "network (H)","network (I)","network (J)","network (K)", "network (L)","network (M)","network (N)","network (O)", "network (P)","network (Q)","network (R)","network (S)","network (T)","network (U)","network (V)","network (W)")
SummaryTble<-tableGrob(data.frame(SummaryTable),theme=ttheme_minimal(base_size = 7, padding= unit(c(1,1),"mm")) ,cols = colnames(SummaryTable),rows = rownames(SummaryTable)) 
ggarrange(SummaryTble)

#ggarrange(tableGrob(data.frame(t(SummaryTable)),theme=ttheme_minimal(base_size = , padding= unit(c(1,1),"mm")),cols = colnames(SummaryTable),rows = rownames(SummaryTable))  )

mytheme <- gridExtra::ttheme_minimal(
  core = list(fg_params=list(cex = 1.2)),
  colhead = list(fg_params=list(cex = 1)),
  rowhead = list(fg_params=list(cex = 1)))
#You can transpose the table just by doing t(SummaryTable), and cols=rownames, and rows=colnames
SummaryTble<-ggarrange(gridExtra::tableGrob(data.frame(SummaryTable), theme = mytheme,cols = colnames(SummaryTable),rows = rownames(SummaryTable)))
ggarrange(SummaryTble)

# Arrange plots using ggarrange
#new
p<- ggarrange(ggarrange(ggarrange(g3BaTrace,degreeA,nrow=2,heights=c(1,2),labels=c("A(i)")),netA,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0.01,0.055),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BbTrace,degreeB,nrow=2,heights=c(1,2),labels=c("B(i)")),netB,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BcTrace,degreeC,nrow=2,heights=c(1,2),labels=c("C(i)")),netC,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BdTrace,degreeD,nrow=2,heights=c(1,2),labels=c("D(i)")),netD,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BeTrace,degreeE,nrow=2,heights=c(1,2),labels=c("E(i)")),netE,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BfTrace,degreeF,nrow=2,heights=c(1,2),labels=c("F(i)")),netF,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BgTrace,degreeG,nrow=2,heights=c(1,2),labels=c("G(i)")),netG,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BhTrace,degreeH,nrow=2,heights=c(1,2),labels=c("H(i)")),netH,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BiTrace,degreeI,nrow=2,heights=c(1,2),labels=c("I(i)")),netI,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BjTrace,degreeJ,nrow=2,heights=c(1,2),labels=c("J(i)")),netJ,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BkTrace,degreeK,nrow=2,heights=c(1,2),labels=c("K(i)")),netK,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BlTrace,degreeL,nrow=2,heights=c(1,2),labels=c("L(i)")),netL,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BmTrace,degreeM,nrow=2,heights=c(1,2),labels=c("M(i)")),netM,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BnTrace,degreeN,nrow=2,heights=c(1,2),labels=c("N(i)")),netN,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BoTrace,degreeO,nrow=2,heights=c(1,2),labels=c("O(i)")),netO,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BpTrace,degreeP,nrow=2,heights=c(1,2),labels=c("P(i)")),netP,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BqTrace,degreeQ,nrow=2,heights=c(1,2),labels=c("Q(i)")),netQ,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BrTrace,degreeR,nrow=2,heights=c(1,2),labels=c("R(i)")),netR,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
              ggarrange(ggarrange(g3BsTrace,degreeS,nrow=2,heights=c(1,2),labels=c("S(i)")),netS,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),

              nrow=10,ncol=2)
p


#ggarrange(ggarrange(g3BrTrace,degreeR,nrow=2,heights=c(1,2),labels=c("R(i)")),netR,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
#ggarrange(ggarrange(g3BsTrace,degreeS,nrow=2,heights=c(1,2),labels=c("S(i)")),netS,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
#ggarrange(ggarrange(g3BtTrace,degreeT,nrow=2,heights=c(1,2),labels=c("T(i)")),netT,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),
#ggarrange(ggarrange(g3BuTrace,degreeU,nrow=2,heights=c(1,2),labels=c("U(i)")),netU,ncol=2,labels=c("(ii)","(iii)"),label.y=c(1.14,1),label.x=c(0,0.05),widths=c(1,3),heights=c(1,2)),

#Export summary table seperate
ggsave("~/Documents/PhD Reports and Documents/ReportsAndFormalities/Paper/paperDrafts/Figures/Supplement/Figure4supplementTableExtended3.svg", ggarrange(SummaryTble), width = 20, height = 40, units = "cm")




#Export and save
#svg
ggsave("~/Documents/PhD Reports and Documents/ReportsAndFormalities/Paper/paperDrafts/Figures/Supplement/Figure4supplement-rearrange3.svg", p, width = 20, height = 40, units = "cm")

#pdf
ggsave("~/Documents/PhD Reports and Documents/ReportsAndFormalities/Paper/paperDrafts/Figures/Supplement/Figure4supplement-rearrange3.pdf", p, width = 37, height = 40, units = "cm")




