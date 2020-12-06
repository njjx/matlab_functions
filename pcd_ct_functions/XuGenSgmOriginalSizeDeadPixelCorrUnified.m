function sgm=XuGenSgmOriginalSizeDeadPixelCorrUnified(s_prj,s_bkg,s_fbp_config,s_preprocessing_config)
%sgm=XuGenSgmOriginalSizeNoDeadPixelCorrUnified(s_prj,s_bkg,s_fbp_config,s_preprocessing_config)
%generate sinogram with original size with no dead pixel correction;
%the reason we do not apply the dead pixel correction is that is takes
%time.

%s_prj is the name of the object scan
%s_bkg is the name of the bkg scan
%s_fbp_config is the fbp jsonc config file
%s_preprocessing_config is the preprocessing config file

recon_para=XuReadJsonc(s_fbp_config);
preprocessing_para = XuReadJsonc(s_preprocessing_config);

%check whether the config file contains the BeginFrameIdx to skip
%to skip the first serval frames. if not, set to 1
begin_frame_idx=GetParaValue(preprocessing_para,'BeginFrameIdx',1);
%check whether the config file contains the BeginBkgFrameIdx to skip
%to skip the first serval frames. if not, set to begin_frame_idx
begin_bkg_frame_idx = GetParaValue(preprocessing_para,'BeginBkgFrameIdx',begin_frame_idx);

if preprocessing_para.DetectorFirmwareVersion==1
    img_bkg=XuReadHydraEviFromDirect(s_bkg,preprocessing_para.BkgNum,begin_bkg_frame_idx);
elseif preprocessing_para.DetectorFirmwareVersion==2
    img_bkg=XuReadHydraEviFromDirect_ver2_w_dead_pixel_correction(s_bkg,preprocessing_para.BkgNum,begin_bkg_frame_idx);
else
    error('Version number can only be 1 or 2!');
end

img_bkg=mean(img_bkg,3);
%img_bkg=imresize(img_bkg(:,3:62),[5120 recon_para.SliceCount]);
disp(['Reading ' s_prj ' ...']);
sgm=zeros(5120,recon_para.SinogramHeight,recon_para.SliceCount);

pb=MgCmdLineProgressBar('Reading prj data frame#');

for idx=1:recon_para.SinogramHeight
    if mod(idx,50)==0 || idx == recon_para.SinogramHeight
        pb.print(idx,recon_para.SinogramHeight);
        pause(0.01)
    end
    
    if preprocessing_para.DetectorFirmwareVersion==1
        img_temp=XuReadHydraEviFromDirect(s_prj,1,idx+begin_frame_idx-1);
    elseif preprocessing_para.DetectorFirmwareVersion==2
        img_temp=XuReadHydraEviFromDirect_ver2_w_dead_pixel_correction(s_prj,1,idx+begin_frame_idx-1);
    else
        error('Version number can only be 1 or 2!');
    end
    
    sgm_temp = -log((img_temp+eps)./(img_bkg+eps));
    sgm_temp = imresize(sgm_temp(:,3:62),[5120 recon_para.SliceCount]);
    sgm(:,idx,:)=sgm_temp;
end


