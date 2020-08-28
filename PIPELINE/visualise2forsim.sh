#!/Applications/Mathematica.app/Contents/MacOS/MathematicaScript -script
filename = StringReplace[$ScriptCommandLine[[3]], "_" -> "-"]
SetDirectory[
 "" <> ToString[$ScriptCommandLine[[2]]] <> "" <> 
  ToString[$ScriptCommandLine[[3]]] <> ""]
filecyt = "simoutput-" <> ToString[filename] <> ".cyt.txt";
filepoint = "simoutput-" <> ToString[filename] <> ".txt";
l = ReadList[filecyt, {Number, Number}];
l1t = ReadList[filepoint, String];
l1 = ToExpression[StringSplit[Drop[l1t, 2]]];
n = Max[Transpose[l1][[2]]] + 1;
nt = Max[Transpose[l1][[3]]] + 1;
lines = Table[{}, {i, 1, n}];
For[i = 1, i <= Length[l1], i++,
  AppendTo[lines[[l1[[i]][[2]] + 1]], {l1[[i]][[4]], l1[[i]][[5]]}];
  ];
skeleton = Table[Point[l[[i]]], {i, 1, Length[l]}];
Graphics[{skeleton, Opacity[0.1], 
   Table[Line[lines[[i]]], {i, 1, Length[lines]}]}, 
  PlotRange -> {{0, 30}, {0, 100}}];
Export[filepoint <> ".pdf", 
 Graphics[{skeleton, Opacity[0.1], 
   Table[Line[lines[[i]]], {i, 1, Length[lines]}]}, 
  PlotRange -> {{0, 30}, {0, 100}}]]
points = Table[{}, {i, 1, nt}];
For[i = 1, i <= Length[l1], i++,
  AppendTo[points[[l1[[i]][[3]] + 1]], {l1[[i]][[4]], l1[[i]][[5]]}];
  ];
vid = ListAnimate[
  Table[Graphics[{Black, Point[points[[i]]], LightGray, skeleton}, 
    PlotRange -> {{0, 30}, {0, 100}}], {i, 1, 200}]];

Export[filepoint <> ".gif", 
 Table[Graphics[{Black, Point[points[[i]]], LightGray, skeleton}, 
   PlotRange -> {{0, 30}, {0, 100}}], {i, 1, 200}]];
(*To alter the size of the gifs and trace, alter the {0,30}{0,100}. Also alter the below table to have ten on either side of the x and y values so you can get a nice clear boundary around the trace*)

set = Table[
   Blur[Graphics[{Black, Rectangle[{-10, -10}, {40, 110}], 
      FaceForm[], EdgeForm[Red], Rectangle[{0, 0}, {30, 100}], 
      EdgeForm[], FaceForm[Green], 
      Table[Disk[points[[j]][[i]], 1.0], {i, 1, 
        Length[points[[j]]]}]}], 4], {j, 1, 200}];
(*the Table[Disk[Points[]]]],1.8] number is the intensity of the green of the mitos, i altered this from 0.8 to 1.8*)

Export[filepoint <> "-render.gif", set, 
 PlotRange -> {{-10, -10}, {40, 110}}];
Print["finished ",allParameters]
Exit[]
