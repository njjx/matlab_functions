energy = 10:50;

mu_adipose = XuGetAtten('adipose',0.95,energy);
mu_water = XuGetAtten('water',1,energy);
mu_breast = XuGetAtten('breast',1.02,energy);

plot(energy,mu_adipose,'.',energy,mu_water,'--',energy,mu_breast);