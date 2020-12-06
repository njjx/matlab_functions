function [sgm_output,coeff_water ]= XuSimuWaterCorrection(sgm_input, en_simu, spec_simu, order_cell)

spec_simu = spec_simu/mean(spec_simu);

mu_water = XuGetAtten('water',1,en_simu);
mu_water_mean = mean(spec_simu.*mu_water);

length_water_max = max(sgm_input(:))/(mu_water_mean/10)*1.5;% in mm
water_thickness = linspace(0,length_water_max, 20);
bone_thickness = linspace(0,0, 20);

sgm_cali = XuGenPostlogSgmFromWaterAndBoneMap(water_thickness,bone_thickness,en_simu,spec_simu);
coeff_water = XuPolyFitForOneInput(sgm_cali(:),water_thickness(:)*(mu_water_mean/10), order_cell);

sgm_output = XuPolyValForOneInput(coeff_water,sgm_input(:),order_cell);
sgm_output = reshape(sgm_output,size(sgm_input));
