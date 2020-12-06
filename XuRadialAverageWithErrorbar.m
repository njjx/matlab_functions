function [data_avg, error, k_avg] = XuRadialAverageWithErrorbar(data2d, dk)
% [data_avg, error,  k_avg] = XuRadialAverageWithErrorbar(data2d, dk)
% For a given 2d data, take the radial average of the data. This is often
% used for NPS or MTF measurement (data2d will be NPS or MTF matrix).
% data2d: input data matrix (N x N).
% dk: pixel size.
% data_avg: output radial average result.
% k: array of corresponding x-axis of data_avg.

theta = (0:359) * pi/180;

N = size(data2d, 1);

if mod(N,2) == 0
    data2d(:,end+1) = data2d(:,1);
    data2d(end+1,:) = data2d(1,:);
else
    N = N - 1;
end

k = (-N/2:N/2) * dk;

[kx, ky] = meshgrid(k);

k_avg = (0:N/2) * dk;
data_avg = zeros(numel(theta), numel(k_avg));

for idx = 1:numel(theta)
    kx_v = k_avg * cos(theta(idx));
    ky_v = k_avg * sin(theta(idx));
    
    data_avg (idx,:) = interp2(kx,ky,data2d, kx_v,ky_v);
end

error=std(data_avg,0,1);
data_avg = mean(data_avg,1);


end

