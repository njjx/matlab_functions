function [nps, k] = MgMeasureNpsIec(image, dx)
% [nps, k] = MgMeasureNPS(image, dx)
% Measure Noise Power Spectrum (NPS) from a given image 3d array, using IEC
% method.
% image: image data (3d array: N x N x frames).
% dx: pixel size [unit of length].
% nps: measured nps 2d data.
% k: array of each frequency of 2d nps pixel.

N = size(image, 1);
frames = size(image, 3);

nps = zeros(N, N);

for idx = 1:frames
    [x, y] = meshgrid(1:N);
    x = reshape(x, N*N, 1);
    y = reshape(y, N*N, 1);
    img = reshape(image(:,:,idx), N*N, 1);
    
    sf = fit([x, y],img,'poly22');
    
    noise = img - sf(x, y);
    
    noise = reshape(noise, N, N);
    
%     img_vec = image(:,:,idx);
%     img_vec = reshape(img_vec, 1, N*N);
%     p = polyfit(x, img_vec, 2);
%     img_vec_fit = polyval(p, x);
%     img_fit = reshape(img_vec_fit, N, N);
%     
%     noise = image(:,:,idx) - img_fit;
    
    nps = nps + abs(fft2(noise)).^2;
end

nps = nps / frames;
nps = (dx/N)^2 * nps;

nps = fftshift(nps);

dk = 1/(N*dx);
k = (-N/2):(N/2-1);
k = k * dk;


end