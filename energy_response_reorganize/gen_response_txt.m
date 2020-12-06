clear all
close all
clc

threshold_energy = '[1:150]';
mkdir('temp_config');
for energy = 1:150
    energy
    XuModifyJsoncFile('CONFIG_energy_response.jsonc','InputPhotonEnergy',energy,...
        'temp_config\CONFIG_energy_response.jsonc');
    XuModifyJsoncFile('temp_config\CONFIG_energy_response.jsonc','ThresholdEnergy',threshold_energy);
    [th, output] = XuGenPCDERFVer1('temp_config\CONFIG_energy_response.jsonc');
    if energy == 1
        fid = fopen('..\Mangofunctions\PCD_energy_response\MgEnergyResponseData_acs_2.txt','w+');
    else
        fid = fopen('..\Mangofunctions\PCD_energy_response\MgEnergyResponseData_acs_2.txt','a');
    end
    fprintf(fid,'%.5f ',output);
    fprintf(fid,'\n ');
    fclose (fid);
    
end
%%