function output=energy_response_fluo(input_photon_energy, threshold_energy_vector, ...
    K_fluorescence_energy, fluo_distance, electron_radius, electron_noise_in_kev,detector_pixel_size_in_um)
%function output=energy_response_fluo(input_photon_energy_in_kev, threshold_energy_vector_in_keV, ...
%    K_fluorescence_energy_in_keV, fluo_distance_in_um, electron_radius_in_um, electron_noise_in_keV,detector_pixel_size_in_um)

if length(threshold_energy_vector)<2
    error('At least two threshold levels needed!');
end

detector_pixel_size=detector_pixel_size_in_um; %detector pixel size in um
r_e=electron_radius; %electron spreading radius in um
simu_dim=5;%simulation
simu_pixel_size=1;%presampling interval
work_function=4.43e-3;%keV
photon_energy=input_photon_energy;%keV
K_fluo_energy=K_fluorescence_energy;
sigma_e=electron_noise_in_kev/work_function;%counts
x_fluo=fluo_distance;
y_fluo=fluo_distance;
threshold_energy=threshold_energy_vector;

simu_pixel_per_detector_pixel=detector_pixel_size/simu_pixel_size;
simu_dim_in_simu_pixel=simu_dim*simu_pixel_per_detector_pixel;

centeridx=(1+simu_dim_in_simu_pixel)/2;

vector_temp=simu_pixel_size*((1:simu_dim_in_simu_pixel)-centeridx);
[mx my]=meshgrid(vector_temp,vector_temp);%initilize 2D spatial matrix

%calculate the 2d signal before thresholding
%1/4*(erf((x+l/2)/sqrt(2)/r_e)-erf((x-l/2)/sqrt(2)/r_e))...
%*(erf((y+l/2)/sqrt(2)/r_e)-erf((y-l/2)/sqrt(2)/r_e))
g_2d=1/4*(erf((mx+detector_pixel_size/2)/sqrt(2)/r_e)-erf((mx-detector_pixel_size/2)/sqrt(2)/r_e)) ...
    .*(erf((my+detector_pixel_size/2)/sqrt(2)/r_e)-erf((my-detector_pixel_size/2)/sqrt(2)/r_e));

%calculate the 2d signal before thresholding
%1/4*(erf((x+l/2-x_f)/sqrt(2)/r_e)-erf((x-l/2-x_f)/sqrt(2)/r_e))...
%*(erf((y+l/2-y_f)/sqrt(2)/r_e)-erf((y-l/2-y_f)/sqrt(2)/r_e))
g_2d_fluo=1/4*(erf((mx+detector_pixel_size/2-x_fluo)/sqrt(2)/r_e)-erf((mx-detector_pixel_size/2-x_fluo)/sqrt(2)/r_e)) ...
    .*(erf((my+detector_pixel_size/2-y_fluo)/sqrt(2)/r_e)-erf((my-detector_pixel_size/2-y_fluo)/sqrt(2)/r_e));

%3d probability matrix spatial 2d times energy thresholds 1d
probability_density_3d=zeros(simu_dim_in_simu_pixel,simu_dim_in_simu_pixel,length(threshold_energy));

for threshold_idx=1:length(threshold_energy)
    probability_density_3d(:,:,threshold_idx)=1/sqrt(2*pi)/sigma_e/work_function*...
        exp(-((photon_energy-K_fluo_energy)/work_function*g_2d...
        +(K_fluo_energy)/work_function*g_2d_fluo...
        -threshold_energy(threshold_idx)/work_function).^2/2/sigma_e^2);
end

output=squeeze(sum(sum(probability_density_3d,1),2))/simu_pixel_per_detector_pixel/simu_pixel_per_detector_pixel;