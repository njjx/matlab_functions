function density = MgGetMaterialDensity(material)
% density = MgGetMaterialDensity(material)
% Get the density of material.
% material: e.g. "water", "air", "Cu", "I".
% density: [g/cm3]

switch material
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %compound
    case "adipose"
        density = 0.95;
    case "air"
        density = 1.205e-3;
    case "CaCl2"
        density = 2.15;
    case "teflon"
        density = 2.2;
    case "water"
        density = 1;
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % element
    case "Al"
        density = 2.7;
    case "Au"
        density = 19.3;
    case "Ca"
        density = 1.55;
    case "Ce"
        density = 6.78;
    case "Cu"
        density = 8.96;
    case "Gd"
        density = 7.89;
    case "I"
        density = 4.92;
    case "Sn"
        density = 7.3;
    case "Tm"
        density = 9.33;
    case "W"
        density = 19.3;
    otherwise
        error("Unknown material '%s'\n", material);
        
end

end

