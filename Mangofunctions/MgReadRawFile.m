function data = MgReadRawFile(filename, rows, cols, pages, offset, gap, type)
% data = MgReadRawFile(filename, rows, cols, pages, offset, gap, type)
% This function reads evi file. Arguments:
% filename: the name of the file
% rows: number of rows (image height)
% cols: number of columns (image width)
% pages: number of pages (image frames)
% offset: offset to first image (bytes)
% gap: gap between images (bytes)
% type: data type, i.e. 'float32', 'uint16'

[fid, errmsg] = fopen(filename, 'r', 'l');

if fid < 0
    disp(errmsg);
    return
end

fseek(fid, offset, 'bof');

data = zeros(cols, rows, pages);
for page = 1:pages
    data(:,:,page) = fread(fid, [cols, rows], type);
    fseek(fid, gap, 'cof');
end
data = permute(data, [2, 1, 3]);

fclose(fid);
end

