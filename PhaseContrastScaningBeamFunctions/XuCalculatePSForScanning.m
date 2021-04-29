function [img_I0,img_eps,img_phi]= XuCalculatePSForScanning(foldername)
%This function generate img_I0,img_eps,img_phi from phase stepping data for 
%the non-uniform scanning beam calculation. 


% count number of files (# of phase steps)
files = MgDirRegExp(foldername, 'PS.*raw');
N = numel(files);

rows = 767;
cols = 1024;
img_I0 = zeros(rows, cols, N);
for n = 0:N-1
    filename = sprintf('%s/PS_%d.raw', foldername, n);
    img_I0(:,:,n+1) = MgReadRawFile(filename, rows, cols, 1, 2048, 0, 'uint16');
end

[img_I0,img_I1,img_phi] = XuMulticontrastRetrieval(img_I0);
img_eps = img_I1./img_I0;

end