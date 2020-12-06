function delta=XuGetAtten(s,energy)
%delta=XuGetAtten(s,energy)
%s is the string of the atten file
%enegy is in keV



data=importdata([s,'_delta.txt']);
energy_eV=energy*1000;
if min(energy_eV)<min(data(:,1)) || max(energy_eV)>max(data(:,1))
    error('Energy out of range!');
end
data_log=log(data);
energy_log=log(energy_eV);
delta_log=interp1(data_log(:,1),data_log(:,2),energy_log,'linear');
delta=exp(delta_log);