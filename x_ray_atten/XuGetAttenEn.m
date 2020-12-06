function mu=XuGetAttenEn(s,density,energy)
%mu=XuGetAttenEn(s,density,energy)
%s is the string of the atten file
%density is in g/cm^3
%enegy is in keV
%output unit: cm^{-1}


data=importdata([s '_atten.txt']);
energy_MeV=energy/1000;
if min(energy_MeV)<min(data(:,1)) || max(energy_MeV)>max(data(:,1))
    error('Energy out of range!');
end
data_log=log(data);
energy_log=log(energy_MeV);
mu_log=interp1(data_log(:,1),data_log(:,3),energy_log,'linear');
mu=density*exp(mu_log);