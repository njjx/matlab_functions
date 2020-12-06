function img = XuSegmentAndSave(file_name,s_jsonc_fbp,s_jsonc_bone_corr,s_jsonc_preprocessing)
%status = XuSegmentAndSave(file_name,s_jsonc_fbp,s_jsonc_bone_corr,,s_jsonc_preprocessing)
%s_jsonc_preprocessing is optional

if nargin == 3
    preprocessing_para.A=0;
else
    preprocessing_para = XuReadJsonc(s_jsonc_preprocessing);
end

recon_para = XuReadJsonc(s_jsonc_fbp);
bone_corr_para = XuReadJsonc(s_jsonc_bone_corr);

if isfield (bone_corr_para, 'InputReconDir')
    rec_folder=bone_corr_para.InputReconDir;
else
    rec_folder=[recon_para.OutputDir '/'];
end

if isfield(bone_corr_para,'InputDir') && isfield(bone_corr_para,'OutputDir')
else
    bone_corr_para.InputDir = [recon_para.OutputDir ,'/bone_corr_temp'];
    bone_corr_para.OutputDir = [recon_para.InputDir ,'/bone_corr_temp'];
end

if isfield(bone_corr_para,'InputReconDir')
else
    bone_corr_para.InputReconDir = [recon_para.OutputDir '/'];
end


img_folder=bone_corr_para.InputDir;
img_dim=recon_para.ImageDimension;
img_slice_count=recon_para.SliceCount;

img=ReadRaw([rec_folder file_name],[img_dim ...
    img_dim img_slice_count],'float32');

if isfield(preprocessing_para, 'ConvertToHU') && isfield(preprocessing_para, 'WaterMu')
    mu_water = preprocessing_para.WaterMu;
    
    bone_threshold_low_mu = XuHUToMu(bone_corr_para.BoneThresholdLow, mu_water);
    bone_threshold_high_mu = XuHUToMu(bone_corr_para.BoneThresholdHigh, mu_water);
    
    tissue_threshold_low_mu = XuHUToMu(bone_corr_para.TissueThresholdLow, mu_water);
    tissue_threshold_high_mu = XuHUToMu(bone_corr_para.TissueThresholdHigh, mu_water);
    
    img_mu = XuHUToMu(img,mu_water);
    
    img_bone=img_mu.*(img_mu>bone_threshold_low_mu).*(img_mu<bone_threshold_high_mu);
    img_tissue=img_mu.*(img_mu>tissue_threshold_low_mu).*(img_mu<tissue_threshold_high_mu);
    img=img_mu;
elseif isfield(recon_para, 'WaterMu')
    img_bone=img.*(img>bone_corr_para.BoneThresholdLow).*(img<bone_corr_para.BoneThresholdHigh);
    img_bone(img<=bone_corr_para.BoneThresholdLow)=-1000;
    img_bone(img>=bone_corr_para.BoneThresholdHigh)=-1000;
    img_tissue=img.*(img>bone_corr_para.TissueThresholdLow).*(img<bone_corr_para.TissueThresholdHigh);
    img_tissue(img<=bone_corr_para.TissueThresholdLow)=-1000;
    img_tissue(img>=bone_corr_para.TissueThresholdHigh)=-1000;    
else
    img_bone=img.*(img>bone_corr_para.BoneThresholdLow).*(img<bone_corr_para.BoneThresholdHigh);
    img_tissue=img.*(img>bone_corr_para.TissueThresholdLow).*(img<bone_corr_para.TissueThresholdHigh);
end

WriteRaw([img_folder '/img_bone'],img_bone);
WriteRaw([img_folder '/img_tissue'],img_tissue);
