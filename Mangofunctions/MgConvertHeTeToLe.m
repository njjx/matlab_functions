function MgConvertHeTeToLe(filenameTe, filenameHe, filenameLe, rows, cols, pages, offset, gap, type)
% MgConvertHeTeToLe(filenameTe, filenameHe)
% This function convert TE and HE file to LE file (LE = TE - HE).
% TE: Total Energy.
% HE: High Energy. 
% LE: Low Energy.
% rows: number of rows (image height)
% cols: number of columns (image width)
% pages: number of pages (image frames)
% offset: offset to first image (bytes)
% gap: gap between images (bytes)
% type: data type, i.e. 'float32', 'uint16'

fprintf("processing ...   ");

% open the TE file and get head info
fid_Te = fopen(filenameTe, 'r', 'l');
headInfo = fread(fid_Te, offset, 'int8');

% open the HE file and skip offset
fid_He = fopen(filenameHe, 'r', 'l');
fseek(fid_He, offset, 'bof');

% open the LE file and write head info
fid_Le = fopen(filenameLe, 'w');
fwrite(fid_Le, headInfo);

gapArray = zeros(1, gap, 'int8');

% read, calculate and write data
for page = 1:pages-1
    dataTe = fread(fid_Te, rows*cols, type);
    fseek(fid_Te, gap, 'cof');
    dataHe = fread(fid_He, rows*cols, type);
    fseek(fid_He, gap, 'cof');
    
    % save to file
    fwrite(fid_Le, dataTe - dataHe, type);
    fwrite(fid_Le, gapArray, 'int8');
    
    fprintf("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\bProcessing %5.1f%%", page/pages*100);
    
end
dataTe = fread(fid_Te, rows*cols, type);
dataHe = fread(fid_He, rows*cols, type);
fwrite(fid_Le, dataTe - dataHe, type);

fprintf("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\bProcessing 100.0%%           \n");

% close files
fclose(fid_Te);
fclose(fid_He);
fclose(fid_Le);

end

