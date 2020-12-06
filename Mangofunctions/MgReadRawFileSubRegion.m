function data = MgReadRawFileSubRegion(filename, rows, cols, pages, offset, gap, type, subregion, gain_correction)
% This function reads a raw file, and only get a specified sub-region data.
% filename: the name of the file.
% rows: number of rows (image height).
% cols: number of columns (image width).
% pages: number of pages (image frames).
% offset: offset to first image (bytes).
% gap: gap between images (bytes).
% type: data type, i.e. 'float32', 'uint16'.
% subregion: sub-region of data, 3x2 matrix, each row represents start and
% end index.
% gain_correction: bool type, perform gain correction or not.

% open the file
[fid, errmsg] = fopen(filename, 'r', 'l');
if fid < 0
    disp(errmsg);
    return
end

% skip the offset
fseek(fid, offset, 'bof');

% skip the first specified number of frames
typeBytes = MgGetTypeBytes(type);
fseek(fid, (rows*cols*typeBytes+gap)*(subregion(3,1)-1), 'cof');


% read the data
row1 = subregion(1,1);
row2 = subregion(1,2);
col1 = subregion(2,1);
col2 = subregion(2,2);
page1= subregion(3,1);
page2= subregion(3,2);

data = zeros( row2-row1+1, col2-col1+1, page2-page1+1 );

for page = 1:(page2-page1+1)
    tmp = fread(fid, [cols, rows], type);
    fseek(fid, gap, 'cof');
    
    data(:,:,page) = tmp(col1:col2, row1:row2)';
end

fclose(fid);

% perform gain correction
if gain_correction
    corr_factor = mean(data(:)) ./ (mean(data,3));
    data = data .* corr_factor;    
end

end
