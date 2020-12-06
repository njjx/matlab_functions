function Z_eff = MgGetEffectiveZ(material)
% Get the effective Z of material.
% material: molecular formula e.g. "H2O", "CO2";
% or an array of electrons and Z, e.g. for "H2O", it cound be [2*1, 1, 8,
% 8]. For "CO2", it can be [6,6, 2*8, 8].

% if material is molecular formula
if ischar(material) || isstring(material)
    
    % string length
    n = strlength(material);
    
    
    % analyze elements and counts of material
    material = convertStringsToChars(material);
    
    elements = {material(1)};
    counts = [0];
    
    k = 2;
    while k <= n
        if material(k) >= 'a' && material(k) <= 'z'
            elements{end} = [elements{end}, material(k)];
        elseif material(k) >= 'A' && material(k) <= 'Z'
            elements{end+1} = material(k);
            if counts(end) == 0
                counts(end) = 1;
            end
            counts(end+1) = 0;
        elseif material(k) >= '0' && material(k) <= '9'
            counts(end) = counts(end) * 10 + str2num(material(k));
        end
        k = k + 1;
    end
    if counts(end) == 0
        counts(end) = 1;
    end
    
    
    % calculate effective Z
    Z_eff = 0;
    weight = 0;
    
    for k = 1:numel(counts)
        Z = MgGetAtomicZ(elements{k});
        Z_eff = Z_eff + counts(k)*Z * Z^3;
        weight = weight + counts(k)*Z;
    end
    Z_eff = Z_eff / weight;
    Z_eff = Z_eff^(1/3);
    
else
    % if material is a general data array
    N = numel(material);
    
    weight = 0;
    Z_eff = 0;
    for k = 1:2:N-1
        Z_eff = Z_eff + material(k)*material(k+1)^3;
        
        weight = weight + material(k);
        
        
    end
    
    Z_eff = Z_eff / weight;
    Z_eff = Z_eff^(1/3);
    
end


end

