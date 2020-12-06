function output=XuGenPCDEnergyResponseWithScatter(input_photon_energy, energy_thresholds,...
    distance_k_fluo_in_one_axis_in_um, electron_spreading_radius_in_um,...
    electronic_noise_in_keV, detector_material_thickness_in_um, detector_pixel_size_in_um)

%output=XuGenPCDEnergyResponseWithScatter(input_photon_energy, energy_thresholds,...
%    distance_k_fluo_in_one_axis_in_um, electron_spreading_radius_in_um,...
%    electronic_noise_in_keV, detector_material_thickness_in_um, detector_pixel_size_in_um)
%Geerate the energy response considering the scatter

%%

if input_photon_energy>50
    %consider scatter only when the energy is larger than 50 keV
    ScatterReabsorption=importdata('ScatterReabsorption.txt');
    CrossSection=importdata('CdTeCrossSection.txt');
    KNCrossSection=importdata('KNCrossSection.txt');
    
    CrossSectionPE=exp(interp1(log(CrossSection(:,1)),log(CrossSection(:,4)),log(input_photon_energy/1000)));
    CrossSectionR=exp(interp1(log(CrossSection(:,1)),log(CrossSection(:,2)),log(input_photon_energy/1000)));
    CrossSectionC=exp(interp1(log(CrossSection(:,1)),log(CrossSection(:,3)),log(input_photon_energy/1000)));
    CrossSectionS=CrossSectionR+CrossSectionC;
    
    FractionPE=(CrossSectionPE)/(CrossSectionPE+CrossSectionS);
    FractionR=CrossSectionR/(CrossSectionPE+CrossSectionS);
    FractionC=CrossSectionC/(CrossSectionPE+CrossSectionS);
    FractionS=FractionR+FractionC;
    
    SigmaTr=interp1(KNCrossSection(:,1),KNCrossSection(:,3),input_photon_energy,'linear');
    SigmaTotal=interp1(KNCrossSection(:,1),KNCrossSection(:,2),input_photon_energy,'linear');
    Ec=input_photon_energy/SigmaTotal*SigmaTr;
    secondary_photon_energy=FractionR/(FractionS)*input_photon_energy+FractionC/(FractionS)*(input_photon_energy-Ec);
    
    Rs=interp1(ScatterReabsorption(:,1),ScatterReabsorption(:,2),input_photon_energy,'linear',0);
    %NEED a funtion in the future to calculate the reabsorption rate
    
    output_PE=XuGenPCDEnergyResponse(input_photon_energy, energy_thresholds,...
        distance_k_fluo_in_one_axis_in_um, electron_spreading_radius_in_um,...
        electronic_noise_in_keV, detector_material_thickness_in_um, detector_pixel_size_in_um);
    
    output_S=XuGenPCDEnergyResponse(secondary_photon_energy, energy_thresholds,...
        distance_k_fluo_in_one_axis_in_um, electron_spreading_radius_in_um,...
        electronic_noise_in_keV, detector_material_thickness_in_um, detector_pixel_size_in_um);
    
    output=output_PE*FractionPE+output_S*FractionS*Rs;
else
    output=XuGenPCDEnergyResponse(input_photon_energy, energy_thresholds,...
        distance_k_fluo_in_one_axis_in_um, electron_spreading_radius_in_um,...
        electronic_noise_in_keV, detector_material_thickness_in_um, detector_pixel_size_in_um);
end