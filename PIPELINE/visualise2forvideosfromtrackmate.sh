#!/Applications/Mathematica.app/Contents/MacOS/MathematicaScript -script

directory = $ScriptCommandLine[[2]]
video = $ScriptCommandLine[[3]]
file = $ScriptCommandLine[[4]]
SetDirectory["" <> ToString[directory] <> "" <> ToString[video] <> ""]

filepoint = file;
l1t = ReadList[filepoint, String];
l1 = ToExpression[StringSplit[Drop[l1t, 2]]]
n = Max[Transpose[l1][[2]]] + 1;
nt = Max[Transpose[l1][[3]]] + 1;
lines = Table[{}, {i, 1, n}];
For[i = 1, i <= Length[l1], i++,
  AppendTo[lines[[l1[[i]][[2]] + 1]], {l1[[i]][[4]], l1[[i]][[5]]}];
  ];

Graphics[{ Opacity[0.3], 
  Table[Line[lines[[i]]], {i, 1, Length[lines]}]}, 
 PlotRange -> {{0, 150}, {0, 150}}]

Export[filepoint <> ".pdf", 
 Graphics[{ Opacity[0.3], 
   Table[Line[lines[[i]]], {i, 1, Length[lines]}]}, 
  PlotRange -> {{0, 150}, {0, 150}}]]

points = Table[{}, {i, 1, nt}];
For[i = 1, i <= Length[l1], i++,
  AppendTo[points[[l1[[i]][[3]] + 1]], {l1[[i]][[4]], l1[[i]][[5]]}];
  ];

vid = ListAnimate[
  Table[Graphics[{Black, Point[points[[i]]], LightGray}, 
    PlotRange -> {{0, 150}, {0, 150}}], {i, 1, 100}]]

Export[filepoint <> ".gif", 
 Table[Graphics[{Black, Point[points[[i]]], LightGray}, 
   PlotRange -> {{0, 150}, {0, 150}}], {i, 1, 100}]]
