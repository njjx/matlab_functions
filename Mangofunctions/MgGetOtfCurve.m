function [otf, k] = MgGetOtfCurve(psf1d_half,dx)
% Plot Optical Transform Function (OTF) for a given psf in polar corrdinate system.
% psf1d_half: 1D psf, only the right half side.
% dx: pixel size.

% get otf curve
N = numel(psf1d_half);
x = -(N-1):(N-1);

[xx, yy] = meshgrid(x);
r = sqrt(xx.^2 + yy.^2);
psf2d = interp1(0:N-1, psf1d_half, r);
psf2d(isnan(psf2d)) = psf1d_half(end);

otf2d = psf2otf(psf2d);
otf = otf2d(1,:);

% get array of k
N = numel(otf);
dk = 1/(dx*N);
k = (0:N-1)*dk;

end

