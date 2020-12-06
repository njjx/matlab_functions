function output=energy_response_full_absorp(input_photon_energy, threshold_energy_vector, ...
     electron_radius, electron_noise_in_kev,detector_pixel_size_in_um)
%function output=energy_response_fluo(input_photon_energy_in_keV, threshold_energy_vector_in_keV, ...
%    electron_radius_in_um, electron_noise_in_keV,detector_pixel_size_in_um)

if length(threshold_energy_vector)<2
    error('At least two threshold levels needed!');
end

detector_pixel_size=detector_pixel_size_in_um; %detector pixel size in um
r_e=electron_radius; %electron spreading radius in um
simu_dim=5;%simulation
simu_pixel_size=1;
work_function=4.43e-3;%keV
photon_energy=input_photon_energy;%keV
sigma_e=electron_noise_in_kev/work_function;%counts
threshold_energy=threshold_energy_vector;

simu_pixel_per_detector_pixel=detector_pixel_size/simu_pixel_size;
simu_dim_in_simu_pixel=simu_dim*simu_pixel_per_detector_pixel;

centeridx=(1+simu_dim_in_simu_pixel)/2;

vector_temp=simu_pixel_size*((1:simu_dim_in_simu_pixel)-centeridx);
[mx my]=meshgrid(vector_temp,vector_temp);

g_2d=1/4*(erf((mx+detector_pixel_size/2)/sqrt(2)/r_e)-erf((mx-detector_pixel_size/2)/sqrt(2)/r_e)) ...
    .*(erf((my+detector_pixel_size/2)/sqrt(2)/r_e)-erf((my-detector_pixel_size/2)/sqrt(2)/r_e));

probability_density_3d=zeros(simu_dim_in_simu_pixel,simu_dim_in_simu_pixel,length(threshold_energy));

for threshold_idx=1:length(threshold_energy)
    probability_density_3d(:,:,threshold_idx)=1/sqrt(2*pi)/sigma_e/work_function*...
        exp(-((photon_energy)/work_function*g_2d...
        -threshold_energy(threshold_idx)/work_function).^2/2/sigma_e^2);
end

output=squeeze(sum(sum(probability_density_3d,1),2))/simu_pixel_per_detector_pixel/simu_pixel_per_detector_pixel;