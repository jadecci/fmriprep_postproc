#!/usr/bin/env bash

# usage
if [ $# -ne 2 ]; then
  echo "Usage: $0 start stop"; exit
fi

# set up
start=$1
stop=$2
project_dir=/data/users/jianxiaow/storage/projects/Fmriprep
parc_code_dir=$CBIG_CODE_DIR/stable_projects/brain_parcellation/Yeo2011_fcMRI_clustering
output_dir=$project_dir/results/100sub_clustering
output_prefix=$output_dir/fmriprep_17cluster_scrub
work_dir=$project_dir/results/cluster_job_files

# get new subject list
sublist=$CBIG_CODE_DIR/stable_projects/preprocessing/CBIG_fMRI_Preproc2016/unit_tests/100subjects_clustering/GSP_80_low_motion+20_w_censor.txt
subnames=`head -$stop $sublist | tail -n $(($stop-$start+1))`
tmp_sublist=$project_dir/results/tmp_sublist.txt
echo $subnames > $tmp_sublist

# Create temporary subject directory
tmp_sub_dir=$project_dir/results/tmp_sub_dir
if [ -d $tmp_sub_dir ]; then rm -rf $tmp_sub_dir; fi 
mkdir -p $tmp_sub_dir
for sub in $subnames
do
  subject=${sub%_Ses1}
  subject=${subject#Sub}

  if [ -d $tmp_sub_dir/$sub ]; then rm -rf $tmp_sub_dir/$sub; fi

  for run in 01 02
  do
    # original results directories
    func_dir=$project_dir/results/sub-$subject/func
    regress_dir=$project_dir/results/sub-$subject/regress

    # skip run if non-existent
    echo "Adding subject $subject run $run..."
    prefix=sub-${subject}_task-rest_run-$run
    if [ ! -e $func_dir/${prefix}_bold_space-fsaverage6_residc_interp_bp_sm6_fs5.L.nii.gz ]; then
      echo "Subject $subject does not have run $run. Skipping..."
      continue
    fi

    # copy surface files
    new_prefix=${sub}_bld$run
    mkdir -p $tmp_sub_dir/$sub/surf
    cp $func_dir/${prefix}_bold_space-fsaverage6_residc_interp_bp_sm6_fs5.L.nii.gz $tmp_sub_dir/$sub/surf/lh.${new_prefix}_surf_fs5.nii.gz
    cp $func_dir/${prefix}_bold_space-fsaverage6_residc_interp_bp_sm6_fs5.R.nii.gz $tmp_sub_dir/$sub/surf/rh.${new_prefix}_surf_fs5.nii.gz

    # copy motion outliers file
    mkdir -p $tmp_sub_dir/$sub/qc
    cp $regress_dir/${prefix}_motion_outliers.txt $tmp_sub_dir/$sub/qc/${new_prefix}_motion_outliers.txt

    # add .bold log file
    mkdir -p $tmp_sub_dir/$sub/logs
    bold_log=$tmp_sub_dir/$sub/logs/$sub.bold
    if [ -e $bold_log ]; then 
      run_curr=`cat $bold_log`
      echo "$run_curr $run" > $bold_log
    else 
      echo "$run" > $bold_log
    fi
  done
done

# run clustering
cmd="$parc_code_dir/CBIG_Yeo2011_general_cluster_fcMRI_surf2surf_profiles.csh -sd $tmp_sub_dir -sub_ls $tmp_sublist -surf_stem _surf_fs5 -n 17 -out_dir $output_dir -cluster_out $output_prefix -tries 1000 -outlier_stem _motion_outliers"
/data/users/jianxiaow/storage/projects/Git_codes/utilities/imgRegProj_pbsubmit.sh $work_dir cluster 20 4 5 "$cmd"


