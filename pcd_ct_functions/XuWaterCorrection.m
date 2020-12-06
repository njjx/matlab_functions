function sgm_water_c = XuWaterCorrection(sgm)
%sgm_water_c = XuWaterCorrection(sgm)

if exist('water_corr_coef.mat','file')
    load('water_corr_coef.mat');
else
    water_corr_coef=[0.02,1,0];
end
sgm_water_c=polyval(water_corr_coef,sgm(:));