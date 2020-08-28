#!/Applications/Mathematica.app/Contents/MacOS/MathematicaScript -script

(*directory="/Users/d1795494/Documents/PIPELINE/MitoGFP/";
toSetDirectory="/Users/d1795494/Documents/PIPELINE/MitoGFP/\
ScaleAndCrop-zoomedvid4outfocus";
SetDirectory[toSetDirectory];
name="ScaleAndCrop-zoomedvid4outfocus";
resultsfilename="zoomedvideo4outfocusADJUSTEDCROPPEDabs1.csv";
indexlist=Range[1,118];
colocdist="8.0";*)
directory = $ScriptCommandLine[[2]];
toSetDirectory = 
  "" <> ToString[$ScriptCommandLine[[2]]] <> "" <> 
   ToString[$ScriptCommandLine[[3]]] <> "";
SetDirectory[toSetDirectory];
name = $ScriptCommandLine[[3]];
resultsfilename = $ScriptCommandLine[[4]];
colocdist = $ScriptCommandLine[[8]];
indexlist = Range[1, ToExpression[$ScriptCommandLine[[7]]]];
graphlist = {};

For[ k = 1, k <= Length[indexlist], k++,
 networkdata = 
  ReadList["" <> ToString[directory] <> "" <> ToString[name] <> "/" <>
     ToString[resultsfilename] <> "-" <> ToString[colocdist] <> "-" <>
     ToString[indexlist[[k]]] <> ".txt", {Number, Number}];
 am = Table[
   networkdata[[i]][[1]] -> networkdata[[i]][[2]], {i, 1, 
    Length[networkdata]}];
 amf = Table[
   networkdata[[i]][[1]] \[UndirectedEdge] networkdata[[i]][[2]], {i, 
    1, Length[networkdata]}];
 graph = Graph[amf];
 graphlist = Append[graphlist, graph];
 ]
(*Gather the list of connected components sizes of each frame*)

sizes = Map[Length, ConnectedComponents /@ graphlist, {2}];
(*From these, gather the size of the largest connected component in \
that frame, and the total size of connected copmponents in that frame*)
\
(*Take the proportional size of connected components by doing largest \
size/total size for each set of connected components in a frame*)

LargestCCList = {};
TotalCCsList = {};
For[i = 1, i <= Length[sizes], i++,
 LargestCCList = Append[LargestCCList, sizes[[i]][[1]]];
 TotalCCsList = Append[TotalCCsList, Total[sizes[[i]]]];
 ]
proportionList = N[LargestCCList/TotalCCsList];
(*For each of the proportional sizes of connected components,if the \
size of proportional connected components is greater than 0.5 AND the \
previous connected component was under 0.5, store the frame number at \
which that happens. If there is no increase to or above 0.5 at all, \
store the time point at which this jump occurs as Infinity*)

listOfPassableFrames = {};
sizebefore = {};
sizeafter = {};
For[c = 1, c < Length[proportionList], c++,
 If[proportionList[[c]] >= 0.5,
  If[proportionList[[c - 1]] < 0.5,
   listOfPassableFrames = Append[listOfPassableFrames, c];
   sizebefore = Append[sizebefore, proportionList[[c - 1]]];
   sizeafter = Append[sizeafter, proportionList[[c]]];
   ]
  ]
 ]
If[Length[listOfPassableFrames] == 0, ( 
  listOfPassableFrames = Append[listOfPassableFrames, "Infinity"]; 
  sizebefore = Append[sizebefore, "NA"]; 
  sizeafter = Append[sizeafter, "NA"];)]

(*Export this list of time points where crossing over 0.5 \
proportional size occured occurred*)
jumpsTable = 
 List[Flatten[listOfPassableFrames], Flatten[sizebefore], 
  Flatten[sizeafter]]; Export[
 "percolationThresholdJumps" <> ToString[name] <> ".csv", 
 Prepend[Transpose[jumpsTable], {"FrameOfOccurance", "propsizebefore",
     "propsizeafter"}] // TableForm]
(*Transpose[List[Flatten[indexlist],Flatten[LargestCCList]]]//\
TableForm*)