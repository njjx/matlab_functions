function image_pick = XuPickFrames(image, ratio)
if nargin ==1
    ratio =1;
end

image_pick=image;
imag_mean = mean(mean(mean(image)));

image_z_ave = squeeze(mean(mean(image,1),2));
z_incorrect = find(image_z_ave<imag_mean*ratio);
image_pick(:,:,z_incorrect)=[];
