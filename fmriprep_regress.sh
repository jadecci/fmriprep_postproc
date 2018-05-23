#!/usr/bin/env bash

subject=0843
project_dir=/data/users/jianxiaow/storage/projects/Fmriprep
func_dir=$project_dir/results/sub-$subject/func

for run in 01 02
do
  confounds=$func_dir/sub-${subject}_test-rest_run-${run}_bold_confounds.tsv
  
done
