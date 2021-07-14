function status = XuWholeReconProcessWithConfigDualEnergy(s_config)


paras = XuReadJsonc(s_config);

%%
s_energy_bin = paras.EnergyBin;

recon_only = paras.ReconOnly;
%% initialize config file names
input_config_folder = paras.ConfigFolder;
s_config_fbp = paras.ConfigFbp;
s_config_preprocessing=paras.ConfigPreprocessing;
s_config_ring_correction=paras.ConfigRingCorrection;
s_config_bone_correction=paras.ConfigBoneCorrection;
s_config_fpj = paras.ConfigFpj;
%% generate LE images
if paras.AlreadyHaveLEImages || ~strcmp(lower(s_energy_bin),'le')
else
    if isfield(paras , 'AlreadyHaveAirLEImages')
        XuGenLEImages([input_config_folder '/' s_config_fbp],...
            [input_config_folder '/' s_config_preprocessing], ~paras.AlreadyHaveAirLEImages);
    else
        XuGenLEImages([input_config_folder '/' s_config_fbp],...
            [input_config_folder '/' s_config_preprocessing],1);
    end
end
%% generate configs for LE or HE
output_folder = XuGenHEorLEConfigs(s_config_fbp,...
    s_config_preprocessing,...
    s_config_ring_correction,...
    s_config_bone_correction,...
    input_config_folder,s_energy_bin);
copyfile([input_config_folder s_config_fpj],[output_folder s_config_fpj])

%% modify the mu value of water
if isfield(paras,'MeasuredMuVersusMuYouWant')
    HU_measured = paras.MeasuredMuVersusMuYouWant(1);
    HU_you_want = paras.MeasuredMuVersusMuYouWant(2);
    water_mu = XuReadJsoncField([output_folder '\' s_config_fbp],'WaterMu');
    water_mu = XuCorrectWaterMu(water_mu,HU_measured,HU_you_want);
    XuModifyJsoncFile([output_folder '\' s_config_fbp], 'WaterMu', water_mu);
end

if recon_only ==1
    XuModifyJsoncFile([output_folder '\' s_config_preprocessing], 'ReconAndAverageOnly', 1);
else
    XuModifyJsoncFile([output_folder '\' s_config_preprocessing], 'ReconAndAverageOnly', 0);
end
%% change config folder
XuModifyJsoncFile(s_config,'ConfigFolder',output_folder,'config_one_stop_recon_temp.jsonc');
%% reconstruction
XuWholeReconProcessWithConfig('config_one_stop_recon_temp.jsonc');
delete('config_one_stop_recon_temp.jsonc');
status = 1;

