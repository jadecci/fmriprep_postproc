% load volume and labels
project_dir = '/data/users/jianxiaow/storage/projects/Fmriprep';
mri = MRIread([project_dir '/sample.nii.gz']);
lh_avg_mesh6 = CBIG_ReadNCAvgMesh('lh', 'fsaverage6', 'white', 'cortex');
rh_avg_mesh6 = CBIG_ReadNCAvgMesh('rh', 'fsaverage6', 'white', 'cortex');

% write outputs
mri.vol = reshape(double(lh_avg_mesh6.MARS_label==2), [1 6 6827]);
MRIwrite(mri, [project_dir '/sample_mask.L.nii.gz']);
mri.vol = reshape(double(rh_avg_mesh6.MARS_label==2), [1 6 6827]);
MRIwrite(mri, [project_dir '/sample_mask.R.nii.gz']);


