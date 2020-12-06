function img_mu = XuHUToMu(img_hu, water_mu)

img_mu = (img_hu/1000+1)*water_mu;