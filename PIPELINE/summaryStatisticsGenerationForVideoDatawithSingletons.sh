#!/Applications/Mathematica.app/Contents/MacOS/MathematicaScript -script
graphlist = {};
singletonsgraphlist = {};
singandhistgraphlist = {};
singletonsNewList = {};
singletonsHistoricalList = {};
(*This indexlist represents how many frames are in the video, which \
we loop over to generate statistics for them all*)
(*it's important \
to change this value to an expression so It can be used as an \
expression, not a string*)

indexlist = Range[1, ToExpression[$ScriptCommandLine[[7]]]];
(*Set the name with an appropriate decription- this name will be \
reused over in the R file*)
name = $ScriptCommandLine[[3]];
resultsfilename = $ScriptCommandLine[[4]];
(*Set Directory to where the ./organelles.ce outputs are*)
\
toSetDirectory = 
 "" <> ToString[$ScriptCommandLine[[2]]] <> "" <> 
  ToString[$ScriptCommandLine[[3]]] <> ""
SetDirectory[toSetDirectory];
directory = $ScriptCommandLine[[2]];
(*Loop through the ./organelles.ce outputs*)
For[ k = 1, 
 k <= Length[indexlist], k++,
 (*Read in historical adjacency matrix*)
 
 l = ReadList[
   "" <> ToString[directory] <> "" <> ToString[name] <> "/" <> 
    ToString[resultsfilename] <> "-" <> 
    ToString[$ScriptCommandLine[[8]]] <> "-" <> 
    ToString[indexlist[[k]]] <> ".txt", {Number, Number}];
 (*Uses each number pair from historical adjacency matrix as a \
directed then undirected graphs, storing each frames graph as g5*)
 
 am = Table[l[[i]][[1]] -> l[[i]][[2]], {i, 1, Length[l]}];
   amf = Table[
   l[[i]][[1]] \[UndirectedEdge] l[[i]][[2]], {i, 1, Length[l]}];
   g5 = Graph[amf, VertexStyle -> Black];
 (*Gathers all graphs as graphlist. Note:Graphlist is used to call \
the bC and Degree histograms from later.Accessed with graphlist[[n]]*)

  graphlist = Append[graphlist, g5];
 
 (*Read in frame specific singletons list (this one is historical)*)
 
 singletons = 
  ReadList["" <> ToString[directory] <> "" <> ToString[name] <> "/" <>
     ToString[resultsfilename] <> "-" <> 
    ToString[$ScriptCommandLine[[8]]] <> "-" <> 
    ToString[indexlist[[k]]] <> "-single.txt", Number];
 (*Lets also collect a list of the number of historical singletons \
collected over time*)
 
 singletonsHistoricalList = 
  Append[singletonsHistoricalList, Length[singletons]];
 
 (*Read in frame specific singletons list (this one is for any new \
singletons in the current frame)*)
 
 singletonNew = 
  ReadList["" <> ToString[directory] <> "" <> ToString[name] <> "/" <>
     ToString[resultsfilename] <> "-" <> 
    ToString[$ScriptCommandLine[[8]]] <> "-" <> 
    ToString[indexlist[[k]]] <> "-single-new.txt", Number];
 (*For these we won't do anything else with them, so can just take \
how many novel singletons there are and make a list of them to export \
asfter leaving the loop*)
 
 singletonsNewList = Append[singletonsNewList, Length[singletonNew]];
 (*could just take vertex number from the length of the singletons \
lists being imported. But we may also want to access the ids for \
these singleton mitochondria, so we will store them in these graphs \
generations. Storing as a graph also simplifies social network stat \
extractions*)
 (*Makes a graph of singleton mitochondria, labelled by \
id, stores these networks in a list. Accessed with \
singletonsGraphList[[n]] *)
 
 singletonsGraph = Graph[singletons, {}, VertexLabels -> "Name"];
 singletonsgraphlist = Append[singletonsgraphlist, singletonsGraph];
 (*writes singletons nodes into an adjacency matrix- they have edges \
linking themslves. Ie 1\[UndirectedEdge]1. Therefore you cannot use \
these for edge counts but can for degree calc, betweeness calc and \
node number.*)
 sng = Transpose[{singletons, singletons}];
 sngam = Table[sng[[i]][[1]] -> sng[[i]][[2]], {i, 1, Length[sng]}];
   sngamf = 
  Table[sng[[i]][[1]] \[UndirectedEdge] sng[[i]][[2]], {i, 1, 
    Length[sng]}];
 (*joins historic adjacency matrix to the singletons matrix. You \
can't put single non connected nodes into graphs, unless they are all \
non connected. So, I've joined the adjacency matrix where the \
singletons are connected to themselves to the original historical \
network.*)
 historicandsingletonsgraph = Graph[Join[amf, sngamf]];
 singandhistgraphlist = 
  Append[singandhistgraphlist, historicandsingletonsgraph];
 (*While still working with each g5, export normalised BC as it needs \
the vertexnumber at that exact g5 for the calculation, and export \
just that network graph, and BC and Degree Hists for reference*)
 \
(*Export[""<>ToString[indexlist[[k]]]<>"_normalisedBC.csv",\
BetweennessCentrality[graphlist[[k]]]*2/((VertexCount[graphlist[[k]]]-\
1)*(VertexCount[graphlist[[k]]]-2))];
 Export[""<>ToString[indexlist[[k]]]<>"_maxnormalisedBC.csv",Max[\
BetweennessCentrality[graphlist[[k]]]]*2/((VertexCount[graphlist[[k]]]\
-1)*(VertexCount[graphlist[[k]]]-2))];
 Export[""<>ToString[indexlist[[k]]]<>"_meannormalisedBC.csv",Mean[\
BetweennessCentrality[graphlist[[k]]]]*2/((VertexCount[graphlist[[k]]]\
-1)*(VertexCount[graphlist[[k]]]-2))];*)
 (* with singletons *)
 
 Export["" <> ToString[indexlist[[k]]] <> "_normalisedBC_WS.csv", 
  BetweennessCentrality[
    singandhistgraphlist[[
     k]]]*2/((VertexCount[singandhistgraphlist[[k]]] - 
        1)*(VertexCount[singandhistgraphlist[[k]]] - 2))];
 Export["" <> ToString[indexlist[[k]]] <> "_maxnormalisedBC_WS.csv", 
  Max[BetweennessCentrality[
     singandhistgraphlist[[
      k]]]]*2/((VertexCount[singandhistgraphlist[[k]]] - 
        1)*(VertexCount[singandhistgraphlist[[k]]] - 2))];
 Export["" <> ToString[indexlist[[k]]] <> "_meannormalisedBC_WS.csv", 
  Mean[BetweennessCentrality[
     singandhistgraphlist[[
      k]]]]*2/((VertexCount[singandhistgraphlist[[k]]] - 
        1)*(VertexCount[singandhistgraphlist[[k]]] - 2))];
 
 (*Export["Results"<>ToString[name]<>"Frame"<>ToString[indexlist[[k]]]\
<>".jpg",g5];
 Export["Results"<>ToString[name]<>"Frame"<>ToString[indexlist[[k]]]<>\
"DegreeHist.jpg",Histogram[DegreeCentrality[g5]]];
 Export["Results"<>ToString[name]<>"Frame"<>ToString[indexlist[[k]]]<>\
"BCHist.jpg",Histogram[BetweennessCentrality[g5]]];*)
 
 Print["Results" <> ToString[name] <> "Frame" <> 
   ToString[indexlist[[k]]] <> "done"]
 ]


(*LETS also get the average distance over the network out for \
networks with singletons *)
(*THIS way adds a bunch of 0s, as the \
singleton is 0 distance from itself. But, each node in the connected \
netwrok also produces a distance to itself of 0. So, its hard to \
distinguish from singletons and connected nodes in that respect. So \
what we'll do instead is take the distance across the network for the \
without-singletons graph and divide it by the number of distances \
plus the number of singletons at that point in time*)

averagedistlistnoinfWS = {};
For[k = 1, k <= Length[indexlist], k++,
 Print["av dist Frame", ToString[k], ""];
 (*Find the average of distances across the network in each \
frame.Remove Infinities as Thats the distance found between 2 \
connected components. Also remove 0s thats the distance between a \
node and itself.*)
 averagedistlist = GraphDistanceMatrix[graphlist[[k]]];
 removedInf = DeleteCases[Flatten[averagedistlist], \[Infinity]];
 removed0 = DeleteCases[removedInf, 0];
 averagedistWS = 
  N[Total[removed0]/(Length[removed0] + 
      singletonsHistoricalList[[k]])];
 averagedistlistnoinfWS = 
  Append[averagedistlistnoinfWS, averagedistWS];
 ]


(*Stores Summary Statistic outputs as various lists, which then need \
transposing and prepending with column names*)
FrameList = indexlist;
numberccWS = Length /@ ConnectedComponents /@ singandhistgraphlist;
numbercc = Length /@ ConnectedComponents /@ graphlist;
(* Map is concerned about using level {2} to track length of the \
seprate cc, but level {1} reads lengths of whole CCs, giving numbercc \
ranther than length cc- level 2 dives one step deeper to give the \
output we want*)

sizes = Map[Length, ConnectedComponents /@ graphlist, {2}];
sizesreformat = Map[Length, ConnectedComponents /@ graphlist, {2}];
sizesWS = 
  Map[Length, ConnectedComponents /@ singandhistgraphlist, {2}];
sizesreformatWS = 
  Map[Length, ConnectedComponents /@ singandhistgraphlist, {2}];
(*Edge number should be the same, whether using graph with singletons \
or not. Edges are only between CONNECXTED nodes, not singles. We \
don't want to include self-associated edges. Therefore this edges_WS \
is just an insurance and a proof of point.*)

edgesWS = (EdgeCount /@ singletonsGraphList) + (EdgeCount /@ 
     graphlist);
edges = EdgeCount /@ graphlist;
vertices = VertexCount /@ graphlist;
verticesWS = (VertexCount /@ singletonsGraphList) + (VertexCount /@ 
     graphlist);
BCWS = BetweennessCentrality /@ singandhistgraphlist;
BC = BetweennessCentrality /@ graphlist;
(*We're using DegreeCentrality not VErtexDegree as VertexDegree \
identifies self associated nodes as having a degree of 2, which is \
not in line with our definiton of degree for singletons. \
DegreeCentrality nopminates self-associated as degree = 0*)

Degree1WS = DegreeCentrality /@ singandhistgraphlist;
Degree1 = DegreeCentrality /@ graphlist;
MeanDegreeWS = 
  Flatten[{Map[Mean, DegreeCentrality /@ singandhistgraphlist]}] ;
MeanDegree = Flatten[{Map[Mean, DegreeCentrality /@ graphlist]}] ;
MeanDegreeWS = N[MeanDegreeWS];
MeanDegree = N[MeanDegree];
SDDegreeWS = 
  Flatten[{Map[StandardDeviation, 
     DegreeCentrality /@ singandhistgraphlist]}] ;
SDDegree = 
  Flatten[{Map[StandardDeviation, DegreeCentrality /@ graphlist]}] ;
SDDegreeWS = N[SDDegreeWS];
SDDegree = N[SDDegree];
CoeffVarDegreeWS = SDDegreeWS/MeanDegreeWS;
CoeffVarDegree = SDDegree/MeanDegree;
MaxDegreeWS = 
  Flatten[{Map[Max, DegreeCentrality /@ singandhistgraphlist]}];
MaxDegree = Flatten[{Map[Max, DegreeCentrality /@ graphlist]}];
MeanBCWS = 
  Flatten[{Map[Mean, 
     BetweennessCentrality /@ singandhistgraphlist]}];
MeanBC = Flatten[{Map[Mean, BetweennessCentrality /@ graphlist]}];
MaxBCWS = 
  Flatten[{Map[Max, BetweennessCentrality /@ singandhistgraphlist]}];
MaxBC = Flatten[{Map[Max, BetweennessCentrality /@ graphlist]}];

(*Exports for singletons lists*)

Export["" <> ToString[name] <> "_CC_WS.csv", 
  Prepend[Transpose@{FrameList, numberccWS}, {"Frame", "No of CC"}]];
Export["" <> ToString[name] <> "_EN_WS.csv", 
  Prepend[Transpose@{FrameList, edgesWS}, {"Frame", "Edges"}]];
Export["" <> ToString[name] <> "_NN_WS.csv", 
  Prepend[Transpose@{FrameList, verticesWS}, {"Frame", "Nodes"}]];
Export["" <> ToString[name] <> "_SCC_WS.csv", 
  Prepend[Transpose@{FrameList, sizesWS}, {"Frame", "V1"}]];
Export["" <> ToString[name] <> "_SCCreformat2_WS.csv", 
  sizesreformatWS];
Export["" <> ToString[name] <> "_BC_WS.csv", 
  Prepend[Transpose@{BCWS}, {"V1"}]];
Export["" <> ToString[name] <> "_D_WS.csv", 
  Prepend[Transpose@{Degree1WS}, {"V1"}]];
Export["" <> ToString[name] <> "_MaxD_WS.csv", 
  Prepend[Transpose@{FrameList, MaxDegreeWS}, {"Frame", 
    "Max Degree"}]];
Export["" <> ToString[name] <> "_MaxBC_WS.csv", 
  Prepend[Transpose@{FrameList, MaxBCWS}, {"Frame", 
    "Max Betweeness Centrality"}]];
Export["" <> ToString[name] <> "_MeanD_WS.csv", 
  Prepend[Transpose@{FrameList, MeanDegreeWS}, {"Frame", 
    "Mean Degree"}]];
Export["" <> ToString[name] <> "_SdD_WS.csv", 
  Prepend[Transpose@{FrameList, SDDegreeWS}, {"Frame", 
    "SD Degree"}]];
Export["" <> ToString[name] <> "_CoeffVarD_WS.csv", 
  Prepend[Transpose@{FrameList, CoeffVarDegreeWS}, {"Frame", 
    "CoeffVarD"}]];
Export["" <> ToString[name] <> "_MeanBC_WS.csv", 
  Prepend[
   Transpose@{FrameList, MeanBCWS}, {"Frame", 
    "Mean Betweeness Centrality"}]];
Export["" <> ToString[name] <> "_F.csv", 
  Prepend[Transpose@{FrameList}, {"Frame"}]];
Export["" <> ToString[name] <> "_singletons-new-count.csv", 
  Prepend[Transpose@{FrameList, singletonsNewList}, {"Frame", 
    "New singletons in each frame"}]];
Export["" <> ToString[name] <> "_singletons-historical-count.csv", 
  Prepend[Transpose@{FrameList, singletonsHistoricalList}, {"Frame", 
    "Historical singletons count over time"}]];
Export["averageDistsOverNetworksForAllFrames_WS.csv", 
 Prepend[Transpose@{Flatten[indexlist], 
    Flatten[averagedistlistnoinfWS]}, {"Frames", 
   "Distance between all nodes, av by nodes+singletons"}]]
(*Export the desired histograms and joined listsfor historic \
adjacency matrix. BC and Degree are very long lists of lists, so are \
exported on their own then joined later in R to the framelist*)
\
(*Export[""<>ToString[name]<>"_CC.csv",Prepend[Transpose@{FrameList,\
numbercc},{"Frame","No of CC"}]];
Export[""<>ToString[name]<>"_EN.csv",Prepend[Transpose@{FrameList,\
edges},{"Frame","Edges"}]];
Export[""<>ToString[name]<>"_NN.csv",Prepend[Transpose@{FrameList,\
vertices},{"Frame","Nodes"}]];
Export[""<>ToString[name]<>"_SCC.csv",Prepend[Transpose@{FrameList,\
sizes},{"Frame","V1"}]];
Export[""<>ToString[name]<>"_SCCreformat2.csv",sizesreformat];
Export[""<>ToString[name]<>"_BC.csv",Prepend[Transpose@{BC},{"V1"}]];
Export[""<>ToString[name]<>"_D.csv",Prepend[Transpose@{Degree1},{"V1"}\
]];
Export[""<>ToString[name]<>"_MaxD.csv",Prepend[Transpose@{FrameList,\
MaxDegree},{"Frame","Max Degree"}]];
Export[""<>ToString[name]<>"_MaxBC.csv",Prepend[Transpose@{FrameList,\
MaxBC},{"Frame","Max Betweeness Centrality"}]];
Export[""<>ToString[name]<>"_MeanD.csv",Prepend[Transpose@{FrameList,\
MeanDegree},{"Frame","Mean Degree"}]];
Export[""<>ToString[name]<>"_SdD.csv",Prepend[Transpose@{FrameList,\
SDDegree},{"Frame","SD Degree"}]];
Export[""<>ToString[name]<>"_CoeffVarD.csv",Prepend[Transpose@{\
FrameList,CoeffVarDegree},{"Frame","CoeffVarD"}]];
Export[""<>ToString[name]<>"_MeanBC.csv",Prepend[Transpose@{FrameList,\
MeanBC},{"Frame","Mean Betweeness Centrality"}]];
Export[""<>ToString[name]<>"_F.csv",Prepend[Transpose@{FrameList},{\
"Frame"}]];*)

Print["SummaryStatsExported"]
(*Input the number of frames, it's important to change this value to \
an expression so It can be used as an expression, not a string*)
\
frameno = ToExpression[$ScriptCommandLine[[7]]]
(*This step take the number of frames you have, and divides it into \
11+1 equally spaced values, rounded to the nearest whole number*)
\
frameSteps = Round[Subdivide[1, frameno, 11], 1]
(*Re-load the files we've just generated to be the frames specified \
by the equal division of frame number into 11 intervals*)

graphic1 = 
  Import["Results" <> ToString[name] <> "Frame" <> 
    ToString[frameSteps[[1]]] <> ".jpg"];
graphic2 = 
  Import["Results" <> ToString[name] <> "Frame" <> 
    ToString[frameSteps[[2]]] <> ".jpg"];
graphic3 = 
  Import["Results" <> ToString[name] <> "Frame" <> 
    ToString[frameSteps[[3]]] <> ".jpg"];
graphic4 = 
  Import["Results" <> ToString[name] <> "Frame" <> 
    ToString[frameSteps[[4]]] <> ".jpg"];
graphic5 = 
  Import["Results" <> ToString[name] <> "Frame" <> 
    ToString[frameSteps[[5]]] <> ".jpg"];
graphic6 = 
  Import["Results" <> ToString[name] <> "Frame" <> 
    ToString[frameSteps[[6]]] <> ".jpg"];
graphic7 = 
  Import["Results" <> ToString[name] <> "Frame" <> 
    ToString[frameSteps[[7]]] <> ".jpg"];
graphic8 = 
  Import["Results" <> ToString[name] <> "Frame" <> 
    ToString[frameSteps[[8]]] <> ".jpg"];
graphic9 = 
  Import["Results" <> ToString[name] <> "Frame" <> 
    ToString[frameSteps[[9]]] <> ".jpg"];
graphic10 = 
  Import["Results" <> ToString[name] <> "Frame" <> 
    ToString[frameSteps[[10]]] <> ".jpg"];
graphic11 = 
  Import["Results" <> ToString[name] <> "Frame" <> 
    ToString[frameSteps[[11]]] <> ".jpg"];
graphic12 = 
  Import["Results" <> ToString[name] <> "Frame" <> 
    ToString[frameSteps[[12]]] <> ".jpg"];
(*Export these into a neat grid shape of networks- handy for quick \
visualisation*)

Export["" <> ToString[name] <> "_AllNetworks.jpg", 
  Grid[{{"Frame" <> ToString[frameSteps[[1]]] <> "", 
     "Frame" <> ToString[frameSteps[[2]]] <> "", 
     "Frame" <> ToString[frameSteps[[3]]] <> ""}, {graphic1, graphic2,
      graphic3}, {"Frame" <> ToString[frameSteps[[4]]] <> "", 
     "Frame" <> ToString[frameSteps[[5]]] <> "", 
     "Frame" <> ToString[frameSteps[[6]]] <> ""}, {graphic4, graphic5,
      graphic6}, {"Frame" <> ToString[frameSteps[[7]]] <> "", 
     "Frame" <> ToString[frameSteps[[8]]] <> "", 
     "Frame" <> ToString[frameSteps[[9]]] <> ""}, {graphic7, graphic8,
      graphic9},
    {"Frame" <> ToString[frameSteps[[10]]] <> "", 
     "Frame" <> ToString[frameSteps[[11]]] <> "", 
     "Frame" <> ToString[frameSteps[[12]]] <> ""}, {graphic10, 
     graphic11, graphic12}}]];
Print["NetworkImageGridExported"]