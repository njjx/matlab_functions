function mu = MgGetLinearAttenuation(material, energy)
% Get the linear attenuation of material [cm^-1].
% material: "water", "CaCl2", "UricAcid"
% energy: between 1 and 150 keV.

tmp = importdata(sprintf("%s",material));

mu = interp1(tmp(:,1)/1000, tmp(:,2), energy);

end

