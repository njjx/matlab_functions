function status = XuOneStopRecon(s_config_fbp, s_config_preprocessing)
%status = XuOneStopRecon(s_config_fbp, s_config_preprocsssing)

fprintf('****Running one stop recon function ... ****\n');

%%
status = 0;

config_fbp_file_name = s_config_fbp;
config_preprocessing_file_name = s_config_preprocessing;

recon_para=XuReadJsonc(config_fbp_file_name);
preprocessing_para = XuReadJsonc(config_preprocessing_file_name);

%% initilize parameters
if isfield(preprocessing_para,'RawDataFolder')
    raw_data_prj_folder=preprocessing_para.RawDataFolder;
    raw_data_bkg_folder=preprocessing_para.RawDataFolder;
elseif isfield(preprocessing_para,'RawDataPrjFolder') && isfield(preprocessing_para,'RawDataBkgFolder')
    raw_data_prj_folder=preprocessing_para.RawDataPrjFolder;
    raw_data_bkg_folder=preprocessing_para.RawDataBkgFolder;
end
sgm_folder=recon_para.InputDir;
raw_data_bkg_name=preprocessing_para.RawDataBkgName;
raw_data_prj_name=preprocessing_para.RawDataPrjName;
native_pixel_size=GetParaValue(recon_para,'NativePixelSize',0.1);
detector_width=GetParaValue(recon_para,'DetectorWidth',5120);
if isfield(preprocessing_para,'EnergyBin')
    s_energy_bin = preprocessing_para.EnergyBin;
else
    s_energy_bin = 'TE';
end

%% add dimension replace in the fbp config file
%may have some bug with cone beam recon; need to be reviewed in the future!
if preprocessing_para.FileNameWithDim
    recon_para.OutputFileReplace(end+1) = cellstr([ num2str(recon_para.SinogramWidth) ...
        '-' num2str(recon_para.SinogramHeight)]);
    recon_para.OutputFileReplace(end+1) = cellstr([num2str(recon_para.ImageDimension) ...
        '-'  num2str(recon_para.ImageDimension)]);
end

%%
mkdir(sgm_folder);%make sinogram folder
D=dir([raw_data_prj_folder '/' raw_data_prj_name]);
%%

fprintf('**Please confirm: %d raw data files are to be processed:\n',length(D));
for idx=1:length(D)
    disp(['File #' num2str(idx) ':' raw_data_prj_folder, '/' D(idx).name]);
end
fprintf('******************************\n');
pause(1);

%%

if isfield(preprocessing_para,'ReconAndAverageOnly')
    recon_only = preprocessing_para.ReconAndAverageOnly;
else
    recon_only = 0;
end

