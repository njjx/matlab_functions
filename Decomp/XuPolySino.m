function sinogram=XuPolySino(sgm_material_1,sgm_material_2,s_material_1,s_material_2,density_1,density_2,spec,energy)
%sinogram=XuPolySino(sgm_material_1,sgm_material_2,...
%    s_material_1,s_material_2,density_1,density_2,spec,energy)
spec=spec/sum(spec);
sinogram=zeros(size(sgm_material_1));
mu_material_1=XuGetAtten(s_material_1,density_1,energy);
mu_material_2=XuGetAtten(s_material_2,density_2,energy);
for energy_idx=1:length(energy)
    sinogram=sinogram+spec(energy_idx)*exp(-mu_material_2(energy_idx)*sgm_material_2...
        -mu_material_1(energy_idx)*sgm_material_1);
end
sinogram=-log(sinogram);