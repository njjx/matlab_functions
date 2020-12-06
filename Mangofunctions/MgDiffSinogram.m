function sgmDiff= MgDiffSinogram(sgmData, dx)
% Take the differential of sinogram along detector direction
% sgmData: 3D sinogram data (views x detectorCount x slice)
% dx: detector element size.

cols = size(sgmData, 2);

sgmDiff = zeros(size(sgmData));

for col = 2:cols-1
    sgmDiff(:,col,:) = (sgmData(:,col+1,:) - sgmData(:,col-1,:)) / (2*dx);
end

end

