#!/bin/bash


cd ./PIPELINE/

#make executable
gcc physnew-28-11-19.c -I/usr/local/include/igraph -L/usr/local/lib/ -ligraph -lm -o physnew-28-11-19.ce

cd ./PIPELINE/

#here alter the colocalisation distance (microns), here currently set to 1.6
./physnew-28-11-19.ce --simulation ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10} ${11} ${12} ${13} 1.6

echo ""

 mv simoutput-${1}-${2}-${3}-${4}-${5}-${6}-${7}-${8}-${9}-${10}-${11}-${12}-${13}.cyt.txt ./PIPELINE/simulations/${1}_${2}_${3}_${4}_${5}_${6}_${7}_${8}_${9}_${10}_${11}_${12}_${13}
 mv simoutput-${1}-${2}-${3}-${4}-${5}-${6}-${7}-${8}-${9}-${10}-${11}-${12}-${13}.txt ./PIPELINE/simulations/${1}_${2}_${3}_${4}_${5}_${6}_${7}_${8}_${9}_${10}_${11}_${12}_${13}
 mv simstats-${1}-${2}-${3}-${4}-${5}-${6}-${7}-${8}-${9}-${10}-${11}-${12}-${13}-1.600.txt ./PIPELINE/simulations/${1}_${2}_${3}_${4}_${5}_${6}_${7}_${8}_${9}_${10}_${11}_${12}_${13}
 mv networks-${1}-${2}-${3}-${4}-${5}-${6}-${7}-${8}-${9}-${10}-${11}-${12}-${13}-1.600.txt ./PIPELINE/simulations/${1}_${2}_${3}_${4}_${5}_${6}_${7}_${8}_${9}_${10}_${11}_${12}_${13}


#here alter the time interval (seconds, currently 1.1628), resolution (pixels per microns, currently set to 1), frame number (currently set to 198), and colocalisation distance (mocrons, currently set to 1.6)
./masterSSGeneration.sh ./PIPELINE/simulations/ ${1}_${2}_${3}_${4}_${5}_${6}_${7}_${8}_${9}_${10}_${11}_${12}_${13} simoutput-${1}-${2}-${3}-${4}-${5}-${6}-${7}-${8}-${9}-${10}-${11}-${12}-${13}.txt 1.1628 1.000 198 1.6


cd ./PIPELINE/simulations/${1}_${2}_${3}_${4}_${5}_${6}_${7}_${8}_${9}_${10}_${11}_${12}_${13}

cp ${1}_${2}_${3}_${4}_${5}_${6}_${7}_${8}_${9}_${10}_${11}_${12}_${13}_AllNetworks.jpg ./PIPELINE/simulations/AllAutomatedNetworkOutputs


cd ./PIPELINE/
