function [thLow, thHigh] = MgReadEviThresholds(filename)
% [thLow, thHigh] = MgReadEviThresholds(filename)
% This function reads evi file thresholds (low and high).
% filename: the name of the file
% thLow: low threshold.
% thHigh: high threshold.

[fid, errmsg] = fopen(filename, 'r', 'l');

if fid < 0
    disp(errmsg);
    return
end

% skip first 26 lines
% totalLines = 71;
for k = 1:26
    tline = fgetl(fid);
	% fprintf("line %2d\t", k);
    % fprintf("\t%s\n", tline);
end

% read line of low and high thresholds
thLows = fscanf(fid, "Low_Thresholds [ %f %f %f %f %f %f %f %f %f %f %f %f ]\n");
thHighs = fscanf(fid, "High_Thresholds [ %f %f %f %f %f %f %f %f %f %f %f %f ]\n");

% only return the first value
thLow = thLows(1);
thHigh = thHighs(1);

fclose(fid);
end

