#!/Applications/Mathematica.app/Contents/MacOS/MathematicaScript -script
graphlist = {};
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
 l = ReadList[
   "" <> ToString[directory] <> "" <> ToString[name] <> "/" <> 
    ToString[resultsfilename] <> "-" <> 
    ToString[$ScriptCommandLine[[8]]] <> "-" <> 
    ToString[indexlist[[k]]] <> ".txt", {Number, Number}];
 (*USes each number pair as a directed then undirected graphs, \
storing each frames graph as g5*)
 
 am = Table[l[[i]][[1]] -> l[[i]][[2]], {i, 1, Length[l]}];
 amf = Table[l[[i]][[1]] <-> l[[i]][[2]], {i, 1, Length[l]}];
 g5 = Graph[amf, VertexStyle -> Black];
 (*Gathers all graphs as graphlist. Note:Graphlist is used to call \
the bC and Degree histograms from later*)
 
 graphlist = Append[graphlist, g5];
 (*While still working with each g5, export normalised BC as it needs \
the vertexnumber at that exact g5 for the calcualation, and export \
just that network graph, and BC and DEgree Hists for reference*)
 
 Export["" <> ToString[indexlist[[k]]] <> "_normalisedBC.csv", 
  BetweennessCentrality[
    graphlist[[
     k]]]*2/((VertexCount[graphlist[[k]]] - 
        1)*(VertexCount[graphlist[[k]]] - 2))];
 Export["" <> ToString[indexlist[[k]]] <> "_maxnormalisedBC.csv", 
  Max[BetweennessCentrality[
     graphlist[[
      k]]]]*2/((VertexCount[graphlist[[k]]] - 
        1)*(VertexCount[graphlist[[k]]] - 2))];
 Export["" <> ToString[indexlist[[k]]] <> "_meannormalisedBC.csv", 
  Mean[BetweennessCentrality[
     graphlist[[
      k]]]]*2/((VertexCount[graphlist[[k]]] - 
        1)*(VertexCount[graphlist[[k]]] - 2))];
 Export["Results" <> ToString[name] <> "Frame" <> 
    ToString[indexlist[[k]]] <> ".jpg", g5]
  Export["Results" <> ToString[name] <> "Frame" <> 
    ToString[indexlist[[k]]] <> "DegreeHist.jpg", 
   Histogram[DegreeCentrality[g5]]];
 Export["Results" <> ToString[name] <> "Frame" <> 
   ToString[indexlist[[k]]] <> "BCHist.jpg", 
  Histogram[BetweennessCentrality[g5]]];
 Print["Results" <> ToString[name] <> "Frame" <> 
   ToString[indexlist[[k]]] <> "done"]
 ]
(*Stores Summary Statistic outputs as various lists, which then need \
transposing and prepending with column names*)
FrameList = indexlist;
numbercc = Length /@ ConnectedComponents /@ graphlist;
Transpose[{{FrameList}, {numbercc}}] // TableForm;
(* Map is concerned about using level {2} to track length of the \
seprate cc, but level {1} reads lengths of whole CCs, giving numbercc \
ranther than length cc- level 2 dives one step deeper to give the \
output we want*)

sizes = Map[Length, ConnectedComponents /@ graphlist, {2}];
sizesreformat = Map[Length, ConnectedComponents /@ graphlist, {2}];
Transpose[{{FrameList}, {sizes}}] // TableForm;
edges = EdgeCount /@ graphlist;
Transpose[{{FrameList}, {edges}}] // TableForm;
vertices = VertexCount /@ graphlist;
Transpose[{{FrameList}, {vertices}}] // TableForm;
BC = BetweennessCentrality /@ graphlist;
Transpose[{{FrameList}, {BC}}] // TableForm;
Degree1 = DegreeCentrality /@ graphlist;
MeanDegree = Flatten[{Map[Mean, DegreeCentrality /@ graphlist]}] ;
MeanDegree = N[MeanDegree]
SDDegree = 
  Flatten[{Map[StandardDeviation, DegreeCentrality /@ graphlist]}] ;
SDDegree = N[SDDegree]
CoeffVarDegree = SDDegree/MeanDegree
MaxDegree = Flatten[{Map[Max, DegreeCentrality /@ graphlist]}];
MeanBC = Flatten[{Map[Mean, BetweennessCentrality /@ graphlist]}];
MaxBC = Flatten[{Map[Max, BetweennessCentrality /@ graphlist]}];
Transpose[{{FrameList}, {Degree1}}] // TableForm;

(*Export the desired histograms and joined lists. BC and Degree are \
very long lists of lists, so are exported on their own then joined \
later in R to the framelist*)

Export["" <> ToString[name] <> "_CC.csv", 
  Prepend[Transpose@{FrameList, numbercc}, {"Frame", "No of CC"}]];
Export["" <> ToString[name] <> "_EN.csv", 
  Prepend[Transpose@{FrameList, edges}, {"Frame", "Edges"}]];
Export["" <> ToString[name] <> "_NN.csv", 
  Prepend[Transpose@{FrameList, vertices}, {"Frame", "Nodes"}]];
Export["" <> ToString[name] <> "_SCC.csv", 
  Prepend[Transpose@{FrameList, sizes}, {"Frame", "V1"}]];
Export["" <> ToString[name] <> "_SCCreformat2.csv", sizesreformat];
Export["" <> ToString[name] <> "_BC.csv", 
  Prepend[Transpose@{BC}, {"V1"}]];
Export["" <> ToString[name] <> "_D.csv", 
  Prepend[Transpose@{Degree1}, {"V1"}]];
Export["" <> ToString[name] <> "_MaxD.csv", 
  Prepend[Transpose@{FrameList, MaxDegree}, {"Frame", 
    "Max Degree"}]];
Export["" <> ToString[name] <> "_MaxBC.csv", 
  Prepend[Transpose@{FrameList, MaxBC}, {"Frame", 
    "Max Betweeness Centrality"}]];
Export["" <> ToString[name] <> "_MeanD.csv", 
  Prepend[Transpose@{FrameList, MeanDegree}, {"Frame", 
    "Mean Degree"}]];
Export["" <> ToString[name] <> "_SdD.csv", 
  Prepend[Transpose@{FrameList, SDDegree}, {"Frame", "SD Degree"}]];
Export["" <> ToString[name] <> "_CoeffVarD.csv", 
  Prepend[Transpose@{FrameList, CoeffVarDegree}, {"Frame", 
    "CoeffVarD"}]];
Export["" <> ToString[name] <> "_MeanBC.csv", 
  Prepend[Transpose@{FrameList, MeanBC}, {"Frame", 
    "Mean Betweeness Centrality"}]];
Export["" <> ToString[name] <> "_F.csv", 
  Prepend[Transpose@{FrameList}, {"Frame"}]];
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
