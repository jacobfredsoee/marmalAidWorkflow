#!/bin/bash

source /com/extra/R/3.1.0/load.sh

FILELIST=$(find /home/siri/MarmalAid/Rdata/ -name "*_nm_imp.Rdata")

for outfile in $FILELIST
do
     qx --no-scratch --mem 4gb -t=00:10:00 "Rscript ./ChAMPProcess.R $outfile"
done