function [threshold_energy,output] = XuGenPCDERFVer1(s_config)

res_para=XuReadJsonc(s_config);

threshold_energy=eval(res_para.ThresholdEnergy);
k_travel_distance=eval(res_para.KTravelDistance);


output=XuGenPCDEnergyResponseWithScatter(res_para.InputPhotonEnergy,threshold_energy,...
    k_travel_distance,res_para.ChargeSpreadingRadius,...
    res_para.ElectronicsNoise,res_para.ConversionMaterialThickness,...
    res_para.DetectorPixelSize);


% 
% plot(threshold_energy,output);
% grid on;