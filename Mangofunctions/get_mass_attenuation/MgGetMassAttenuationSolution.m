function mu = MgGetMassAttenuationSolution(material, energy, concentration)
% function mu = MgGetMassAttenuationSolution(material, energy, concentration)
% Get mass attenuation coefficients of solution.
% mu: mass attenuation coefficients [cm^2/g].
% material: string, the material name. "CaCl2" or "I".
% concentration: solution concentration [mg/mL].
mu_water = MgGetMassAttenuation("water", energy);

if material == "CaCl2"
    mu_Ca = MgGetMassAttenuation("Ca", energy);
    mu_Cl = MgGetMassAttenuation("Cl", energy);
    
    % molar mass [g/mol]
    A_Ca = 40; 
    A_Cl = 35.5;
    
    % mass ratio
    r_Ca = concentration/(concentration+1000) * A_Ca/(A_Ca+2*A_Cl);
    r_Cl = concentration/(concentration+1000) * 2*A_Cl/(A_Ca+2*A_Cl);
    r_water = 1000 / (concentration+1000);
    
    % calculate mass attenuation coefficient
    mu = r_Ca*mu_Ca + r_Cl*mu_Cl + r_water*mu_water;
    
elseif material == "I"
    mu_I = MgGetMassAttenuation("I", energy);
    
    % mass ratio
    r_I = concentration/(concentration+1000);
    r_water = 1000/(concentration+1000);
    
    % calcuate mass attenuation coefficient
    mu = r_I*mu_I + r_water*mu_water;
    
end
    
end