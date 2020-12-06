function electron_density=XuElectronDensity(s,density)
%electron_density=XuElectronDensity(s,density)
z_and_a=importdata('z_and_a.txt');
mass_fraction=importdata([s,'_z_frac.txt']);

total_Z=0;
for idx=1:size(mass_fraction,1)
    Z=round(mass_fraction(idx,1));
    total_Z=total_Z+...
        mass_fraction(idx,2)*z_and_a(Z,1)/z_and_a(Z,2);
end

electron_density=total_Z*density;
