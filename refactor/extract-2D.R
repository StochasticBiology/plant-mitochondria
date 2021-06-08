#!/usr/bin/env Rscript
# draft code for taking XML description of trajectories and outputting summary statistics of dynamic encounter networks (and some snapshots of networks) 

# process command-line arguments
# these are of the form
# Rscript extract-2D.R [input XML file] [threshold] [any frames for which to output graph plots]
# e.g.
# Rscript extract-2D.R test.xml 1.6 1 50 100

message("Processing arguments...")

args = commandArgs(trailingOnly=TRUE)

# we need at least an XML input filename and a threshold distance
if (length(args) < 2) {
  stop("At least two arguments must be supplied (input file and threshold distance).n", call.=FALSE)
}

filename = args[1]
threshold = as.numeric(args[2])
frames.to.plot = NULL
if(length(args) > 2) {
  for(i in 3:length(args)) {
    frames.to.plot = c(frames.to.plot, as.numeric(args[i]))
  }
}

message(paste("Attempting to analyse ", filename, sep=""))
message(paste("with threshold ", threshold, sep=""))

message("Loading libraries...")
library(XML)
library(igraph)
library(brainGraph)

# read XML to list
message("Reading and parsing XML...")
traj.list = xmlToList(filename)

# initialise dataframe for storing trajectories
df = data.frame(traj=NULL, t=NULL, x=NULL, y=NULL)

# loop through list, extracting coordinates and times and binding to growing dataframe
message("Extracting trajectories...")
# horrible code to extract trajectories from XML output
# issues here include that XML output is character format, has the same label for every row ($particle$detection) and comes in a very nested list form
# we use one nested sapply to grab the coordinate of interest from each entry, chop off the extraneous metadata, then another sapply to convert to numeric values
tmp = sapply(traj.list, function(v) sapply(v, function(w) w[1]))
tmp = tmp[-length(tmp)]
tmp1 = sapply(tmp, function(v) as.numeric(v[-length(v)]))
ts = unlist(tmp1)

tmp = sapply(traj.list, function(v) sapply(v, function(w) w[2]))
tmp = tmp[-length(tmp)]
tmp1 = sapply(tmp, function(v) as.numeric(v[-length(v)]))
xs = unlist(tmp1)

tmp = sapply(traj.list, function(v) sapply(v, function(w) w[3]))
tmp = tmp[-length(tmp)]
tmp1 = sapply(tmp, function(v) as.numeric(v[-length(v)]))
ys = unlist(tmp1)

lengths = sapply(traj.list, function(v) length(v)-1)
lengths = lengths[-length(lengths)]
labels = rep(1:length(lengths), times = lengths)

df = data.frame(traj=labels, t=ts, x=xs, y=ys)

# output the trajectories in simple format
output.filename = paste(filename, "-trajs.csv", sep="")
write.csv(df, output.filename, row.names=FALSE)

# overall stats for this dataset
maxt = max(df$t)
ntraj = max(df$traj)

# initialise data structures. adj matrix and list, matrix for colocalisation times, data frame to store mean min distances, list to store number of vertices at each frame
amlist = data.frame(firstframe = NULL, t1 = NULL, t2 = NULL)
am = matrix(nrow = ntraj, ncol = ntraj)
colocal.time = matrix(0, nrow = ntraj, ncol = ntraj)
dist.frame = data.frame(frame = NULL, mean.min.dist = NULL)
vlist = NULL

