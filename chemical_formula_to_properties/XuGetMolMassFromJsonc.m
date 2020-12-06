function total_mass=XuGetMolMassFromJsonc(s_jsonc)
%total_mass=XuGetMolMassFromJsonc(s_jsonc)
%Get mol mass
%unit g/mol
para_material=XuReadJsonc(s_jsonc);

total_mass=0;
for idx=1:round(length(para_material.ChemicalFomula)/2)
    element_name=char(para_material.ChemicalFomula(2*idx-1));
    element_count=cell2mat(para_material.ChemicalFomula(2*idx));
    z=XuGetZFromName(element_name);
    a=XuGetAFromZ(z);
    total_mass=total_mass+a*element_count;
end