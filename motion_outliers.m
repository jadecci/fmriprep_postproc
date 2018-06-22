function motion_outliers(confound_file, output_dvars, output_fd)

% load confounds
confounds = tdfread(confound_file);
dvars_char = confounds.non0x2DstdDVARS;
fd_char = confounds.FramewiseDisplacement;

% convert to double
dvars = zeros(120, 1);
fd = zeros(120, 1);
for i = 2:120
    dvars(i) = str2double(dvars_char(i, :));
    fd(i) = str2double(fd_char(i, :));
end

% save to intermediate file
dlmwrite(output_dvars, dvars);
dlmwrite(output_fd, fd);

end
