function [img_I0,img_I1,img_phi ]= XuCalculatePSFromVarianFolder(foldername)
% count number of files (# of phase steps)
files = MgDirRegExp(foldername, 'PS.*raw');
N = numel(files);

% calculate I0
rows = 767;
cols = 1024;
img_ps = zeros(rows, cols, N);
for n = 0:N-1
    filename = sprintf('%s/PS_%d.raw', foldername, n);
    img_ps(:,:,n+1) = MgReadRawFile(filename, rows, cols, 1, 2048, 0, 'uint16');
end
[img_I0,img_I1,img_phi ]=XuMulticontrastRetrieval(img_ps);

end