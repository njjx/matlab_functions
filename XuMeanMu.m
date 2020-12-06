function mu_material_mean = XuMeanMu(material, density, en_simu, spec_simu)

spec_simu = spec_simu/sum(spec_simu);

material_mu = XuGetAtten(material,density,en_simu);
mu_material_mean = sum(spec_simu.*material_mu);