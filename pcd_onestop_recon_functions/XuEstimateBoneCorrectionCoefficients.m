function [coeff_tb,coeff_bb] = XuEstimateBoneCorrectionCoefficients(en_simu, spec_simu, sgm)
mu_water_mean =XuMeanWaterMu(en_simu,spec_simu);
mu_bone_mean =XuMeanMu('bone',1.92,en_simu,spec_simu);


length_water_max = max(sgm(:))/mu_water_mean*10*1.2;
length_bone_max = max(sgm(:))/mu_bone_mean*10/2;

water_thickness = linspace(0,length_water_max, 20);
bone_thickness = linspace(0,length_bone_max, 20);

[map_water, map_bone] = meshgrid(water_thickness, bone_thickness);

sgm_cali = XuGenPostlogSgmFromWaterAndBoneMap(map_water,map_bone,en_simu,spec_simu);
[sgm_cali_wc, coeff_wc] = XuSimuWaterCorrection(sgm_cali, en_simu, spec_simu,{3,2,1});

map_water_times_mu = map_water*mu_water_mean/10;
map_bone_times_mu = map_bone*mu_bone_mean/10;

%plot(map_bone_times_mu(:,1), sgm_cali(:,1));

coeffs = XuPolyFitForTwoInputs(map_water_times_mu(:),map_bone_times_mu(:),sgm_cali_wc(:),...
    {[1,0], [0,1], [1,1], [0,2]})
coeff_tb = -coeffs(3)/coeffs(1)/coeffs(2);
coeff_bb = -coeffs(4)/coeffs(2)/coeffs(2);

coeff_tb = -coeffs(3);
coeff_bb = -coeffs(4);


