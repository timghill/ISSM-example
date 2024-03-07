#!/bin/bash

# Run suite of matlab ISSM simulations. The suite is defined by table.dat
# and this script loops through the table to run each case.
# This is a stripped down version of the META-Farm
# (https://docs.alliancecan.ca/wiki/META-Farm)
# scripts available on the compute canada clusters.

TABLE=table.dat

matlab="${HOME}/MATLAB/R2022b/bin/matlab"   # Might need to change this for your system
for i1 in {1..5}; do
    LINE=`sed -n ${i1}p $TABLE`
    ID=`echo "$LINE" | cut -d" " -f1`
    COMM=`echo "$LINE" | cut -d" " -f2-`

    echo "Case $ID:"
    
    $matlab -nodisplay -r "try, $COMM; quit(); catch ME, disp(ME.message); quit(1); end; quit;" > log${i1}.txt
    status=$?
done
