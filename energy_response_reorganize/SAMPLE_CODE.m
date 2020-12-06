clear all
close all
clc


plot(20:120,CdTe_scatter_reabsorp_prob(2000,20:120));
hold on;
plot(30:120,CdTe_fluorescence_reabsorp_prob(2000,30:120,26.7,23.2));
hold off;
xlim([20 120]);


res_para=jsondecodewithcomment('config_energy_response.jsonc');

threshold_energy=eval(res_para.ThresholdEnergy);
k_travel_distance=eval(res_para.KTravelDistance);


output=XuGenPCDEnergyResponseWithScatter(res_para.InputPhotonEnergy,threshold_energy,...
    k_travel_distance,res_para.ChargeSpreadingRadius,...
    res_para.ElectronicsNoise,res_para.ConversionMaterialThickness,...
    res_para.DetectorPixelSize);



plot(threshold_energy,output);
grid on;