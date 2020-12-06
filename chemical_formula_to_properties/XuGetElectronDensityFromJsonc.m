function ratio=XuGetElectronDensityFromJsonc(s_jsonc)
%XuGetElectronDensityFromJsonc(s_jsonc)
%unit cm^(-3)
para_material=XuReadJsonc(s_jsonc);

total_mass=0;
total_z=0;
for idx=1:round(length(para_material.ChemicalFomula)/2)
    element_name=char(para_material.ChemicalFomula(2*idx-1));
    element_count=cell2mat(para_material.ChemicalFomula(2*idx));
    z=XuGetZFromName(element_name);
    a=XuGetAFromZ(z);
    total_mass=total_mass+a*element_count;
    total_z=total_z+z*element_count;
end

ratio=total_z/total_mass*para_material.Density*6.02*10^23;
