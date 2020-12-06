function mu_water_mean = XuMeanWaterMu(en_simu, spec_simu)

spec_simu = spec_simu/sum(spec_simu);

water_mu = XuGetAtten('water',1,en_simu);
mu_water_mean = sum(spec_simu.*water_mu);