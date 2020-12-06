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
D=dir([raw_data_prj_folder raw_data_prj_name]);
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
        
        sgm=XuGenSgmOriginalSizeNoDeadPixelCorrUnified([raw_data_prj_folder D(idx).name],...
            [raw_data_bkg_folder raw_data_bkg_name],config_fbp_file_name,config_preprocessing_file_name);
        
        if isfield(preprocessing_para,'SgmGlobalShift')
            sgm = sgm+preprocessing_para.SgmGlobalShift;
        else
        end
        
        if isfield(preprocessing_para,'PanelSpecificWaterCorrection')
            if preprocessing_para.PanelSpecificWaterCorrection
                sgm = MgPanelCorrectionVer2(sgm,'PMMA','TE',recon_para.SliceCount,...
                    preprocessing_para.SinogramBoundary(1),preprocessing_para.SinogramBoundary(2));
            end
        else
        end
        
        
        if preprocessing_para.PanelCorrectionMethod==1
            fprintf('Performing panel correction with symmetry ...\n');
        elseif preprocessing_para.PanelCorrectionMethod==2
            fprintf('Performing panel correction without symmetry ...\n');
        elseif preprocessing_para.PanelCorrectionMethod==0
        else
            error('PanelCorrectionMethod need to be 0, 1, or 2!');
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
                    preprocessing_para.PanelCorrectionBeginIdx,...
                    preprocessing_para.PanelCorrectionEndIdx,...
                    preprocessing_para.PanelInterpGapWidth);
                
            elseif preprocessing_para.PanelCorrectionMethod==0
            else
                error('PanelCorrectionMethod need to be 0, 1, or 2!');
            end
            
            %set pixels outside the boundary to zero
            if isfield(preprocessing_para,'SinogramBoundary')
                sgm_temp(1:preprocessing_para.SinogramBoundary(1),:)=0;
                sgm_temp(preprocessing_para.SinogramBoundary(2):end,:)=0;
            end
            
            %resize the sinogram
            sgm_resize=imresize(sgm_temp,[recon_para.SinogramWidth, recon_para.SinogramHeight],'box');
            
            %read water corection coefficient
            if isfield( preprocessing_para, 'WaterCorrectionCoef')
                sgm_resize = polyval(preprocessing_para.WaterCorrectionCoef,sgm_resize(:));
            elseif isfield( preprocessing_para, 'WaterCorrectionCoefFile')
                temp_struct = load(preprocessing_para.WaterCorrectionCoefFile);
                temp_field_names = fieldnames(temp_struct);
                eval(['watercoef = temp_struct.' char(temp_field_names(1)) ';']);
                sgm_resize = polyval(watercoef,sgm_resize(:));
            else
                fprintf('Water correction not applied!\n');
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

%%
mkdir(recon_para.OutputDir);
mkdir('temp_config');

XuStructToJsonc('temp_config\config_fbp_temp.jsonc',recon_para);

cmd = ['mgfbp.exe '  'temp_config\config_fbp_temp.jsonc'];
system(cmd);

%delete('config_fbp_temp.jsonc');

status=1;

%% (OPTIONAL) average the images with the same header in the config config file
XuReconToHU(config_fbp_file_name, config_preprocessing_file_name);
XuReconFileAverage(config_fbp_file_name, config_preprocessing_file_name);

