#!/usr/bin/env bash

# set up directories
subject=1530
project_dir=/data/users/jianxiaow/storage/projects/Fmriprep
preproc_util_dir=$CBIG_CODE_DIR/stable_projects/preprocessing/CBIG_fMRI_Preproc2016/utilities
intermediate_dir=$project_dir/results/sub-$subject/intermediate
func_dir=$project_dir/results/sub-$subject/func
regress_dir=$project_dir/results/sub-$subject/regress

# clean up results directory
rm -rf $regress_dir
mkdir -p $regress_dir

# set up list file names
mc_par_list=$intermediate_dir/mc_par_list.txt
mc_regressor_list=$intermediate_dir/mc_regressor_list.txt
fmri_list=$intermediate_dir/fmri_list.txt
output_list=$intermediate_dir/output_list.txt
all_regressors_list=$intermediate_dir/all_regressors_list.txt
censor_list=$intermediate_dir/censor_list.txt

for run in 01 02
do
  echo "Processing subject $subject run $run..."
  prefix=sub-${subject}_task-rest_run-${run}
  if [ ! -e $func_dir/${prefix}_bold_space-fsaverage6.L.func.gii ]; then
    echo "Subject $subject does not have run $run. Skipping..."
    continue
  fi

  # create mc regressor
  echo "1. Create MC regressor"
  echo "$intermediate_dir/${prefix}_bold_valid_mcf.nii.gz.par" > $mc_par_list
  mc_regressor=$intermediate_dir/${prefix}_mc_regressor.txt
  if [ -e $mc_regressor ]; then rm $mc_regressor; fi
  echo "$mc_regressor" > $mc_regressor_list
  matlab -nodesktop -nojvm -nosplash -r "CBIG_preproc_create_mc_regressors('$mc_par_list', '$mc_regressor_list', 'detrend', 1); exit"
  
  # create roi regressors with derivatives
  echo "2. Create ROI regressors with their derivatives"
  confounds=$func_dir/${prefix}_bold_confounds.tsv
  roi_regressor=$intermediate_dir/${prefix}_roi_regressors.txt
  if [ -e $roi_regressor ]; then rm $roi_regressor; fi
  matlab -nodesktop -nojvm -nosplash -r "add_roi_diff_regressors('$confounds', '$roi_regressor'); exit"

  # collect all regressors in one file
  echo "3. Put all regressors in one file"
  all_regressors=$regress_dir/${prefix}_all_regressors.txt
  paste -d " " $intermediate_dir/${prefix}_mc_regressor.txt $roi_regressor > $all_regressors

  # get motion outliers
  echo "4. Find motion outliers"
  dvars_file=$regress_dir/${prefix}_dvars.txt
  fd_file=$regress_dir/${prefix}_fd.txt
  matlab -nodesktop -nojvm -nosplash -r "motion_outliers('$confounds', '$dvars_file', '$fd_file'); exit"
  outliers_file=$regress_dir/${prefix}_motion_outliers.txt
  matlab -nodesktop -nojvm -nosplash -r "CBIG_preproc_motion_outliers('$dvars_file', '$fd_file', '0.5', '50', '5', '$outliers_file'); exit"

  # convert gifti file
  echo "5. Convert gifti input to nifti file"
  nifti_sample=$project_dir/sample.nii.gz
  gifti=$func_dir/${prefix}_bold_space-fsaverage6.L.func.gii
  nifti=$intermediate_dir/${prefix}_bold_space-fsaverage6.L.nii.gz
  matlab -nodesktop -nosplash -r "mri_g = gifti('$gifti'); mri_n = MRIread('$nifti_sample'); mri_n.vol = reshape(mri_g.cdata, [1, 6, 6827, 120]); MRIwrite(mri_n, '$nifti'); exit"
  gifti=$func_dir/${prefix}_bold_space-fsaverage6.R.func.gii
  nifti=$intermediate_dir/${prefix}_bold_space-fsaverage6.R.nii.gz
  matlab -nodesktop -nosplash -r "mri_g = gifti('$gifti'); mri_n = MRIread('$nifti_sample'); mri_n.vol = reshape(mri_g.cdata, [1, 6, 6827, 120]); MRIwrite(mri_n, '$nifti'); exit"

  # apply GLM
  echo "6. Apply GLM"
  if [ -e $fmri_list ]; then rm $fmri_list; fi
  echo "$intermediate_dir/${prefix}_bold_space-fsaverage6.L.nii.gz" >> $fmri_list
  echo "$intermediate_dir/${prefix}_bold_space-fsaverage6.R.nii.gz" >> $fmri_list
  if [ -e $output_list ]; then rm $output_list; fi
  echo "$func_dir/${prefix}_bold_space-fsaverage6_residc.L.nii.gz" >> $output_list
  echo "$func_dir/${prefix}_bold_space-fsaverage6_residc.R.nii.gz" >> $output_list
  if [ -e $all_regressors_list ]; then rm $all_regressors_list; fi
  echo "$all_regressors" >> $all_regressors_list
  echo "$all_regressors" >> $all_regressors_list
  if [ -e $censor_list ]; then rm $censor_list; fi
  echo "$outliers_file" >> $censor_list
  echo "$outliers_file" >> $censor_list
  matlab -nodesktop -nosplash -r "addpath('$preproc_util_dir'); CBIG_glm_regress_vol('$fmri_list', '$output_list', '$all_regressors_list', '1', '$censor_list', '1'); rmpath('$preproc_util_dir'); exit"
done




