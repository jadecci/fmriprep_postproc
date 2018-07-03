#!/usr/bin/env bash

# set up directories
subject=$1
project_dir=/data/users/jianxiaow/storage/projects/Fmriprep
preproc_util_dir=$CBIG_CODE_DIR/stable_projects/preprocessing/CBIG_fMRI_Preproc2016/utilities
func_dir=$project_dir/results/sub-$subject/func
intermediate_dir=$project_dir/results/sub-$subject/intermediate
regress_dir=$project_dir/results/sub-$subject/regress
qc_dir=$project_dir/results/sub-$subject/qc
mkdir -p $qc_dir
matlab_dir=/apps/arch/Linux_x86_64/matlab/R2014a/bin

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

    # censoring QC
    echo "$hemi: 1. Censoring QC"
    censor_qc_dir=$qc_dir/censor_interp_$hemi
    mkdir -p $censor_qc_dir
    sub=Sub$subject
    input_before=$func_dir/${prefix}_bold_space-fsaverage6_residc.$hemi.nii.gz
    input_interim=$intermediate_dir/${prefix}_interp_inter.$hemi.nii.gz
    input_final=$func_dir/${prefix}_bold_space-fsaverage6_residc_interp.$hemi.nii.gz
    fake_mask=$project_dir/sample_mask.$hemi.nii.gz
    outliers_file=$regress_dir/${prefix}_motion_outliers.txt
    $matlab_dir/matlab -nodesktop -nosplash -r "addpath('$preproc_util_dir'); CBIG_preproc_CensorQC('$censor_qc_dir', '$sub', '$run', '$input_before', '$input_interim', '$input_final', '$fake_mask', '$fake_mask','$outliers_file'); rmpath('$preproc_util_dir'); exit"

    # greyplot
    echo "$hemi: 2. Greyplot"
    input=$func_dir/${prefix}_bold_space-fsaverage6_residc_interp_bp.$hemi.nii.gz
#    input=$project_dir/temp_sub-${subject}.$hemi.nii.gz
    dvars_file=$regress_dir/${prefix}_dvars.txt
    fd_file=$regress_dir/${prefix}_fd.txt
    output=$qc_dir/${prefix}_greyplot.$hemi.png
    $matlab_dir/matlab -nodesktop -nosplash -r "addpath('$preproc_util_dir'); CBIG_preproc_QC_greyplot('$input', '$fd_file', '$dvars_file', '$output', 'GM_mask', '$fake_mask', 'WB_mask', '$fake_mask', 'grey_vox_factor', '200', 'tp_factor', '0.3', 'FD_thres', '0.4', 'DV_thres', '50'); rmpath('$preproc_util_dir'); exit"

    # FD-DVARS correlation
    echo "$hemi: 3. FD-DVARS Correlation"
    dvars_file=$regress_dir/${prefix}_dvars.txt
    fd_file=$regress_dir/${prefix}_fd.txt
    output_prefix=$qc_dir/${prefix}_$hemi
    $matlab_dir/matlab -nodesktop -nosplash -r "addpath('$preproc_util_dir'); CBIG_preproc_DVARS_FDRMS_Correlation('$dvars_file', '$fd_file', '$output_prefix'); rmpath('$preproc_util_dir'); exit"

    # FC
    #echo "$hemi: 4. FC"
  done
done
