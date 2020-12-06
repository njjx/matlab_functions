function spectrum_out = XuFilterWithPCDEnergyResponse(spectrum_in, energy,energy_thre)
% Distort the spectrum with photon counting detecotr energy response
% function.
% spectrum_in: incident spectrum to the PCD.
% energy: corresponding energy of spectrum_in [keV].

% set enregy for data matrix
en = 1:120;
% set spectrum for data matrix
N0 = interp1(energy(:), spectrum_in(:), en);
N0(isnan(N0)) = 0;

% import energy response data matrix
enRes = importdata('MgEnergyResponseData.txt');

% output spectrum
N = sum(N0 .* enRes, 2);

% justify array length of output spectrum
spectrum_out = interp1(en, N, energy_thre);
spectrum_out = reshape(spectrum_out, size(spectrum_in));


end