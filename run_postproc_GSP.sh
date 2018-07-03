#!/usr/bin/env bash

# usage
if [ $# -ne 2 ]; then
  echo "Usage: $0 start stop"; exit
fi

# get input parameter
start=$1
stop=$2

# loop through each subject
project_dir=/data/users/jianxiaow/storage/projects/Fmriprep
sublist=$CBIG_CODE_DIR/stable_projects/preprocessing/CBIG_fMRI_Preproc2016/unit_tests/100subjects_clustering/GSP_80_low_motion+20_w_censor.txt
subnames=`head -$stop $sublist | tail -n $(($stop-$start+1))`
for sub in $subnames
do
  subject=${sub%_Ses1}
  subject=${subject#Sub} 

  echo "running sub-$subject..."
  echo ">>>>> Regression <<<<<"
  $project_dir/fmriprep_regress.sh $subject
  echo ">>>>> Censoring & Bandpass <<<<<"
  $project_dir/fmriprep_censor_bp.sh $subject
  echo ">>>>> Smoothing & Downsampling <<<<<"
  $project_dir/fmriprep_sm_ds.sh $subject
done
