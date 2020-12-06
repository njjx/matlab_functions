function HVL = MgCalculateHVL(spectrum, energy, material)
% Calculate Half Value Layer (HVL) for a given spectrum and material.
% spectrum: array of spectrum.
% energy: array of energy [keV].
% material: material name, e.g. "Al", "Cu"; or array of linear attenuation
% coefficients [cm^-1].
% HVL: [mm].

% precision
precision = 0.0001;   % 0.1mm

% mu_en of air
mu_en_air = MgGetEnergyMassAttenuation("air", energy);

% Get linear attenuation of material.
if isstring(material) || ischar(material)
    mu = MgGetLinearAttenuation(material, energy);    
else
    mu = material;
end

% Find the maximum thickness.
t_right = 1;    % [cm]
expo_right = sum( spectrum .* exp(-mu * t_right) .* energy .* mu_en_air );
expo_0 = sum( spectrum .* energy .* mu_en_air );
while expo_right/expo_0 > 1/2
    t_right = 2 * t_right;
    expo_right = sum( spectrum .* exp(-mu * t_right) .* energy .* mu_en_air );
end

% thickness left
expo_left = expo_0;
t_left = 0;

while t_right - t_left > precision
    t = (t_left + t_right) / 2;
    expo = sum( spectrum .* exp(-mu * t) .* energy .* mu_en_air);
    
    if expo/expo_0 > 1/2    % t is smaller than true HVL
        t_left = t;
        expo_left = expo;
    else          % t is greater than true HVL
        t_right = t;
        expo_right = expo;
    end
end

HVL = (t_left + t_right) / 2;   % [cm]
HVL = HVL * 10;         % [mm]

end

