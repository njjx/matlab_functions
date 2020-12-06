function effectiveZ=XuGetEffectiveZFromJsonc(s_jsonc)

para_material=XuReadJsonc(s_jsonc);

total_z=0;
for idx=1:round(length(para_material.ChemicalFomula)/2)
    element_name=char(para_material.ChemicalFomula(2*idx-1));
    element_count=cell2mat(para_material.ChemicalFomula(2*idx));
    z=XuGetZFromName(element_name);
    total_z=total_z+z*element_count;
end


temp_sum=0; 
for idx=1:round(length(para_material.ChemicalFomula)/2)
    element_name=char(para_material.ChemicalFomula(2*idx-1));
    element_count=cell2mat(para_material.ChemicalFomula(2*idx));
    z=XuGetZFromName(element_name);
    temp_sum=temp_sum+z*element_count*z^2.94;
end

effectiveZ=(temp_sum/total_z)^(1/2.94);