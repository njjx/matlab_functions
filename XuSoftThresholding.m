function img_threshold = XuSoftThresholding(img, th_l,th_h, lower_or_upper)
% lower_or_upper<0 means lower portion
% lower_or_upper>0 means higher portion


lower = img<th_l;
upper = img>=th_h;

transitional = (img>=th_l).*(img<th_h);
if lower_or_upper>0
    transitional = transitional.*[(img-th_l)/(th_h-th_l)];
    img_threshold = upper + transitional;
else
    transitional = transitional.*[(th_h-img)/(th_h-th_l)];
    img_threshold = lower + transitional;
end