#!/usr/bin/env bash

# set up directories
subject=0843
project_dir=/data/users/jianxiaow/storage/projects/Fmriprep
#preproc_dir=$CBIG_CODE_DIR/stable_projects/preprocessing/CBIG_fMRI_Preproc2016
intermediate_dir=$project_dir/results/sub-$subject/intermediate
func_dir=$project_dir/results/sub-$subject/func
regress_dir=$project_dir/results/sub-$subject/regress
mkdir -p $regress_dir

# set up intermediate files
mc_par_list=$intermediate_dir/mc_par_list.txt
mc_regressor_list=$intermediate_dir/mc_regressor_list.txt

for run in 01 02
do
  prefix=sub-${subject}_task-rest_run-${run}

  # create mc regressor
  echo "$intermediate_dir/${prefix}_bold_valid_mcf.nii.gz.par" > $mc_par_list
  echo "$intermediate_dir/${prefix}_mc_regressor.txt" > $mc_regressor_list
  matlab -nodesktop -nojvm -nosplash -r "CBIG_preproc_create_mc_regressors('$mc_par_list', '$mc_regressor_list', 'detrend', 1); exit"
  
  # create roi regressors with derivatives
  confounds=$func_dir/${prefix}_bold_confounds.tsv
  roi_regressor=$intermediate_dir/${prefix}_roi_regressors.txt
  matlab -nodesktop -nojvm -nosplash -r"add_roi_diff_regressors('$confounds', '$roi_regressor'); exit"

  # collect all regressors in one file
  all_regressors=$regress_dir/${prefix}_all_regressors.txt
  paste -d " " $intermediate_dir/${prefix}_mc_regressor.txt $roi_regressor > $all_regressors
done

# apply GLM

