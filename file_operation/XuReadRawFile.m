function data = XuReadRawFile(filename, rows, cols, pages, offset, gap, type)
% data = MgReadRawFile(filename, rows, cols, pages, offset, gap, type)
% This function reads evi file. Arguments:
% filename: the name of the file
% rows: number of rows (image height)
% cols: number of columns (image width), optional, default = rows
% pages: number of pages (image frames), optional, default = 1
% offset: offset to first image (bytes), optional, default = 0
% gap: gap between images (bytes), optional, default = 0
% type: data type, i.e. 'float32', 'uint16', optional, default = 'float32'

[fid, errmsg] = fopen(filename, 'r', 'l');

if fid < 0
    disp(errmsg);
    return
end

if nargin < 7
    type = 'float32';
end
if nargin < 6
    gap = 0;
end
if nargin < 5
    offset = 0;
end
if nargin < 4
    pages = 1;
end
if nargin < 3
    cols = rows;
end

fseek(fid, offset, 'bof');

data = zeros(cols, rows, pages);

ps = MgCmdLineProgressBar('Reading frame #');
for page = 1:pages
    ps.print(page,pages);
    data(:,:,page) = fread(fid, [cols, rows], type);
    fseek(fid, gap, 'cof');
end
data = permute(data, [2, 1, 3]);

fclose(fid);
end

