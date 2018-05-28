% this script creates a file contianing slice timing info based on example
% slice order

% set up timing
tr = 3;
n_slice = 47;
t_1 = round(tr/n_slice, 4);
t_all = 0:t_1:tr;
results = struct('RepetitionTime', 3);

% read slice order
f_so = fullfile(getenv('CBIG_CODE_DIR'), 'stable_projects', 'preprocessing', ...
    'CBIG_fMRI_Preproc2016', 'example_slice_order.txt');
fid = fopen(f_so, 'r');
slice_order = fscanf(fid, '%d');
fclose(fid);

% get slice timing in order
slice_timing = t_all(slice_order);
results.SliceTiming = slice_timing;

% save slice timing
f_st = 'example_slice_timing.json';
fid = fopen(f_st, 'w');
results_json = jsonencode(results);
fprintf(fid, results_json);
fclose(fid);


