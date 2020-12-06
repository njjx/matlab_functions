function status = XuOneStopBoneCorr(config_fbp_file, config_fpj_file, config_bone_corr_file, config_preprocessing_file)
fprintf('****Running one stop bone correction function ... ****\n');
mkdir('temp_config');

%% read config files
recon_para=XuReadJsonc(config_fbp_file);
fpj_para=XuReadJsonc(config_fpj_file);
bone_corr_para=XuReadJsonc(config_bone_corr_file);
preprocessing_para = XuReadJsonc(config_preprocessing_file);
%% 
%if not set, the input dir and output dir of the bone correction config will be 
% the output dir and input dir of the fbp config

if isfield(bone_corr_para,'InputDir') && isfield(bone_corr_para,'OutputDir')
else
    bone_corr_para.InputDir = [recon_para.OutputDir ,'/bone_corr_temp/'];
    bone_corr_para.OutputDir = [recon_para.InputDir ,'/bone_corr_temp/'];
end

if isfield(bone_corr_para,'InputReconDir')
else
    bone_corr_para.InputReconDir = [recon_para.OutputDir '/'];
end

%% pass the recon paras to fpj paras
fpj_para=XuStructPassVal(recon_para,fpj_para);
fpj_para=XuStructPassVal(bone_corr_para,fpj_para);
fpj_para.DetectorElementCount=recon_para.SinogramWidth;
fpj_para.StartAngle = recon_para.ImageRotation;
if isfield(recon_para, 'PixelSize')
    fpj_para = rmfield(fpj_para,'ImageSize');
else
    fpj_para = rmfield(fpj_para,'PixelSize');
end

%% add dimension replace in the fbp config file

recon_para.OutputFileReplace(1) = cellstr('sgm_');

if preprocessing_para.FileNameWithDim && length(recon_para.OutputFileReplace)<3
    recon_para.OutputFileReplace(end+1) = cellstr([ num2str(recon_para.SinogramWidth) ...
        '-' num2str(recon_para.Views)]);
    recon_para.OutputFileReplace(end+1) = cellstr([num2str(recon_para.ImageDimension) ...
        '-'  num2str(recon_para.ImageDimension)]);
end

%%
mkdir(fpj_para.InputDir);
mkdir(fpj_para.OutputDir);

if isfield(bone_corr_para, 'InputFilePrefix')
    D=dir([bone_corr_para.InputReconDir '/*' bone_corr_para.InputFilePrefix '*.raw']);
else
    D=dir([bone_corr_para.InputReconDir '/*' char(recon_para.OutputFileReplace(2)) '*.raw']);
end
%%

fprintf('*Please confirm: the following files are to be processed:\n')
for idx=1:length(D)
    disp(['File #' num2str(idx) ':' bone_corr_para.InputReconDir, '/' D(idx).name]);
end

pause(0.5);

%%
for file_idx=1:length(D)
    fprintf('Processing File #%d ...\n', file_idx)
    corr_name = XuBoneCorrectionChangeName(D(file_idx).name,config_bone_corr_file);
    img=XuSegmentAndSave(D(file_idx).name,config_fbp_file,config_bone_corr_file,config_preprocessing_file);
    
    StructToJsonc('temp_config/config_fpj_bone_corr.jsonc',fpj_para);
    !mgfpj.exe temp_config/config_fpj_bone_corr.jsonc
    
    XuGenBBBWSinogramWithDimJudge('temp_config/config_fpj_bone_corr.jsonc',...
        preprocessing_para.FileNameWithDim);
    
    XuGenBBBWReconFromStruct(recon_para,bone_corr_para);
    %%
    img_corr=XuBoneCorrSummationWithDimJudge(img,'temp_config/config_fbp_bone_corr.jsonc',...
        config_bone_corr_file,preprocessing_para.FileNameWithDim);
    
    if isfield(preprocessing_para, 'ConvertToHU') && isfield(preprocessing_para, 'WaterMu')
        img_corr=XuMuToHU(img_corr,preprocessing_para.WaterMu);
    end
    
    XuWriteRaw([bone_corr_para.InputReconDir corr_name],img_corr);
    fprintf('Final image saved to %s!\n',corr_name);
end