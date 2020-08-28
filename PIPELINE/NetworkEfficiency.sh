#!/Applications/Mathematica.app/Contents/MacOS/MathematicaScript -script
indexlist = Range[1, ToExpression[$ScriptCommandLine[[7]]]];
name = $ScriptCommandLine[[3]];
resultsfilename = $ScriptCommandLine[[4]];
directory = $ScriptCommandLine[[2]];
toSetDirectory =
 "" <> ToString[directory] <> "" <> ToString[name] <> ""
SetDirectory[toSetDirectory];

graphlist = {};
singletonsgraphlist = {};
singandhistgraphlist = {};
singletonsNewList = {};
singletonsHistoricalList = {};
For[ k = 1, k <= Length[indexlist], k++,
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
 graphlist = Append[graphlist, g5];
 
 (*Read in frame specific singletons list (this one is historical)*)
 
 singletons =
  ReadList["" <> ToString[directory] <> "" <> ToString[name] <> "/" <>
     ToString[resultsfilename] <> "-" <>
    ToString[$ScriptCommandLine[[8]]] <> "-" <>
    ToString[indexlist[[k]]] <> "-single.txt", Number];
 
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
 
 sng = Transpose[{singletons, singletons}];
 sngam = Table[sng[[i]][[1]] -> sng[[i]][[2]], {i, 1, Length[sng]}];
   sngamf =
  Table[sng[[i]][[1]] \[UndirectedEdge] sng[[i]][[2]], {i, 1,
    Length[sng]}];
 
 historicandsingletonsgraph = Graph[Join[amf, sngamf]];
 singandhistgraphlist =
  Append[singandhistgraphlist, historicandsingletonsgraph];
 
 ]


NetworkEfficiency[x_] := Module[{graph = x},
  g = graph;
  (*Must remove infinities as they are irrelevant, and cases of 0-
  as cant do 1/0 in the sumUnder equation*)
  
  ShortestPathsij =
   DeleteCases[Flatten[GraphDistanceMatrix[g]], \[Infinity]];
  ShortestPathsij = DeleteCases[Flatten[ShortestPathsij], 0];
  (*a catch put in here- if all nodes are singletons,
  the string of ShortestPathsij will return as empty,
  it still needs to be 0 efficiency. So set it to 0*)
  
  If[ MatchQ[ShortestPathsij, {}] == True,
   ShortestPathsij = Append[ShortestPathsij, 0],
   (*else*)
   
   InverseDistances = Map[Function[{y}, 1/y], ShortestPathsij];
   InverseSum = Total[InverseDistances];
   nodes = VertexCount[g];
   EG = 1/(nodes (nodes - 1))* InverseSum;
   Return[EG];
   ]
  ]

EfficiencyList = {};
For [i = 1, i <= Length[singandhistgraphlist], i++,
 currentEfficiency = NetworkEfficiency[singandhistgraphlist[[i]]];
 EfficiencyList = Append[EfficiencyList, currentEfficiency];
 Print["NetEfficiencyNew" <> ToString[name] <> "Frame" <>
   ToString[indexlist[[i]]] <> "done"];
 ]
Export["avNetworkEfficiency_WS.csv",
 Prepend[Transpose@{Flatten[indexlist],
    Flatten[N[EfficiencyList, 3]]}, {"Frames",
   "Network Efficieny, averagedoverallnodes-incSingletons"}]]
