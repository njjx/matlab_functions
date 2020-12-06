function img_hu = XuMuToHU(img_mu, water_mu)

img_hu = img_mu/water_mu*1000-1000;