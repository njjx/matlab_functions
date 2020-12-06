function image_pick = XuPickFramesRadiog(image)

image_pick=image;

image_z_ave = squeeze(mean(mean(image,1),2));
z_incorrect = find(image_z_ave<50);
image_pick(:,:,z_incorrect)=[];