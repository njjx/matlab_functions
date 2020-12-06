function status = XuReconToHU(s_config_fbp, s_config_preprocessing)
%status = XuReconToHU( s_config_fbp, s_config_preprocessing)

status = 0;

config_fbp_file_name = s_config_fbp;
config_preprocessing_file_name = s_config_preprocessing;

recon_para=XuReadJsonc(config_fbp_file_name);
preprocessing_para = XuReadJsonc(config_preprocessing_file_name);

if isfield(preprocessing_para, 'ConvertToHU') && isfield(preprocessing_para, 'WaterMu')
    fprintf('Converting to HU ...\n');
    if preprocessing_para.ConvertToHU
        d_recon = dir([recon_para.OutputDir '/' preprocessing_para.AverageReconInputPrefix '*']);
        if length(d_recon)>=1
            for idx = 1:length(d_recon)
                recon_image_temp = XuReadRaw([recon_para.OutputDir '/' d_recon(idx).name],...
                    [recon_para.ImageDimension recon_para.ImageDimension recon_para.SliceCount]);
                recon_image_temp = XuMuToHU(recon_image_temp,preprocessing_para.WaterMu);
                XuWriteRawNoAddDotRaw([recon_para.OutputDir '/' d_recon(idx).name], recon_image_temp);
            end
        else
            error('No recon files found!')
        end
    end
end