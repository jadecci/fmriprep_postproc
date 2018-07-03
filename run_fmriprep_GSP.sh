#!/usr/bin/env bash

# usage
if [ $# -ne 3 ]; then
  echo "Usage: $0 start stop interval"; exit
fi

# get input parameter
start=$1
stop=$2
interval=$3

# set up
project_dir=/data/users/jianxiaow/storage/projects/Fmriprep
work_dir=$project_dir/results/job_files
mkdir -p $work_dir
sublist=$CBIG_CODE_DIR/stable_projects/preprocessing/CBIG_fMRI_Preproc2016/unit_tests/100subjects_clustering/GSP_80_low_motion+20_w_censor.txt
func_dir=/mnt/yeogrp/data/GSP2016/CBIG_preproc_global_cen_bp/GSP_single_session/CBIG2016_preproc_global_cen_bp

# loop through each subject
subnames=`head -$stop $sublist | tail -n $(($stop-$start+1))`
for sub in $subnames
do
  subject=${sub%_Ses1}
  subject=${subject#Sub} 

  # check if subject is already run
  if [ -e results/sub-$subject/intermediate/sub-${subject}_task-rest_run-01_bold_valid_mcf.nii.gz.par -a -e results/sub-$subject/func/sub-${subject}_task-rest_run-01_bold_space-fsaverage6.L.func.gii ]; then
    echo "sub-$subject run 1 is already completed."
    if [ -e $func_dir/Sub${subject}_Ses1/bold/003/Sub${subject}_Ses1_bld003_rest_skip4.nii.gz ]; then
      if [ -e results/sub-$subject/intermediate/sub-${subject}_task-rest_run-02_bold_valid_mcf.nii.gz.par -a -e results/sub-$subject/func/sub-${subject}_task-rest_run-02_bold_space-fsaverage6.L.func.gii ]; then 
        echo "sub-$subject run 2 is already completed."
        continue
      fi
    else 
      echo "sub-$subject does not have run 2."
      continue
    fi
  fi

  # run fmriprep
  echo "submitting job for sub-$subject..."
  cmd="$project_dir/fmriprep_singleSub.sh $subject"
  /data/users/jianxiaow/storage/projects/Git_codes/utilities/imgRegProj_pbsubmit.sh $work_dir fmriprep 10 2 10 "$cmd"
  sleep $interval
done
