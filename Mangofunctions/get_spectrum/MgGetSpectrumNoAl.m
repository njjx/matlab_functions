function N = MgGetSpectrumNoAl(kVp, energy)
% function N = MgGetSpectrum(kVp, energy)
% Get the spectrum for a certain kVp. Only intrinsical air 1m is applied.
% kVp: kVp, only support 80 now.
% energy: array of energy (keV).
% N: output spectrum (same size as energy);

filename = sprintf("spectrum_no_Al_%d.txt", kVp);

if ~exist(filename, 'file')
	error("%d kVp is not available!\n", kVp);
    return
end

data = importdata(filename);
N = interp1(data(:,1), data(:,2), energy,'linear',0);

end