function status = XuCropReconImages(s_config_fbp, s_config_preprocessing)
%status = XuReconFileAverage( s_config_fbp, s_config_preprocessing)

status = 0;

config_fbp_file_name = s_config_fbp;
config_preprocessing_file_name = s_config_preprocessing;

recon_para=XuReadJsonc(config_fbp_file_name);
preprocessing_para = XuReadJsonc(config_preprocessing_file_name);

if isfield(preprocessing_para, 'XuCropReconImages')
    if preprocessing_para.XuCropReconImages
        
        if isfield(recon_para,'PixelSize')
            crop_radius = 112/recon_para.PixelSize;
        elseif isfield(recon_para,'ImageSize')
            crop_radius = 112/(recon_para.ImageSize/recon_para.ImageDimension);
        end
        
        if isfield(recon_para,'WaterMu')
            value_outside = -1000;
        else
            value_outside = 0;
        end
        
        d_recon = dir([recon_para.OutputDir '/' preprocessing_para.AverageReconInputPrefix '*']);
        if length(d_recon)>=1
            for idx = 1:length(d_recon)
                recon_image_temp = XuReadRaw([recon_para.OutputDir '/' d_recon(idx).name],...
                    [recon_para.ImageDimension recon_para.ImageDimension recon_para.SliceCount]);
                
                for slice_idx = 1:recon_para.SliceCount
                    recon_image_temp(:,:,slice_idx) = MgCropCircleFOV(recon_image_temp(:,:,slice_idx),...
                        crop_radius,value_outside);
                end
                file_output_name = strrep(d_recon(idx).name,'.raw','');
                file_output_name = strrep(file_output_name,'.RAW','');
                XuWriteRaw([recon_para.OutputDir '/' file_output_name],recon_image_temp);
            end
        end
    end
end