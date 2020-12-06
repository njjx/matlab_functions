function img_3d_corr = MgThorBadPixelCorrNoTranspose(img_3d)
%

pages = size(img_3d, 3);

img_3d_corr = zeros(size(img_3d));

for page = 1:pages
    img_3d_corr(:,:,page) = XuThorBadPixelCorr(img_3d(:,:,page));
end

end