if recon_only==0
    
    for idx=1:length(D)
        
        fprintf('Processing file #%d;', idx);
        
        %generate the name of the sinogram to save
        sgm_name = XuGenSgmName(D(idx).name,config_preprocessing_file_name);
        
        %generate sinogram with original size with no dead pixel correction;
        %the reason we do not apply the dead pixel correction is that is takes
        %time.
        
        [sgm,bkg_count]=XuGenSgmFromEviFiles([raw_data_prj_folder '/' D(idx).name],...
            [raw_data_bkg_folder '/' raw_data_bkg_name],config_fbp_file_name,config_preprocessing_file_name);
        
        if isfield(preprocessing_para,'SaveOriginalSinogram')
            if preprocessing_para.SaveOriginalSinogram
                if ~exist([sgm_folder '/un_corr' ], 'dir')
                    mkdir([sgm_folder '/un_corr' ]);
                end
                XuSaveSgmSlice(['un_corr/' sgm_name],sgm, 1, config_fbp_file_name);
            end
        end
        
        if isfield(preprocessing_para,'SinogramBoundary')
            sgm(1:preprocessing_para.SinogramBoundary(1),:)=0;
            sgm(preprocessing_para.SinogramBoundary(2):end,:)=0;
        end
        
        % correct the views with abnormal readout
        if isfield(preprocessing_para,'CorrectViewsWithAbnormalReadout')
            if preprocessing_para.CorrectViewsWithAbnormalReadout
                sgm_ave_rows = mean(sgm(:,:,1),1);
                sgm_ave_rows_diff = sgm_ave_rows - medfilt1(sgm_ave_rows,5);
                views_idx_with_problems = find(sgm_ave_rows_diff>0.02);
                sgm(:,views_idx_with_problems,:) = sgm(:,views_idx_with_problems,:)...
                    - sgm_ave_rows_diff(views_idx_with_problems);
            end
        end
        
        if isfield(preprocessing_para,'AdjustIndividualPanel')
            tmp = preprocessing_para.AdjustIndividualPanel;
            if tmp(1)~=0
                for correction_idx = 1:length(tmp)/2
                    panel_idx = tmp(2*correction_idx-1);
                    offset = tmp(2*correction_idx);
                    sgm(256*(panel_idx-1)+2:256*(panel_idx)-1,:,:) = ...
                        sgm(256*(panel_idx-1)+2:256*(panel_idx)-1,:,:)*offset;
                end
            end
        else
        end
        
        
        if isfield(preprocessing_para,'SgmGlobalShift')
            sgm = sgm+preprocessing_para.SgmGlobalShift;
        else
        end

        if isfield(preprocessing_para,'PanelSpecificWaterCorrection')
            if preprocessing_para.PanelSpecificWaterCorrection && isfield(preprocessing_para,'Protocol')
                
                sgm = XuPanelCorrection(sgm,'PMMA',s_energy_bin,recon_para.SliceCount,...
                    preprocessing_para.SinogramBoundary(1),preprocessing_para.SinogramBoundary(2),...
                    preprocessing_para.Protocol);
                
            elseif preprocessing_para.PanelSpecificWaterCorrection
                sgm = XuPanelCorrection(sgm,'PMMA',s_energy_bin,recon_para.SliceCount,...
                    preprocessing_para.SinogramBoundary(1),preprocessing_para.SinogramBoundary(2));
            end
        else
        end

        
        if isfield(preprocessing_para,'CorrectViewsWithAbnormalReadout')
            if preprocessing_para.CorrectViewsWithAbnormalReadout
                sgm_ave_rows = mean(sgm(:,:,1),1);
                sgm_ave_rows_diff = sgm_ave_rows - medfilt1(sgm_ave_rows,5);
                views_idx_with_problems = find(sgm_ave_rows_diff>0.02);
                sgm(:,views_idx_with_problems,:) = sgm(:,views_idx_with_problems,:)...
                    - sgm_ave_rows_diff(views_idx_with_problems);
            end
        end
        %
        if isfield(preprocessing_para,'PrjScatterCount')
            sgm_to_count = bkg_count*exp(-sgm);
            sgm_to_count = sgm_to_count-preprocessing_para.PrjScatterCount;
            sgm = log(bkg_count./sgm_to_count);
        end
        %
        
        if preprocessing_para.PanelCorrectionMethod==1
            fprintf('Performing panel correction with symmetry ...\n');
        elseif preprocessing_para.PanelCorrectionMethod==2
            fprintf('Performing panel correction without symmetry ...\n');
        elseif preprocessing_para.PanelCorrectionMethod==3
            fprintf('Performing panel interpolation ...\n');
        elseif preprocessing_para.PanelCorrectionMethod==0
        else
            error('PanelCorrectionMethod need to be 0-3!');
        end
        
        pb=MgCmdLineProgressBar('Processing slice No.');
        
        for slice_idx=1:recon_para.SliceCount
            pb.print(slice_idx, recon_para.SliceCount);
            
            sgm_temp = sgm(:,:,slice_idx);
            if preprocessing_para.PanelCorrectionMethod==1
                %perform panel symmetry correction
                sgm_temp=XuPanelSymmetryCorrection(sgm_temp,...
                    recon_para.Views,256,(1+detector_width)/2-...
                    recon_para.DetectorOffcenter/native_pixel_size,...
                    preprocessing_para.PanelCorrectionBeginIdx,...
                    preprocessing_para.PanelCorrectionEndIdx,...
                    preprocessing_para.PanelSymmetryGapWidth);
                
                %perform panel alignment after the symmertry correction
                sgm_temp=XuPanelAlignment(sgm_temp,...
                    recon_para.Views,256,...
                    preprocessing_para.PanelCorrectionBeginIdx,...
                    preprocessing_para.PanelCorrectionEndIdx,...
                    preprocessing_para.PanelSymmetryGapWidth,...
                    preprocessing_para.PanelAlignmentInterpWidth);
                
                %perform interpolation of the gap between panels
                sgm_temp=XuPanelInterp(sgm_temp,...
                    recon_para.SinogramHeight,detector_width,256,...
                    preprocessing_para.PanelCorrectionBeginIdx,...
                    preprocessing_para.PanelCorrectionEndIdx,...
                    preprocessing_para.PanelInterpGapWidth);
            elseif preprocessing_para.PanelCorrectionMethod==2
                sgm_temp=XuPanelAlignmentWithoutSymmetry(sgm_temp,...
                    recon_para.Views, 256,...
                    preprocessing_para.PanelCorrectionBeginIdx,...
                    preprocessing_para.PanelCorrectionEndIdx,...
                    preprocessing_para.PanelInterpGapWidth,...
                    preprocessing_para.PanelAlignmentInterpWidth);
                
                sgm_temp=XuPanelInterp(sgm_temp,...
                    recon_para.SinogramHeight,detector_width,256,...
                    2,...
                    18,...
                    preprocessing_para.PanelInterpGapWidth);
            elseif preprocessing_para.PanelCorrectionMethod==3
                sgm_temp=XuPanelInterp(sgm_temp,...
                    recon_para.SinogramHeight,detector_width,256,...
                    preprocessing_para.PanelCorrectionBeginIdx,...
                    preprocessing_para.PanelCorrectionEndIdx,...
                    preprocessing_para.PanelInterpGapWidth);
                
            elseif preprocessing_para.PanelCorrectionMethod==0
            else
                error('PanelCorrectionMethod need to be 0-3!');
            end
            
            %set pixels outside the boundary to zero
            if isfield(preprocessing_para,'SinogramBoundary')
                sgm_temp(1:preprocessing_para.SinogramBoundary(1),:)=0;
                sgm_temp(preprocessing_para.SinogramBoundary(2):end,:)=0;
            end
            
            %resize the sinogram
            sgm_resize=imresize(sgm_temp,[recon_para.SinogramWidth, recon_para.SinogramHeight],'box');
            
            % truncation correction
            %             if isfield(preprocessing_para,'TruncationCorrection')
            %                 if preprocessing_para.TruncationCorrection
            %                     fprintf('Performing truncation correction ...\n');
            %                     sgm_resize = XuExtrapSgmCarm(sgm_resize,s_config_preprocessing,s_config_fbp );
            %
            %                 end
            %             end
            
            
            %read water corection coefficient
            if isfield( preprocessing_para, 'WaterCorrectionCoef')
                sgm_resize = polyval(preprocessing_para.WaterCorrectionCoef,sgm_resize(:));
            elseif isfield( preprocessing_para, 'WaterCorrectionCoefFile')
                temp_struct = load(preprocessing_para.WaterCorrectionCoefFile);
                temp_field_names = fieldnames(temp_struct);
                eval(['watercoef = temp_struct.' char(temp_field_names(1)) ';']);
                sgm_resize = polyval(watercoef,sgm_resize(:));
            else
                %fprintf('Water correction not applied!\n');
            end
            
            %save to file
            if preprocessing_para.FileNameWithDim
                XuSaveSgmSliceWithDim(sgm_name,sgm_resize, slice_idx, config_fbp_file_name);
            else
                XuSaveSgmSlice(sgm_name,sgm_resize, slice_idx, config_fbp_file_name);
            end
            
        end
    end
