#Fig 1: pipeline outline
#A- raw data from scope,
#B -- traces of trajectories 
#C -- "Social" social network example and "Physical" histogram example (e.g. speed)
#A --[Fiji+Trackmate]--> B --[bash+R+Mathematica]--> C
#D -- simple simulation illustration
#E -- ???quantitatively compare hypothesised mechanisms???
#C -> E and D -> E

#because this is a more freestyle image, i'll just generate the "Physical" Histogram example here,
#and do the rest in Inkscape. 


library(ggplot2)
library(jpeg)
library(cowplot)
library(gridExtra)
library(ggpubr)
library(magick)
library(ggdark)
library(ggthemes)

###### A -- distribution of speeds in a single cell  -- i.e. nframe * nmito points
currentCell<-"trackmaterun-nice120"
currentDirectory<- paste("/Users/d1795494/Documents/PIPELINE/MitoGFP-TRACKMATERUNS/",currentCell,sep="")
setwd(currentDirectory)
numberOfFramesInCurrentVideo<- 118

speedList<-c()
for (i in 1:numberOfFramesInCurrentVideo){
  currentSpeeds<-read.csv(paste("all_speeds/Speedofallmitosinframe",i,".csv",sep=""))
  currentSpeedList<-currentSpeeds$speeds
  speedList<-c(speedList,currentSpeedList)
}
speedframe<-data.frame(speedList)
Ci<-ggplot(data = speedframe) + geom_histogram(aes(x=log(speedList)),binwidth=0.5,fill="aquamarine3") +
    ylab("Frequency") + 
    xlab(expression(log(Speed/μms^-1)))  + 
    dark_theme_linedraw() +
    theme(axis.text=element_text(size=50), axis.title=element_text(size=60),
          panel.grid.minor = element_line(size = 0.9),
          panel.grid.major = element_line(size = 0.9))


ggsave("~/Documents/PhD Reports and Documents/ReportsAndFormalities/Paper/paperDrafts/Figures/Figure1/FigCi.png", Ci, width = 25, height = 20, units = "cm")

#Same again but for the simulation example


currentCell<-"7_198_0.040_4.416_0.309_0.424_1.000_3.151_0.337_0_0.359_0.000_0"
currentDirectory<- paste("/Users/d1795494/Documents/PIPELINE/simulation/",currentCell,sep="")
setwd(currentDirectory)
numberOfFramesInCurrentVideo<- 198

speedList<-c()
for (i in 1:numberOfFramesInCurrentVideo){
  currentSpeeds<-read.csv(paste("all_speeds/Speedofallmitosinframe",i,".csv",sep=""))
  currentSpeedList<-currentSpeeds$speeds
  speedList<-c(speedList,currentSpeedList)
}
speedframe<-data.frame(speedList)
Cii<-ggplot(data = speedframe) + geom_histogram(aes(x=log(speedList)),binwidth=0.5,fill="slategray3") +
  ylab("Frequency") + 
  xlab(expression(log(Speed/μms^-1)))  + 
  dark_theme_linedraw() +
  theme(axis.text=element_text(size=50), axis.title=element_text(size=60),
        panel.grid.minor = element_line(size = 0.9),
        panel.grid.major = element_line(size = 0.9))

ggsave("~/Documents/PhD Reports and Documents/ReportsAndFormalities/Paper/paperDrafts/Figures/Figure1/FigCii.png", Cii, width = 25, height = 20, units = "cm")
