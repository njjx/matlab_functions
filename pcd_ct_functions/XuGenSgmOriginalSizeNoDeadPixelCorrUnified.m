function [sgm,bkg_count]=XuGenSgmOriginalSizeNoDeadPixelCorrUnified(s_prj,s_bkg,s_fbp_config,s_preprocessing_config)
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
    if isfield(preprocessing_para, 'DeadPixelCorrection')
        if preprocessing_para.DeadPixelCorrection
            img_bkg=XuReadHydraEviFromDirect_ver2_w_dead_pixel_correction(s_bkg,preprocessing_para.BkgNum,begin_bkg_frame_idx);
        else
            img_bkg=XuReadHydraEviFromDirect_ver2(s_bkg,preprocessing_para.BkgNum,begin_bkg_frame_idx);
        end
    else
        img_bkg=XuReadHydraEviFromDirect_ver2(s_bkg,preprocessing_para.BkgNum,begin_bkg_frame_idx);
    end
else
    error('Version number can only be 1 or 2!');
end

img_bkg=mean(img_bkg,3);
if isfield(preprocessing_para,'PostlogBinning')
    if preprocessing_para.PostlogBinning
        img_bkg=img_bkg(:,3:62);
    else
        img_bkg=imresize(img_bkg(:,3:62),[5120 recon_para.SliceCount]);
    end
else
    img_bkg=imresize(img_bkg(:,3:62),[5120 recon_para.SliceCount]);
end
if isfield(preprocessing_para,'SinogramBoundary')
    bkg_count = mean2(img_bkg(preprocessing_para.SinogramBoundary(1):...
        img_bkg(preprocessing_para.SinogramBoundary(1)),:));
else
    bkg_count=0;
end

disp(['Reading ' s_prj ' ...']);
sgm=zeros(5120,recon_para.SinogramHeight,recon_para.SliceCount);

%prepare for scatter correction
if isfield(preprocessing_para,'PrjScatterCount')
    non_gap_idx =1:5120;
    gap_idx = [];
    for panel_idx = 1:19
        gap_idx = [gap_idx,panel_idx*256-1:panel_idx*256+2];
    end
    non_gap_idx(gap_idx)=[];
end

pb=MgCmdLineProgressBar('Reading prj data frame#');

for idx=1:recon_para.SinogramHeight
    if mod(idx,50)==0 || idx == recon_para.SinogramHeight
        pb.print(idx,recon_para.SinogramHeight);
        pause(0.01)
    end
    
    if preprocessing_para.DetectorFirmwareVersion==1
        img_temp=XuReadHydraEviFromDirect(s_prj,1,idx+begin_frame_idx-1);
    elseif preprocessing_para.DetectorFirmwareVersion==2
        if isfield(preprocessing_para, 'DeadPixelCorrection')
            if preprocessing_para.DeadPixelCorrection
                img_temp=XuReadHydraEviFromDirect_ver2_w_dead_pixel_correction(s_prj,1,idx+begin_frame_idx-1);
            else
                img_temp=XuReadHydraEviFromDirect_ver2(s_prj,1,idx+begin_frame_idx-1);
            end
        else
            img_temp=XuReadHydraEviFromDirect_ver2(s_prj,1,idx+begin_frame_idx-1);
        end
    else
        error('Version number can only be 1 or 2!');
    end
    
%     if isfield(preprocessing_para,'PrjScatterCount')
%         img_temp_medfilt = medfilt1(mean(img_temp,2),5);
%         gap_ratio = mean(img_temp,2)./img_temp_medfilt;
%         gap_scatter_count = preprocessing_para.PrjScatterCount*gap_ratio;
%         
%         img_temp(non_gap_idx,:)= img_temp(non_gap_idx,:)-preprocessing_para.PrjScatterCount;
%         img_temp(gap_idx,:)= img_temp(gap_idx,:)-gap_scatter_count(gap_idx);
%     end
    
    if isfield(preprocessing_para,'PostlogBinning')
        if preprocessing_para.PostlogBinning
            img_temp=img_temp(:,3:62);
            sgm_temp=-log((img_temp+eps)./(img_bkg+eps));
            sgm_temp = imresize(sgm_temp,[5120 recon_para.SliceCount]);
            sgm(:,idx,:) = sgm_temp;
        else
            img_temp=imresize(img_temp(:,3:62),[5120 recon_para.SliceCount]);
            sgm(:,idx,:)=-log((img_temp+eps)./(img_bkg+eps));
        end
    else
        img_temp=imresize(img_temp(:,3:62),[5120 recon_para.SliceCount]);
        sgm(:,idx,:)=-log((img_temp+eps)./(img_bkg+eps));
    end

end


