function bin_spectrum = MgGetBinResponseSpectrum(spectrum, energy, threshold_low, threshold_high)
% bin_spectrum = MgGetBinResponseSpectrum(spectrum, energy, threshold_low, threshold_high)
% For a given spectrum, return detected spectrum with detector energy response.
% spectrum: array of photon counts.
% energy: [keV].
% threshold_low: low threshold [keV] (included).
% threshold_high: high threshold [keV] (not included).
% bin_spectrum: respond spectrum in energy bin [threshold_low,threshold_high)

enRes = importdata('MgEnergyResponseData.txt');

en = interp1(energy, spectrum, 1:120);
en(isnan(en)) = 0;

bin = sum(enRes(threshold_low:threshold_high,:), 1);
bin = interp1(1:120, bin, energy);

bin_spectrum = spectrum .* bin;

end
