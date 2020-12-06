function output=XuGenPCDEnergyResponse(input_photon_energy, energy_thresholds,...
    distance_k_fluo_in_one_axis_in_um, electron_spreading_radius_in_um,...
    electronic_noise_in_keV, detector_material_thickness_in_um, detector_pixel_size_in_um)
%function output=XuGenPCDEnergyResponse(input_photon_energy, energy_thresholds,...
%    distance_k_fluo_in_one_axis_in_um, electron_spreading_radius_in_um,...
%    electronic_noise_in_keV, detector_material_thickness_in_um, detector_pixel_size_in_um)
%Generate energy response function without scatter

%%
detector_material_thickness=detector_material_thickness_in_um;%um
electronic_noise=electronic_noise_in_keV;%keV
detector_pixel_size=detector_pixel_size_in_um;%um
energy_k_edge=[26.7 26.7 31.8 31.8];%K-edge energy in keV
energy_k_fluo=[23.2 26.1 27.2 31.0];%K-fluo energy in keV

prob_k_fluorescence=0.86*0.85;
%K-flluorescence probability for CdTe

prob_k_fluo_paths=[0.84*0.85*0.84/2,0.84*0.85*0.16/2,...
    0.88*0.85*0.83/2,0.88*0.85*0.17/2]/prob_k_fluorescence;
%normalized k-luorescence probability for each path

distance_k_fluo_x=distance_k_fluo_in_one_axis_in_um;

r_e=electron_spreading_radius_in_um;

thre_energy=energy_thresholds;

energy_photon=input_photon_energy;

output_full=energy_response_full_absorp(energy_photon,thre_energy,r_e,electronic_noise,detector_pixel_size);

%judge whether the input photon energy is higher than any of the k-edges
if energy_photon>energy_k_edge(3)%if higher than both kedges
    
    for k_idx=1:length(energy_k_fluo)
        output_escape(:,k_idx)=energy_response_full_absorp(energy_photon-energy_k_fluo(k_idx),thre_energy,r_e,electronic_noise,detector_pixel_size);
        
        output_fluo(:,k_idx)=energy_response_fluo(energy_photon,thre_energy,...
            energy_k_fluo(k_idx),distance_k_fluo_x(k_idx),...
            r_e,electronic_noise,detector_pixel_size);
        
        prob_reabsorb(:,k_idx)=CdTe_fluorescence_reabsorp_prob(detector_material_thickness,...
            energy_photon,energy_k_edge(k_idx),energy_k_fluo(k_idx));
    end
    output=output_full*(1-prob_k_fluorescence);
    for k_idx=1:length(energy_k_fluo)
        output=output...
            +output_escape(:,k_idx)*prob_k_fluorescence*prob_k_fluo_paths(k_idx)*(1-prob_reabsorb(:,k_idx))...
            +output_fluo(:,k_idx)*prob_k_fluorescence*prob_k_fluo_paths(k_idx)*(prob_reabsorb(:,k_idx));
    end
    
elseif energy_photon>energy_k_edge(1)%if only higher than lower k-edge
    for k_idx=1:2
        output_escape(:,k_idx)=energy_response_full_absorp(energy_photon-energy_k_fluo(k_idx),thre_energy,r_e,electronic_noise,detector_pixel_size);
        
        output_fluo(:,k_idx)=energy_response_fluo(energy_photon,thre_energy,...
            energy_k_fluo(k_idx),distance_k_fluo_x(k_idx),...
            r_e,electronic_noise,detector_pixel_size);
        
        prob_reabsorb(:,k_idx)=CdTe_fluorescence_reabsorp_prob(detector_material_thickness,...
            energy_photon,energy_k_edge(k_idx),energy_k_fluo(k_idx));
    end
    
    output=output_full*(1-prob_k_fluorescence);
    for k_idx=1:2
        output=output...
            +output_escape(:,k_idx)*prob_k_fluorescence*prob_k_fluo_paths(k_idx)*(1-prob_reabsorb(:,k_idx))...
            +output_fluo(:,k_idx)*prob_k_fluorescence*prob_k_fluo_paths(k_idx)*(prob_reabsorb(:,k_idx));
    end
else%if smaller than both kedges
    output=output_full;
end