# loop through frames
message("Computing distances...")
for(t in 1:maxt) {
  # store total number of trajectories recorded up to this frame (to account for singletons)
  vlist = c(vlist, length(unique(df$traj[df$t <= t])))
  # grab trajectories from this frame
  subset = df[df$t == t,]
  min.dists = NULL
  # loop through pairs of trajectories
  for(i in 1:nrow(subset)) {
    min.dist.2 = -1
    for(j in 1:nrow(subset)) {
      if(i != j) {
        # compute distance for this pair -- recording minimum dists
        pair.dist.2 = (subset$x[i]-subset$x[j])**2 + (subset$y[i]-subset$y[j])**2
        if(min.dist.2 == -1 | pair.dist.2 < min.dist.2) { min.dist.2 = pair.dist.2 }
       	# if this distance is below our threshold
        if(pair.dist.2 < threshold**2) {
	   # if we haven't recorded this pair yet, do so
	   if(is.na(am[subset$traj[i],subset$traj[j]])) {
  	     amlist = rbind(amlist, data.frame(firstframe = t, t1=subset$traj[i], t2=subset$traj[j]))
             am[subset$traj[i],subset$traj[j]] = am[subset$traj[j],subset$traj[i]] = t
	   }
	   # add colocalisation time to matrix
	   colocal.time[subset$traj[i],subset$traj[j]] = colocal.time[subset$traj[j],subset$traj[i]] = colocal.time[subset$traj[j],subset$traj[i]]+1
	}
      }
    }
    # summarise distance statistics
    min.dists = c(min.dists, sqrt(min.dist.2))
  }
  dist.frame = rbind(dist.frame, data.frame(frame = t, mean.min.dist = mean(min.dists)))
}

# output the adjacency list. a fake self-edge on the highest-labelled node is appended as the final entry to characterise the number of nodes
output.filename = paste(filename, "-amlist.csv", sep="")
amlist.out = rbind(amlist, data.frame(firstframe=0, t1=length(unique(df$traj)), t2=length(unique(df$traj))))
write.csv(amlist.out, output.filename, row.names=FALSE)

# initialise data frame to report statistics
stats.frame = data.frame(frame = NULL, mean.min.dist = NULL, mean.degree = NULL, sd.degree = NULL, max.degree = NULL, diameter = NULL, betweenness = NULL, efficiency = NULL, num.edges = NULL, num.vertices = NULL, cc.num = NULL, cc.mean.size = NULL, cc.max.size = NULL, singletons = NULL)

# loop through frames
message("Calculating network statistics...")
for(frame.number in 1:maxt) {
  # subset out the interactions recorded up to this frame
  amlist.frame = amlist[amlist$firstframe <= frame.number,]
  # construct graph structure from edge list. coerce to character labels first, otherwise igraph fills in any missing numeric labels -- which we don't want, as these may correspond to trajectories that have yet to appear
  edgelist.frame = as.matrix(data.frame(t1=as.character(amlist.frame$t1), t2=as.character(amlist.frame$t2)))
  g = graph_from_edgelist(edgelist.frame, directed=F)
  # figure out if we need to add any trajectories that exist, but haven't interacted, so don't appear in the edge list 
  to.add = vlist[frame.number]-length(V(g))
  g = add.vertices(g, to.add)
  # add statistics to data frame
  g.frame = data.frame(frame = frame.number, mean.min.dist = dist.frame$mean.min.dist[frame.number], mean.degree = mean(degree(g)), sd.degree = sd(degree(g)), max.degree = max(degree(g)), diameter = diameter(g), betweenness = mean(betweenness(g)), efficiency = efficiency(g, type="global"), num.edges = length(E(g)), num.vertices = length(V(g)), cc.num = components(g)$no, cc.mean.size = mean(components(g)$csize), cc.max.size = max(components(g)$csize), singletons = sum(degree(g)==0))
  stats.frame = rbind(stats.frame, g.frame)
  # if we want to output the structure at this frame, do so
  if(frame.number %in% frames.to.plot | frame.number == maxt) {
    pdf(paste("plot-", frame.number, "-", filename, ".pdf", sep=""))
    plot(g, vertex.size=0, vertex.label=NA)
    dev.off()
  }
}

# output stats table
output.filename = paste(filename, "-stats.csv", sep="")
write.csv(stats.frame, output.filename, row.names=FALSE)

message("Done.")
