function [nps_2d, k, nps_seq] = MgMeasureNps(image, dx)
% [nps, k] = MgMeasureNPS(image, dx)
% Measure Noise Power Spectrum (NPS) from a given image 3d array.
% image: image data (3d array: N x N x frames).
% dx: pixel size [unit of length].
% nps: measured nps 2d data.
% k: array of each frequency of 2d nps pixel.

N = size(image, 1);
frames = size(image, 3);

nps_2d = zeros(N, N);

image_mean = mean(image, 3);

for idx = 1:frames
    nps_2d = nps_2d + abs( fft2(image(:,:,idx) - image_mean) ) .^2;
end

nps_2d = nps_2d / frames;
nps_2d = (dx/N)^2 * nps_2d;

nps_2d = fftshift(nps_2d);

dk = 1/(N*dx);
k = (-N/2):(N/2-1);
k = k * dk;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nps_seq = zeros(N,N, frames);

for idx = 1:frames
    nps_seq(:,:,idx) = abs( fft2(image(:,:,idx) - image_mean) ) .^2;
end


end

