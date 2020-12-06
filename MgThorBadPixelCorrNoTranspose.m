function img_3d = MgThorBadPixelCorrNoTranspose(img_3d)
%

pages = size(img_3d, 3);

for page = 1:pages
    img_3d(:,:,page) = XuThorBadPixelCorr(img_3d(:,:,page));
end

end

