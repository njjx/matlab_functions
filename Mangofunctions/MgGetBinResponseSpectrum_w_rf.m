function bin_spectrum = MgGetBinResponseSpectrum_w_rf(spectrum, energy, threshold_low, threshold_high,s)
% get bin spectrum from a specific energy response matrix
% bin_spectrum = MgGetBinResponseSpectrum(spectrum, energy, threshold_low, threshold_high,s)
% For a given spectrum, return detected spectrum with detector energy response.
% spectrum: array of photon counts.
% energy: [keV].
% threshold_low: low threshold [keV] (included).
% threshold_high: high threshold [keV] (not included).
% bin_spectrum: respond spectrum in energy bin [threshold_low,threshold_high)
% s: name of txt file saving the response matrix 
enRes = importdata(s);

size_enRes = round(sqrt(length(enRes(:))));

enRes = reshape(enRes,[size_enRes size_enRes]);

en = interp1(energy, spectrum, 1:size_enRes);
en(isnan(en)) = 0;

bin = sum(enRes(threshold_low:threshold_high,:), 1);
bin = interp1(1:120, bin, energy);

bin_spectrum = spectrum .* bin;

end
