function air_kerma = XuCalculateAirKerma(spectrum, energy)
% air_kerma = XuCalculateAirKerma(spectrum, energy)
% Calculate the air kerma for a given sepctrum.
% air_kerma: Gy
% spectrum: 1d array, number of photons per cm^2.
% energy: 1d array, corresponding photon energy [keV] of spectrum.

%equation: air_kerma = energ_flux x mu_en

% get energy mass attenuation of air
mu_en_air = XuGetAttenEn('air',1, energy);

air_kerma_in_keV_g=sum( spectrum .* energy .* mu_en_air );
air_kerma_in_J_g=air_kerma_in_keV_g*1.6e-16;
air_kerma_in_J_kg=air_kerma_in_J_g*1e3;

air_kerma=air_kerma_in_J_kg;

end

