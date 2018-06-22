function CBIG_preproc_motion_outliers(DVARS_file,FDRMS_file,FD_th,DV_th,discard_seg,output_name)

% CBIG_preproc_motion_outliers(DVARS_file,FDRMS_file,FD_th,DV_th,discard_seg,output_name)
%
% This function is used to find the outliers with DVARS threshold DV_th and
% FDRMS threshold FD_th. After threholding, one frame before two frame after
% will also be removed. The default DV_th is 50, default FD_th is 0.2
% INPUT:                                                                   
% 	- DVARS_file:
%       a file contains DVARS values as a TX1 column, T is the number of
%       frames (include the first frame, whose value supposed to be 0) 
%
%	- FDRMS_file:
%       a file contains FDRMS values as a TX1 column, T is the number of
%       frames (include the first frame, whose value supposed to be 0) 
%
% 	- FD_th: 
%       the threshold of FDRMS, default is 0.2
%
% 	- DV_th: 
%       the threshold of DVARS, default is 50
%
%   - discard_seg: 
%       uncensored segments of data lasting fewer than discard_seg
%       contiguous frames will be removed, default is 5. 
%
%   - output_name:
%       output file name (full path).
%
% OUTPUT:                                                                  
% 	txt file: this file contains a Tx1 vector where 1 means kept, 0 means removed.
%
% Written by CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md



%% Read in file and construct DVARS. FDRMS vectors
fd = dlmread(FDRMS_file);
dvars = dlmread(DVARS_file);

%% Detect outliers with DVARS threhold
DV_th = str2num(DV_th);
DV_vect = (dvars <= DV_th); % 1 means the frame below the threshold is kept, 0 means the frame above the threshold is removed

%% Detect outliers with FDRMS threhold
FD_th = str2num(FD_th);
FD_vect = (fd <= FD_th); % 1 means the frame below the threshold is kept, 0 means the frame above the threshold is removed

%% Continue removing one frame before and two frames after
DV_censor = (DV_vect & [DV_vect(2:end,1); 1] & [1; DV_vect(1:end-1)] & [1;1; DV_vect(1:end-2)]);
FD_censor = (FD_vect & [FD_vect(2:end,1); 1] & [1; FD_vect(1:end-1)] & [1;1; FD_vect(1:end-2)]);

%% Combine DVARS and FDRMS so that a frame is either above FD_th or DV_th, it will be removed
DV_FD_censor = [DV_censor & FD_censor];

%% remove uncensored segments of data lasting fewer than discard_seg contiguous frames
discard_seg = str2num(discard_seg);
DV_FD_censor_segment = diff([0; DV_FD_censor; 0]);
seg_start = find(DV_FD_censor_segment == 1);
seg_end = find(DV_FD_censor_segment == -1)-1;

for idx = 1:length(seg_start)
    if(seg_end(idx)-seg_start(idx) + 1 < discard_seg)
        DV_FD_censor(seg_start(idx):seg_end(idx)) = 0;
    end
end

%% Save out the outlier vector into a text file
outfilename_index = fopen(output_name, 'w+');
fprintf(outfilename_index, '%d\n', DV_FD_censor);

