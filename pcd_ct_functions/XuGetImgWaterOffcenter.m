function img_water = XuGetImgWaterOffcenter(rec_water, s_config)
%img_water = XuGetImgWaterOffcenter(rec_water, s_config)

recon_para = XuReadJsonc(s_config);

field_of_view_in_pixel = XuGetFieldOfView(s_config); 


[mx,my] = meshgrid(1:recon_para.ImageDimension,1:recon_para.ImageDimension);
center_idx = (1+recon_para.ImageDimension)/2;
image_effective = ((mx-center_idx).^2+(my-center_idx).^2<(field_of_view_in_pixel*0.90)^2);


rec_water_diff = diff(rec_water,1,1);
rec_water_diff(end+1,:)=0;
rec_water_diff = circshift(rec_water_diff,[1,0]);

rec_water_diff_effective = image_effective.*rec_water_diff;

[val,idx] = max(rec_water_diff_effective,[],1);

x_idx_effective  =find(val>0.01);%determine the effective idx
y_idx_effective = idx(x_idx_effective);

[x_c,y_c,radius] = XuGetCircFromPoints(x_idx_effective,y_idx_effective);
y_c = y_c-0.5;%shift the y_idx up by half of a pixel

water_ratio = 401/425;

mu_pmma_effective_area = ((mx-x_c).^2+(my-y_c).^2<(radius)^2)-...
    ((mx-x_c).^2+(my-y_c).^2<(radius*water_ratio)^2);

mu_water_effective_area = ((mx-x_c).^2+(my-y_c).^2<(radius*water_ratio)^2)-...
    ((mx-x_c).^2+(my-y_c).^2<(radius*water_ratio^2)^2);

mu_pmma_effective_area_crop=mu_pmma_effective_area.*image_effective;
mu_water_effective_area_crop=mu_water_effective_area.*image_effective;

mu_pmma = XuSum2(mu_pmma_effective_area_crop.*rec_water)/XuSum2(mu_pmma_effective_area_crop);
mu_water = XuSum2(mu_water_effective_area_crop.*rec_water)/XuSum2(mu_water_effective_area_crop);

img_water = mu_pmma_effective_area*mu_pmma...
    +((mx-x_c).^2+(my-y_c).^2<(radius*water_ratio)^2)*mu_water;
