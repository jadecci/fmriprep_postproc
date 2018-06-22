#!/usr/bin/env bash

# set up directories
subject=$1
project_dir=/data/users/jianxiaow/storage/projects/Fmriprep
preproc_util_dir=$CBIG_CODE_DIR/stable_projects/preprocessing/CBIG_fMRI_Preproc2016/utilities
func_dir=$project_dir/results/sub-$subject/func
intermediate_dir=$project_dir/results/sub-$subject/intermediate
regress_dir=$project_dir/results/sub-$subject/regress

for run in 01 02
do
  echo "Processing subject $subject run $run..."
  prefix=sub-${subject}_task-rest_run-${run}
  if [ ! -e $func_dir/${prefix}_bold_space-fsaverage6_residc.L.nii.gz ]; then
    echo "Subject $subject does not have run $run. Skipping..."
    continue
  fi

  for hemi in L R
  do

    # censoring
    echo "$hemi: 1. censoring"
    input=$func_dir/${prefix}_bold_space-fsaverage6_residc.$hemi.nii.gz
    outliers_file=$regress_dir/${prefix}_motion_outliers.txt
    TR=`mri_info $input | grep -o 'TR: \(.*\)' | awk -F " " '{print $2}'`
    output_inter=$intermediate_dir/${prefix}_interp_inter.$hemi.nii.gz
    output=$func_dir/${prefix}_bold_space-fsaverage6_residc_interp.$hemi.nii.gz
    matlab -nodesktop -nosplash -r "addpath('$preproc_util_dir'); CBIG_preproc_censor_wrapper('$input', '$outliers_file', '$TR', '$output_inter', '$output'); rmpath('$preproc_util_dir'); exit"

    # bandpass
    echo "$hemi: 2. bandpass"
    input=$func_dir/${prefix}_bold_space-fsaverage6_residc_interp.$hemi.nii.gz
    output=$func_dir/${prefix}_bold_space-fsaverage6_residc_interp_bp.$hemi.nii.gz
    matlab -nodesktop -nosplash -r "addpath('$preproc_util_dir'); CBIG_bandpass_vol('$input', '$output', '0.009', '0.08', '1', '0', ''); rmpath('$preproc_util_dir'); exit"
  done
done
