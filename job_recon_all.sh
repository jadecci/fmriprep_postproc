#!/usr/bin/env bash
#This function script submit jobs to run recon-all for all GSP subjects

##################################################################
#Set up parameters
##################################################################
sub_dir=/data/users/jianxiaow/storage/projects/Fmriprep/reconall
sub_name=`cat /data/users/jianxiaow/storage/projects/Git_codes/data/GSP_subjectnames.csv`

##################################################################
#Make sure subject directory is set up
##################################################################
if [ ! -d "$sub_dir" ]; then
  echo "Subject directory does not exist. Making directory now..."
  mkdir -p $sub_dir
fi

##################################################################
#Submit job to run recon-all
##################################################################
for sub in $sub_name
do
  input=$sub_dir/${sub}_orig.nii
  mri_convert /mnt/yeogrp/data/GSP_release/${sub}_FS/mri/orig/001.mgz $input
  sub_id=${sub#Sub}
  sub_id=${sub_id%_Ses1}
  sub_id=sub-$sub_id

  if [ ! -d $sub_dir/$sub_id ]; then
    cmd="export SUBJECTS_DIR=$sub_dir; recon-all -s $sub_id -i $input -all" #FS6.0 doesn't use -force anymore
    /data/users/jianxiaow/storage/projects/Git_codes/utilities/imgRegProj_pbsubmit.sh $sub_dir recon_all 48 2 15 "$cmd"
  else
    echo "$sub_id recon-all has already been done."
  fi
done





