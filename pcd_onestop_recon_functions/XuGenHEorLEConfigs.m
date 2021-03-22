function output_folder = XuGenHEorLEConfigs(s_config_fbp,...
    s_config_preprocessing,...
    s_config_ring_correction,...
    s_config_bone_correction, input_config_folder, s_energy_bin)


recon_para = XuReadJsonc([input_config_folder s_config_fbp]);
preprocessing_para = XuReadJsonc([input_config_folder s_config_preprocessing]);
rc_para = XuReadJsonc([input_config_folder s_config_ring_correction]);
bc_para = XuReadJsonc([input_config_folder s_config_bone_correction]);

preprocessing_para.EnergyBin = s_energy_bin;
preprocessing_para.RawDataBkgName = strrep(preprocessing_para.RawDataBkgName,...
    '_TE',['_' s_energy_bin]);
preprocessing_para.RawDataPrjName = strrep(preprocessing_para.RawDataPrjName,...
    '_TE',['_' s_energy_bin]);
preprocessing_para.RawDataBkgName = strrep(preprocessing_para.RawDataBkgName,...
    '_te',['_' s_energy_bin]);
preprocessing_para.RawDataPrjName = strrep(preprocessing_para.RawDataPrjName,...
    '_te',['_' s_energy_bin]);

%here have potential bugs; e.g. input folder = "water"
recon_para.InputDir = strrep(recon_para.InputDir,...
    '/TE',['/' s_energy_bin]);
recon_para.InputDir = strrep(recon_para.InputDir,...
    '/te',['/' s_energy_bin]);
recon_para.InputDir = strrep(recon_para.InputDir,...
    '\TE',['/' s_energy_bin]);
recon_para.InputDir = strrep(recon_para.InputDir,...
    '\te',['/' s_energy_bin]);
recon_para.OutputDir = strrep(recon_para.OutputDir,...
    '/TE',['/' s_energy_bin]);
recon_para.OutputDir = strrep(recon_para.OutputDir,...
    '/te',['/' s_energy_bin]);
recon_para.OutputDir = strrep(recon_para.OutputDir,...
    '\TE',['/' s_energy_bin]);
recon_para.OutputDir = strrep(recon_para.OutputDir,...
    '\te',['/' s_energy_bin]);
if isfield(rc_para,'InputFolder')
    rc_para = rmfield (rc_para,'InputFolder');
end
if isfield(rc_para,'OutputFolder')
    rc_para = rmfield (rc_para,'OutputFolder');
end

output_folder = [input_config_folder '/' s_energy_bin '_config'];
mkdir(output_folder);
XuStructToJsonc([output_folder '/' s_config_fbp], recon_para);
XuStructToJsonc([output_folder '/' s_config_preprocessing], preprocessing_para);
XuStructToJsonc([output_folder '/' s_config_ring_correction], rc_para);
XuStructToJsonc([output_folder '/' s_config_bone_correction], bc_para);

end