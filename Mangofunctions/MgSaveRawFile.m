function MgSaveRawFile(filename, data, offset, gap, type)
% data = MgSaveRawFile(filename, data, offset, gap, type)
% This function save data to evi file. Arguments:
% filename: the name of the file
% data: data to be saved (3d matrix)
% offset: offset to first image (array of bytes or a number)
% gap: gap between images (array of bytes or a number)
% type: data type, i.e. 'float32', 'uint16'

[fid, errmsg] = fopen(filename, 'w');

if fid < 0
    disp(errmsg);
    return
end

% if offset and gap are a number or an array
if numel(offset) == 1
    offset = zeros(1, offset, 'int8');
end
if numel(gap) == 1
    gap = zeros(1, gap, 'int8');
end

fwrite(fid, offset, 'int8');

% write the first page
fwrite(fid, data(:,:,1)', type);
% write the rest page
for page = 2:size(data,3)
    fwrite(fid, gap, 'int8');
    fwrite(fid, data(:,:,page)', type); 
end

fclose(fid);
end

