function coef=XuDecompose(s_material,density,s_material_1,density_1,s_material_2,density_2,energy)
%function coef=XuDecompose(s_material,density,s_material_1,density_1,s_material_2,density_2,energy)
mu_1=XuGetAtten(s_material_1,density_1,energy);
mu_2=XuGetAtten(s_material_2,density_2,energy);
mu=XuGetAtten(s_material,density,energy);
coef=[mu]*[mu_1;mu_2]'*inv([mu_1;mu_2]*[mu_1;mu_2]');