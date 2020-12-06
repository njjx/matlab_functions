function imgCorr= MgRingCorrection(img2d, th_low, th_high, th_diff, median_length, smooth_length)
% imgCorr= MgRingCorrection(img2d, th_low, th_high, th_diff, median_length, smooth_length)
% perform ring artifact correction.
% img2d: 2d image data before ring correction.
% imgCorr: 2d image data after ring correction.
% th_low: threshold low.
% th_high: threshold high.
% th_diff: threshold of difference.
% median_length: length of median filter (radial direction) (interger).
% smooth_length: length of rectangle filter (angular direction) (interger).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert img2d into polar coordinate system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = size(img2d,1);
if N ~= size(img2d, 2)
    fprintf("error: input image is not square!\n");
    return
end

[x,y] = meshgrid((1:N)-N/2-0.5);
[theta, r] = meshgrid((-270:0.5:270)*pi/180,  -0.8*N:0.5:0.8*N);

xv = r .* cos(theta);
yv = r .* sin(theta);

imgPolar = interp2(x,y,img2d, xv,yv);
% remove NAN values
imgPolar(isnan(imgPolar)) = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% remove rings in polar coordinate system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% threshold 
imgPolar = imgPolar .* (imgPolar>th_low) .* (imgPolar<th_high);
% imgPolar(imgPolar<th_low | imgPolar>th_high) = 0;

% smooth image with median filter along radial direction
imgPolarSmooth = medfilt2(imgPolar, [median_length 1]);


imgPolarDiff = imgPolar - imgPolarSmooth;


% set difference threshold
imgPolarDiff = imgPolarDiff .* (abs(imgPolarDiff) < th_diff);

%------------------------------------------------
% smooth along azimuthal (horizontal) direction
smoothKernel = ones(1, smooth_length) / smooth_length;

imgPolarDiff = filter2( smoothKernel, imgPolarDiff, 'same');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert image from polar to Cartisian coordiante system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rv = sqrt(x.^2 + y.^2);
thetav = angle(x + 1i*y);
rv(:,1:N/2) = -rv(:,1:N/2);
thetav(N/2+1:end, 1:N/2) = thetav(N/2+1:end, 1:N/2) - pi;
thetav(1:N/2, 1:N/2) = thetav(1:N/2, 1:N/2) + pi;

imgCartDiff = interp2(theta, r, imgPolarDiff, thetav, rv);

% set NAN zero
imgCartDiff(isnan(imgCartDiff)) = 0;


imgCorr = img2d - imgCartDiff;
end

