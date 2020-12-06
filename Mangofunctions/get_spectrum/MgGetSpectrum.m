function N = MgGetSpectrum(kVp, energy, filter_material, thickness)
% function N = MgGetSpectrum(kVp, energy)
% Get the spectrum for a certain kVp. Intrinsical Al 3mm and air 1m is applied.
% kVp: kVp, from 40 to 140 kVp, 5 keV interval.
% energy: array of energy (keV).
% N: output spectrum (same size as energy);
% thickness: mm

if nargin ==2
    filter_material = 'al';
    thickness =0;
end

filename = sprintf("spectrum_air_%d.txt", kVp);

if ~exist(filename, 'file')
    error("%d kVp is not available!\n", kVp);
    return
end

data = importdata(filename);
N = interp1(data(:,1), data(:,2), energy);

switch (filter_material)
    case 'al'
        mu = XuGetAtten('al',2.7,energy)/10;
    case 'cu'
        mu = XuGetAtten('cu',8.96,energy)/10;
    case 'copper'
        mu = XuGetAtten('cu',8.96,energy)/10;
    otherwise
        error('filter material can only be cu or al!');
end

N = N.*exp(-mu*thickness);

end