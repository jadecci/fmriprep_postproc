function add_roi_diff_regressors(confound_file, output_file)
% read in confounds list from fmriprep results and generate list of ROI
% regressors with their derivatives

% load confounds
confounds = tdfread(confound_file);
wb = confounds.GlobalSignal;
wm = confounds.WhiteMatter;
csf = confounds.CSF;

% get derivatives
wb_d = [0; diff(wb)];
wm_d = [0; diff(wm)];
csf_d = [0; diff(csf)];

% collect results and save
all_regressors = [wb wb_d wm wm_d csf csf_d];
dlmwrite(output_file, all_regressors, ' ');

end