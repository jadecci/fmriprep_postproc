#!/usr/bin/env bash

# usage
if [ $# -ne 3 ]; then
  echo "Usage: $0 start stop interval"; exit
fi

# get input parameter
start=$1
stop=$2
interval=$3

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

  if [ -e results/sub-$subject/intermediate/sub-${subject}_task-rest_run-01_bold_mcf.nii.gz.par ]; then
    echo "sub-$subject is already completed."
  else
    echo "submitting job for sub-$subject..."
    cmd="$project_dir/fmriprep_singleSub.sh $subject"
    /data/users/jianxiaow/storage/projects/Git_codes/utilities/imgRegProj_pbsubmit.sh $work_dir fmriprep 10 2 10 "$cmd"
    sleep $interval
  fi
done
