function [sgm_water, sgm_bone, coeff_water ,coeff_bone ]= XuSimuMaterialDecomp(sgm_le, sgm_he, en_simu, spec_le, spec_he, order_cell)

spec_le = spec_le/mean(spec_le);
spec_he = spec_he/mean(spec_he);

mu_water = XuGetAtten('water',1,en_simu);
mu_water_mean = mean(spec_le.*mu_water);
length_water_max = max(sgm_le(:))/(mu_water_mean/10)*1.5;% in mm

mu_bone = XuGetAtten('bone',1.92,en_simu);
mu_bone_mean = mean(spec_le.*mu_bone);
length_bone_max = max(sgm_le(:))/(mu_bone_mean/10);% in mm

water_thickness = linspace(0,length_water_max, 20);
bone_thickness = linspace(0,length_bone_max, 20);

[map_water, map_bone] = meshgrid(water_thickness, bone_thickness);

sgm_cali_le = XuGenPostlogSgmFromWaterAndBoneMap(map_water,map_bone,en_simu,spec_le);
sgm_cali_he = XuGenPostlogSgmFromWaterAndBoneMap(map_water,map_bone,en_simu,spec_he);


coeff_water = XuPolyFitForTwoInputs(sgm_cali_le(:), sgm_cali_he(:), map_water(:),order_cell);
coeff_bone = XuPolyFitForTwoInputs(sgm_cali_le(:), sgm_cali_he(:), map_bone(:),order_cell);

sgm_water = XuPolyValForTwoInputs(coeff_water,sgm_le(:), sgm_he(:),order_cell);
sgm_water = reshape(sgm_water,size(sgm_le));


sgm_bone = XuPolyValForTwoInputs(coeff_bone,sgm_le(:), sgm_he(:),order_cell);
sgm_bone = reshape(sgm_bone,size(sgm_le));