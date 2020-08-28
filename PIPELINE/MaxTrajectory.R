#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
setwd(paste(args[1],args[2],sep=""))
File<-read.delim(args[3],header=TRUE)
Max<-max(File$Trajectory)
write(as.numeric(Max),"MaxTrajectory.txt")