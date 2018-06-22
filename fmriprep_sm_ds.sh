#!/usr/bin/env bash

# set up directories
subject=1530
project_dir=/data/users/jianxiaow/storage/projects/Fmriprep
preproc_util_dir=$CBIG_CODE_DIR/stable_projects/preprocessing/CBIG_fMRI_Preproc2016/utilities
func_dir=$project_dir/results/sub-$subject/func
intermediate_dir=$project_dir/results/sub-$subject/intermediate

for run in 01 02
do
  echo "Processing subject $subject run $run..."
  prefix=sub-${subject}_task-rest_run-${run}_bold_space-fsaverage6_residc_interp_bp
  if [ ! -e $func_dir/$prefix.L.nii.gz ]; then
    echo "Subject $subject does not have run $run. Skipping..."
    continue
  fi

  for hemi in L R
  do
    hemi_low="`echo "$hemi" | sed 's/.*/\L&/'`h"

    # smoothing
    echo "$hemi: 1. Smoothing"
    input=$func_dir/$prefix.$hemi.nii.gz
    output=$func_dir/${prefix}_sm6.$hemi.nii.gz
    cmd="mri_surf2surf --hemi $hemi_low --s fsaverage6 --sval $input --cortex --fwhm-trg 6 --tval $output --reshape"
    echo $cmd
    eval $cmd

    # fill in medial wall
    echo "$hemi: 2. Fill back in medial wall values"
    matlab -nodesktop -nosplash -r "addpath('$preproc_util_dir'); CBIG_preproc_fsaverage_medialwall_fillin('$hemi_low', 'fsaverage6', '$input', '$output', '$output'); rmpath('$preproc_util_dir'); exit"

    # downsample to fs5
    echo "$hemi: 3. Downsample"
    input=$func_dir/${prefix}_sm6.$hemi.nii.gz
    output=$intermediate_dir/${prefix}_sm6_fs5_tmp.$hemi.nii.gz
    cmd="mri_surf2surf --hemi $hemi_low --srcsubject fsaverage6 --sval $input --nsmooth-in 1 --trgsubject fsaverage5 --tval $output --reshape"
    echo $cmd
    eval $cmd

    # set medial wall to Nan
    echo "$hemi: 4. Set medial wall to Nan"
    input=$intermediate_dir/${prefix}_sm6_fs5_tmp.$hemi.nii.gz
    output=$func_dir/${prefix}_sm6_fs5.$hemi.nii.gz
    matlab -nodesktop -nosplash -r "addpath('$preproc_util_dir'); CBIG_preproc_set_medialwall_NaN('$hemi_low', 'fsaverage5', '$input', '$output'); rmpath('$preproc_util_dir'); exit"

  done
done
