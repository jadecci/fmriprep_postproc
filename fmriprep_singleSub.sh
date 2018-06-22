#!/usr/bin/env bash

subject=$1

# set up directories
project_dir=/data/users/jianxiaow/storage/projects/Fmriprep
orig_dir=/mnt/yeogrp/data/GSP_release
func_dir=/mnt/yeogrp/data/GSP2016/CBIG_preproc_global_cen_bp/GSP_single_session/CBIG2016_preproc_global_cen_bp
recon_dir=$project_dir/reconall
data_dir=$HOME/data
output_dir=/tmp/results
work_dir=/tmp/work
export FS_LICENSE=$HOME/license.txt

# prepare data
if [ -d $data_dir/sub-$subject ]; then rm -rf $data_dir/sub-$subject; fi
mkdir -p $data_dir/sub-$subject/anat
mri_convert $orig_dir/Sub${subject}_Ses1_FS/mri/orig/001.mgz $data_dir/sub-$subject/anat/sub-${subject}_T1w.nii.gz
mkdir -p $data_dir/sub-$subject/func
cp $func_dir/Sub${subject}_Ses1/bold/002/Sub${subject}_Ses1_bld002_rest_skip4.nii.gz $data_dir/sub-$subject/func/sub-${subject}_task-rest_run-01_bold.nii.gz
cp $func_dir/Sub${subject}_Ses1/bold/003/Sub${subject}_Ses1_bld003_rest_skip4.nii.gz $data_dir/sub-$subject/func/sub-${subject}_task-rest_run-02_bold.nii.gz

#use existing reconall
mkdir -p $output_dir/freesurfer
cp -r $recon_dir/sub-$subject $output_dir/freesurfer/
chmod -R 755 $output_dir/freesurfer/sub-$subject

# call fmriprep
rm -rf $work_dir/fmriprep_wf/single_subject_${subject}_wf
rm -rf $work_dir/reportlets/fmriprep/sub-${subject}
rm -rf $output_dir/fmriprep/sub-$subject
rm -f $output_dir/fmriprep/sub-$subject.html
cmd="/apps/arch/Linux_x86_64/singularity-2.4.6/bin/singularity run $project_dir/poldracklab_fmriprep_latest-2018-04-16-9433699f2bdc.img $data_dir $output_dir participant --participant-label $subject --output-space T1w fsaverage fsaverage6 --work-dir $work_dir --omp-nthreads 1 --nthreads 1"
echo $cmd
eval $cmd

# get results
if [ -d $project_dir/results/sub-$subject ]; then
  rm -rf $project_dir/results/sub-$subject
  rm $project_dir/results/sub-$subject.html
fi
mv $output_dir/fmriprep/sub-$subject $project_dir/results
mv $output_dir/fmriprep/sub-$subject.html $project_dir/results
rm -rf $output_dir/freesurfer/sub-$subject

# collect some intermediate files for further processing
mkdir -p $project_dir/results/sub-$subject/intermediate
# mc.par
cp $work_dir/fmriprep_wf/single_subject_${subject}_wf/func_preproc_task_rest_run_01_wf/bold_hmc_wf/mcflirt/sub-${subject}_task-rest_run-01_*_mcf.nii.gz.par $project_dir/results/sub-$subject/intermediate
cp $work_dir/fmriprep_wf/single_subject_${subject}_wf/func_preproc_task_rest_run_02_wf/bold_hmc_wf/mcflirt/sub-${subject}_task-rest_run-02_*_mcf.nii.gz.par $project_dir/results/sub-$subject/intermediate

# remove work dir
rm -rf $work_dir/fmriprep_wf/single_subject_${subject}_wf

