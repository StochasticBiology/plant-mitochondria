#!/bin/bash

mkdir ${1}${2}/walkerDegreeOutput

mv ${1}${2}/WalkerDegreeTableByStepFrame*.csv ${1}${2}/walkerDegreeOutput
mv ${1}${2}/NormalisedWalkerDegreeTableByStepFrame*.csv ${1}${2}/walkerDegreeOutput