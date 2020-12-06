function exposure = MgCalculateExposure(spectrum, energy)
% exposure = MgCalculateExposure(spectrum, energy)
% Calculate the exposure for a given sepctrum.
% exposure: [R x cm2/pixel]
% spectrum: 1d array, number of photons per pixel.
% energy: 1d array, corresponding photon energy [keV] of spectrum.

% get energy mass attenuation of air
mu_en_air = MgGetEnergyMassAttenuation("air", energy);

% calculate exposure [keV/g x cm2/pixel]
exposure = sum( spectrum .* energy .* mu_en_air );

% change the unit
% [C/kg x cm2/pixel]
exposure = exposure * 1.6e-13 / 33.97;
% [R x cm2/pixel]
exposure = exposure * 3876;

end

