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
work_dir=$project_dir/results/job_files
mkdir -p $work_dir
sublist=$CBIG_CODE_DIR/stable_projects/preprocessing/CBIG_fMRI_Preproc2016/unit_tests/100subjects_clustering/GSP_80_low_motion+20_w_censor.txt
subnames=`head -$stop $sublist | tail -n $(($stop-$start+1))`
for sub in $subnames
do
  subject=${sub%_Ses1}
  subject=${subject#Sub} 

  if [ -e results/sub-$subject/intermediate/sub-${subject}_task-rest_run-01_bold_space-fsaverage6_residc_interp_bp.R.nii.gz ]; then
    echo "sub-$subject is already processed."
  else
    echo "running sub-$subject..."
    $project_dir/fmriprep_regress.sh $subject
    $project_dir/fmriprep_censor_bp.sh $subject
    $project_dir/fmriprep_sm_ds.sh $subject
  fi
done
