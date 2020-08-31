#!/Applications/Mathematica.app/Contents/MacOS/MathematicaScript -script

(*This indexlist represents how many frames are in the video,which we \
loop over to generate networks for them all*)
(*its important to \
change this value to an expression so It can be used as an \
expression,not a string*)

(*IF you want to do the calculation for averageDistanceOverNetwork \
WITH Singletons, 
it's in the summaryStatisticsGenerationForVideoDatawithSingletons.sh \
document*)

indexlist = Range[1, ToExpression[$ScriptCommandLine[[7]]]];
name = $ScriptCommandLine[[3]];
resultsfilename = $ScriptCommandLine[[4]];
toSetDirectory = 
 "" <> ToString[$ScriptCommandLine[[2]]] <> "" <> 
  ToString[$ScriptCommandLine[[3]]] <> ""
SetDirectory[toSetDirectory];
colocdist = $ScriptCommandLine[[8]];
directory = $ScriptCommandLine[[2]];

graphlist = {};

(*Loop through the./organelles.ce outputs*)
For[k = 1, 
 k <= Length[indexlist], k++,(*Read in historical adjacency matrix*)
 l = ReadList[
   "" <> ToString[directory] <> "" <> ToString[name] <> "/" <> 
    ToString[resultsfilename] <> "-" <> ToString[colocdist] <> "-" <> 
    ToString[indexlist[[k]]] <> ".txt", {Number, Number}];
 (*Uses each number pair from historical adjacency matrix as a \
directed then undirected graphs,storing each frames graph as g5*)
 am = Table[l[[i]][[1]] -> l[[i]][[2]], {i, 1, Length[l]}];
 amf = Table[
   l[[i]][[1]] \[UndirectedEdge] l[[i]][[2]], {i, 1, Length[l]}];
 g5 = Graph[amf, VertexStyle -> Black];
 (*Gathers all graphs as graphlist.Note:Graphlist is used to call the \
bC and Degree histograms from later.Accessed with graphlist[[n]]*)
 graphlist = Append[graphlist, g5];
 ]

(*This function works to generate 100 erdos renyi networks based on \
the degree distribution of the input network,calculate their maxmin \
distance,and average these values.You can then use these values to \
normalise the graphs you generate by.*)
(*Due to some of the random \
networks having or not having seperate connected components,not all \
of the largest distances come out at infinity,like they do if you \
have seperate connected components.In order to get around the value \
of allmaxdists[[1]] being or not being infinity,I wrote an If catch \
on it,that builds a new list (newmaxdists) from the allmaxdists1 if \
its not infinity,and allmaxdists2 otherwise.*)

ErdosRenyiGraphsx100[x_] := Module[{graph = x}, allmaxdists1 = {};
  allmaxdists2 = {};
  newmaxdists = {};
  For[m = 1, m <= 100, m++,
    (*Make the erdos renyi based off corresponding degree \
distribution*)
    ex = RandomGraph[DegreeGraphDistribution[DegreeCentrality[graph]]];
    (*Get the minimum maximum distance for it*)
    maxdists = 
     DeleteDuplicates[Reverse[Sort[Flatten[GraphDistanceMatrix[ex]]]]];
    (*exclude the infinities*)
    If[maxdists[[1]] < \[Infinity], 
     newmaxdists = Append[newmaxdists, maxdists[[1]]], 
     newmaxdists = Append[newmaxdists, maxdists[[2]]]];
    allmaxdists1 = Append[allmaxdists1, maxdists[[1]]];
    allmaxdists2 = Append[allmaxdists2, maxdists[[2]]];]
   (*return the max min dists*) Return[Mean[newmaxdists], Module]]

maxmindistlistnoinf = {};
averagedistlistnoinf = {};
normalisedlist100 = {};
For[k = 1, k <= Length[indexlist], k++, 
 Print["Frame", ToString[k], ""];
 maxmindistlist = {};
 (*Find the average of distances across the network in each \
frame.Remove Infinities as Thats the distance found between 2 \
connected components.Also remove 0s thats the distance between a node \
and itself.*)averagedistlist = GraphDistanceMatrix[graphlist[[k]]];
 removedInf = DeleteCases[Flatten[averagedistlist], \[Infinity]];
 removed0 = DeleteCases[removedInf, 0];
 averagedist = N[Mean[removed0]];
 averagedistlistnoinf = Append[averagedistlistnoinf, averagedist];
 (*Find the maximum minimum distance across the network in each frame*)
 maxmindist = 
  DeleteDuplicates[
   Reverse[Sort[Flatten[GraphDistanceMatrix[graphlist[[k]]]]]]];
 (*exclude the infinities*)
 If[maxmindist[[1]] < \[Infinity], 
  maxmindistlist = Append[maxmindistlist, maxmindist[[1]]], 
  maxmindistlist = Append[maxmindistlist, maxmindist[[2]]]];
 (*Build up a list of these max distances,one for each frame*)
 maxmindistlistnoinf = Append[maxmindistlistnoinf, maxmindistlist];
 (*Then,we want to normalise depending on each graphs degree \
distribution*)
 normalisedmaxmindist100 = ErdosRenyiGraphsx100[graphlist[[k]]];
 normalisedlist100 = 
  Append[normalisedlist100, normalisedmaxmindist100];
 (*normalisedmaxmindist10=ErdosRenyiGraphsx10[graphlist[[k]]];
 normalisedlist10=Append[normalisedlist10,normalisedmaxmindist10];*)]

Print["Running Export"]
Export["normalisedAndRawMaxMinDistsForAllFrames.csv", 
 Prepend[Transpose@{Flatten[indexlist], Flatten[maxmindistlistnoinf], 
    N[normalisedlist100], 
    Flatten[N[maxmindistlistnoinf/normalisedlist100]]}, {"Frames", 
   "Max Min Dist", "Norm Max Min Dist from x100 ERs", 
   "MaxMin/NormMaxMin100"}]]

Export["averageDistsOverNetworksForAllFrames.csv", 
 Prepend[Transpose@{Flatten[indexlist], 
    Flatten[averagedistlistnoinf]}, {"Frames", 
   "Average Distance between all nodes in the network"}]]
