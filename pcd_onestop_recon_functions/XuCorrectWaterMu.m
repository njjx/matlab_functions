function water_mu_new = XuCorrectWaterMu(water_mu, HU_measured, HU_you_want)
HU_measured = HU_measured+1000;
HU_you_want = HU_you_want+1000;

water_mu_new = HU_measured/HU_you_want*water_mu;