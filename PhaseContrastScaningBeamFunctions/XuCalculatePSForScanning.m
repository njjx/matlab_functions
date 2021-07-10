function [img_I0,img_eps,img_phi]= XuCalculatePSForScanning(foldername,roi_rows,roi_cols)
%This function generate img_I0,img_eps,img_phi from phase stepping data for 
%the non-uniform scanning beam calculation. 

if nargin<2
    roi_rows = 1:767;
    roi_cols = 1:1024;
end

% count number of files (# of phase steps)
files = MgDirRegExp(foldername, 'PS.*raw');
N = numel(files);

rows = 768;
cols = 1024;
img_I0 = zeros(rows, cols, N);
for n = 0:N-1
    filename = sprintf('%s/PS_%d.raw', foldername, n);
    img_I0(:,:,n+1) = MgReadRawFile(filename, rows, cols, 1, 0, 0, 'uint16');
end

val_t = XuMean2(img_I0(roi_rows,roi_cols,:),0);
ratio_t = mean(val_t)./val_t;
img_I0 = img_I0.*ratio_t;

[img_I0,img_I1,img_phi] = XuMulticontrastRetrieval(img_I0);
img_eps = img_I1./img_I0;

end