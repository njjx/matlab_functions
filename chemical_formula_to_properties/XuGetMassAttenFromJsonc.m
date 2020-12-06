function mu_rho=XuGetMassAttenFromJsonc(s_jsonc,energy)
%mu_rho=XuGetMassAttenFromJsonc(s_jsonc,energy)
%energy is in keV
%unit cm^2/g
para_material=XuReadJsonc(s_jsonc);

total_mass=0;
for idx=1:round(length(para_material.ChemicalFomula)/2)
    element_name=char(para_material.ChemicalFomula(2*idx-1));
    element_count=cell2mat(para_material.ChemicalFomula(2*idx));
    z=XuGetZFromName(element_name);
    a=XuGetAFromZ(z);
    total_mass=total_mass+a*element_count;
end

mu_rho=0;
for idx=1:round(length(para_material.ChemicalFomula)/2)
    element_name=char(para_material.ChemicalFomula(2*idx-1));
    element_count=cell2mat(para_material.ChemicalFomula(2*idx));
    z=XuGetZFromName(element_name);
    a=XuGetAFromZ(z);
    mu_rho_temp=XuGetAtten(element_name,1,energy);
    mu_rho=mu_rho+mu_rho_temp*a*element_count/total_mass;
end