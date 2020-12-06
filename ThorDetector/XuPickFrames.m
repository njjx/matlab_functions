function image_pick = XuPickFrames(image)

image_pick=image;
imag_mean = mean(mean(mean(image)));

image_z_ave = squeeze(mean(mean(image,1),2));
z_incorrect = find(image_z_ave<imag_mean*1.00);
image_pick(:,:,z_incorrect)=[];
