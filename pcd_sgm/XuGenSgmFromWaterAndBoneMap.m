function sgm_chromatic_prelog = XuGenSgmFromWaterAndBoneMap(sgm_water,sgm_bone,energy_simu,spec_simu)
%XuGenSgmFromWaterAndBoneMap(sgm_water,sgm_bone,energy_simu,spec_simu)
%sgm_water and sgm_bone are the pathlength of water and bone in mm
%They should have the same shape
%energy_simu is the energy vector
%spec_simu is the spectrum vector
%These two vectors should have the same length

if length(energy_simu)~=length(spec_simu)
    error('The energy vector and the spectrum vector do not have the same length!');
end
spec_simu = spec_simu/sum(spec_simu);

length_spec = length(spec_simu);
sgm_width = size(sgm_water,1);
sgm_height = size(sgm_water,2);

atten_water = XuGetAtten('water',1,energy_simu)/10;
atten_water_3d = reshape(atten_water,[1 1 length_spec]);
atten_bone = XuGetAtten('bone',1.92,energy_simu)/10;
atten_bone_3d = reshape(atten_bone,[1 1 length_spec]);

%change the spectrum vector to 3d and normalize it
spectrum_3d = reshape(spec_simu,[1 1 length_spec]);

%attenuation as a function of energy
atten_energy = repmat(atten_water_3d,[sgm_width sgm_height,1]).*repmat(sgm_water,[1 1 length_spec])...
        + repmat(atten_bone_3d,[sgm_width sgm_height,1]).*repmat(sgm_bone,[1 1 length_spec]);
    
%sum the matrix along the energy axis and perform log transform
sgm_chromatic_prelog = sum(exp(-atten_energy).*spectrum_3d,3);

