function sgmRebin= MgRebinSinogram(sgmData, rebinSize)
% Rebin the sinogram data along detector direction.
% sgmData: 2D sinogram data.
% rebinSize: rebin size.

rows = size(sgmData, 1);
cols = size(sgmData, 2);

sgmRebin = zeros(rows, floor(cols/rebinSize));

for col = 1:cols/rebinSize
    sgmRebin(:,col) = mean(sgmData(:, col*rebinSize-rebinSize+1:col*rebinSize), 2);
end

end

