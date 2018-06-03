#!/usr/bin/env bash

# usage
if [ $# -ne 2 ]; then
  echo "Usage: $0 start stop"; exit
fi

# get input parameter
start=$1
stop=$2

# loop through each subject
subnames=`head -$stop GSP_subjectnames.csv | tail -n $(($stop-$start+1))`
for sub in $subnames
do
  subject=${sub%_Ses1}
  subject=${subject#Sub} 
  echo "submitting job for sub-$subject..."
  qsub fmriprep_singleSub.pbs -v subject=$subject
done
