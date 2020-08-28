#!/bin/bash

awk 'BEGIN{n=i=0; printf("\tTrajectory\tFrame\tx\ty\tz\tm0\tm1\tm2\tm3\tm4\tNPscore\n");}{
if($0 ~ "nSpots") n++;
if($0 ~ "detection")
{
  i++;
  split($0, a, "\"");
  printf("%i\t%i\t%i\t%f\t%f\t0\t0\t0\t0\t0\t0\t0\n", i, n, a[2], a[4], a[6]);
}
}' $1 > $1.csv

#Start at beginning
#If the line you're on says nSpots move on a line
#If it says detection, stop and look at the line
#Take the line, and split it up by the special character "  (you need to write special characters with a \ before them, or they cannot be escaped)
#print the n number line (here corresponding to abitrary trajectory name), as well as t, x and y.
