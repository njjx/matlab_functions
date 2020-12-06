function status = XuReconFileAverage(s_config_fbp, s_config_preprocessing)
%status = XuReconFileAverage( s_config_fbp, s_config_preprocessing)

status = 0;

config_fbp_file_name = s_config_fbp;
config_preprocessing_file_name = s_config_preprocessing;

recon_para=XuReadJsonc(config_fbp_file_name);
preprocessing_para = XuReadJsonc(config_preprocessing_file_name);

if isfield(preprocessing_para, 'AverageReconFiles')
    if preprocessing_para.AverageReconFiles
        d_recon = dir([recon_para.OutputDir '/' preprocessing_para.AverageReconInputPrefix '*']);
        if length(d_recon)>1
            recon_image_average = 0;
            for idx = 1:length(d_recon)
                recon_image_temp = XuReadRaw([recon_para.OutputDir '/' d_recon(idx).name],...
                    [recon_para.ImageDimension recon_para.ImageDimension recon_para.SliceCount]);
                recon_image_average =recon_image_average+recon_image_temp;
            end
            recon_image_average = recon_image_average/length(d_recon);
            if isfield(preprocessing_para,'EnergyBin')
                recon_image_average_name = [preprocessing_para.AverageReconAddPrefix...
                    preprocessing_para.AverageReconInputPrefix, preprocessing_para.EnergyBin];
            else
                recon_image_average_name = [preprocessing_para.AverageReconAddPrefix...
                    preprocessing_para.AverageReconInputPrefix];
            end
            
            if preprocessing_para.FileNameWithDim
                XuWriteRawWithDim([recon_para.OutputDir '/' recon_image_average_name],...
                    recon_image_average,3);
            else
                XuWriteRaw([recon_para.OutputDir '/' recon_image_average_name],...
                    recon_image_average);
            end
            
            disp(['Average file saved to ' recon_para.OutputDir '/' recon_image_average_name]);
            if isfield(preprocessing_para,'DeleteOriginalReconFilesAfterAverage')
                if preprocessing_para.DeleteOriginalReconFilesAfterAverage
                    for idx = 1:length(d_recon)
                        delete([recon_para.OutputDir '/' d_recon(idx).name]);
                    end
                    disp('Original files deleted!');
                end
            end
            
        else
            fprintf('There is only one image; no need to average!\n');
        end
    end
end