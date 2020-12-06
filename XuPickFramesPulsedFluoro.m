function image_pick = XuPickFramesPulsedFluoro(image, ratio)
if nargin ==1
    ratio =0.9;
end

image_pick=image;
image_max = max(XuMean2(image));

image_z_ave = squeeze(mean(mean(image,1),2));
z_incorrect = find(image_z_ave<image_max*ratio);
image_pick(:,:,z_incorrect)=[];
