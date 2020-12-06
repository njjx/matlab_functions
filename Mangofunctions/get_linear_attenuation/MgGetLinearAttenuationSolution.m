function mu = MgGetLinearAttenuationSolution(material, energy, concentration)
%mu = MgGetLinearAttenuationSolution(material, energy, concentration)
% Get the linear attenuation of material [cm^-1].
% material: "CaCl2", or ["I", "Gd"]
% energy: between 1 and 150 keV.
% concentration: same size as material [mg/mL].


mu_water = MgGetLinearAttenuation("water", energy);
mu = mu_water;

for idx = 1:numel(material)
    mu_material = MgGetLinearAttenuation(material(idx), energy);
    density = MgGetMaterialDensity(material(idx));
    mu = mu + (concentration(idx)/1000/density) * mu_material;
end

end

