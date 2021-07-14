function coefs= XuCalculatePSForScanning_ver2(foldername,roi_rows,roi_cols,order)
% Read phase stepping data to get A0(x,y), A1(x,y), B1(x,y), etc.
% The model is I(k) = A0 + A1*cos(2pi*k/M)+ B1*sin(2pi*k/M)+
% A2*cos(4pi*k/M)+ B2*sin(4pi*k/M) + ...
% coefficients are in the form of complex number like: A0, A1+iB1, A2+iB2
if nargin<2
    roi_rows = 1:768;
    roi_cols = 1:1024;
end

% count number of files (# of phase steps)
files = MgDirRegExp(foldername, 'PS.*raw');
N = numel(files);

rows = 768;
cols = 1024;
phase_step_data = zeros(rows, cols, N);
for n = 0:N-1
    filename = sprintf('%s/PS_%d.raw', foldername, n);
    phase_step_data(:,:,n+1) = MgReadRawFile(filename, rows, cols, 1, 0, 0, 'uint16');
end

phase_step_data(427,370,:) = 1/4*(phase_step_data(426,370,:)...
    +phase_step_data(428,370,:)+...
    phase_step_data(427,371,:)+phase_step_data(427,369,:));

phase_step_data = phase_step_data(roi_rows,roi_cols,:);

% correction of drift
val_t = XuMean2(phase_step_data,0);
ratio_t = mean(val_t)./val_t;
phase_step_data = phase_step_data.*ratio_t;

% calculate coefficients
nsteps=size(phase_step_data,3);
fft_data=fft(phase_step_data,[],3);
coefs = zeros(length(roi_rows),length(roi_cols),order+1);
coefs(:,:,1) = abs(fft_data(:,:,1))/nsteps;
for idx = 1:order
    coefs(:,:,idx+1) = fft_data(:,:,idx+1)*2/nsteps;
end


end