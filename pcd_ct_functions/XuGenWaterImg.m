function img_water=XuGenWaterImg(rec_water)
%img=XuGenWaterImg(rec_water)

water_pmma_radius_ratio=401/425.2;

rec_water_effective=(rec_water>0.015);
[center_x, center_y, radius_pmma]=GetCenterRadius(rec_water_effective);
radius_water=radius_pmma*water_pmma_radius_ratio;
[mx my]=meshgrid(1:size(rec_water,2), ...
    1:size(rec_water,1));

%roi of pmma material
roi_pmma=((mx-center_x).^2+(my-center_y).^2<radius_pmma.^2).*...
    ((mx-center_x).^2+(my-center_y).^2>=radius_water.^2);

%roi of water material
roi_water=((mx-center_x).^2+(my-center_y).^2<radius_water.^2);

%roi of water to calculate mu_water (outlayer of water)
roi_water_mu=((mx-center_x).^2+(my-center_y).^2<radius_water.^2).*...
    ((mx-center_x).^2+(my-center_y).^2>=(radius_water*0.95).^2);

%calculate mu of pmma
mu_pmma=XuSum2(roi_pmma.*rec_water)/XuSum2(roi_pmma);

%calculate mu of water
mu_water=XuSum2(roi_water_mu.*rec_water)/XuSum2(roi_water_mu);

img_water=mu_pmma*roi_pmma+mu_water*roi_water;