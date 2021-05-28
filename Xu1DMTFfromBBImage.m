function [mtf_1d,frequency]=Xu1DMTFfromBBImage(img_bb, pixel_size)

roi_size = size(img_bb,1);
zero_padding_ratio=19;
img_bb_zp=zeros(roi_size*zero_padding_ratio,roi_size*zero_padding_ratio);
img_bb_zp(roi_size*((zero_padding_ratio-1)/2)+1:roi_size*(zero_padding_ratio+1)/2,roi_size*(zero_padding_ratio-1)/2+1:roi_size*(zero_padding_ratio+1)/2)=img_bb;

mtf_mean=abs(fft2(img_bb_zp));
mtf_mean=mtf_mean/mtf_mean(1,1);
xi_interval=1/zero_padding_ratio/roi_size/pixel_size;
mtf_mean_shift=circshift(mtf_mean,[roi_size*zero_padding_ratio/2,roi_size*zero_padding_ratio/2]);
mtf_mean_shift(end+1,:)=mtf_mean_shift(1,:);
mtf_mean_shift(:,end+1)=mtf_mean_shift(:,1);

[mtf_1d,frequency] = MgRadialAverage(mtf_mean_shift,xi_interval);