else
end
%% truncation correction after preprocessing


if isfield(preprocessing_para,'TruncationCorrection')
    if preprocessing_para.TruncationCorrection
        fprintf('Performing truncation correction...\n');
        for idx=1:length(D)
            sgm_name = XuGenSgmName(D(idx).name,config_preprocessing_file_name);
            DD = dir([recon_para.InputDir '\' sgm_name '*']);
            if length(DD)==0
                error('Can not find the sinogram to perform truncation correction!');
            end
            sgm_resize = XuReadRaw([recon_para.InputDir '\' DD(1).name],...
                [recon_para.SinogramWidth recon_para.SinogramHeight recon_para.SliceCount]);
            sgm_resize = XuExtrapSgmCarm(sgm_resize,s_config_preprocessing,s_config_fbp );
            
            sgm_save_name = strrep(DD(1).name,'.raw','');
            sgm_save_name = strrep(sgm_save_name,'.RAW','');
            XuWriteRaw([recon_para.InputDir '\' sgm_save_name],sgm_resize);
        end
        fprintf(' Truncation correction finished!\n');
    end
end

%%
mkdir(recon_para.OutputDir);
mkdir('temp_config');

XuStructToJsonc('temp_config\config_fbp_temp.jsonc',recon_para);

cmd = ['mgfbp.exe '  'temp_config\config_fbp_temp.jsonc'];
system(cmd);

%delete('config_fbp_temp.jsonc');

status=1;

%% (OPTIONAL) convert the pixels values to HU after recon
XuReconToHU(config_fbp_file_name, config_preprocessing_file_name);

%% (OPTIONAL) crop the images to field of view

XuCropReconImages(config_fbp_file_name, config_preprocessing_file_name);

%% (OPTIONAL) average the images with the same header in the config config file
XuReconFileAverage(config_fbp_file_name, config_preprocessing_file_name);

