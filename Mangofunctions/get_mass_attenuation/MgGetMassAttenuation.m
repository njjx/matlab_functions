function mu = MgGetMassAttenuation(material, energy)
% function mu = MgGetMassAttenuation(material, energy)
% Get mass attenuation coefficients.
% mu: [cm^2/g].
% material: string, the material name.
% energy: array of energy [keV].
mu_file = importdata(sprintf("%s.txt", material));
mu = interp1(mu_file(:,1)*1000, log(mu_file(:,2)), energy);
mu = exp(mu);
end