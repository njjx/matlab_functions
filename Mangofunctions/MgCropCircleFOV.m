  
function img_crop = MgCropCircleFOV(img_2d, radius, fillValue)
% img_crop = MgCropCircle(img_2d, radius)
% Crop an image to a circular field of view. 
% img_2d: [M x N x slice] 2D image (could have multiple slices) 
% radius: radius of circular FOV, it could be:
%         a decimal number smaller than or equal to 1, i.e. ratio to min(M, N)         
%         or an integer [unit: pixel]
% fillValue: (optional) the value to fill outside FOV, default is zero.


[M, N, S] = size(img_2d);

if nargin < 3
    fillValue = 0;
end


if radius <= 1
    radius = radius * min(M, N) / 2;
end

x = (1:N) - N/2 - 0.5;
y = (1:M) - M/2 - 0.5;

[xx, yy] = meshgrid(x, y);

idx_zero = xx.^2 + yy.^2 > radius^2;
idx_zero = repmat(idx_zero, 1, 1, S);

img_crop = img_2d;
img_crop(idx_zero) = fillValue;


end