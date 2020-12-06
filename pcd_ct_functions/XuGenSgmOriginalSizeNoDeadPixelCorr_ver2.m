function sgm=XuGenSgmOriginalSizeNoDeadPixelCorr_ver2(s_prj,s_bkg,s_config, bkg_begin_idx)
%sgm=GenSgmOriginalSizeNoDeadPixelCorr(s_prj,s_bkg,s_config, bkg_begin_idx)
%generate sinogram with original size with no dead pixel correction;
%the reason we do not apply the dead pixel correction is that is takes
%time.

%s_prj is the name of the object scan
%s_bkg is the name of the bkg scan
%s_config is the jsonc config file
%bkg_begin_idx is optional to choose some specific frames in bkg file



if nargin == 3
    recon_para=XuReadJsonc(s_config);
    begin_frame_idx=GetParaValue(recon_para,'BeginFrameIdx',1);
    bkg_begin_idx=begin_frame_idx;
else
    recon_para=XuReadJsonc(s_config);
    begin_frame_idx=GetParaValue(recon_para,'BeginFrameIdx',1);
end



%check whether the config file contains the BeginFrameIdx to skip
%to skip the first serval frames. if not, set to 1

img_bkg=XuReadHydraEviFromDirect_ver2(s_bkg,recon_para.BkgNum,bkg_begin_idx);

img_bkg=mean(img_bkg,3);
img_bkg=imresize(img_bkg(:,3:62),[5120 recon_para.SliceCount],'box');
disp(['Reading ' s_prj ' ...']);
sgm=zeros(5120,recon_para.SinogramHeight,recon_para.SliceCount);

pb=MgCmdLineProgressBar('Reading prj data ');
%check whether the config file contains the BeginFrameIdx to skip
%to skip the first serval frames

for idx=1:recon_para.SinogramHeight
    if mod(idx,10)==0
        pb.print(idx,recon_para.SinogramHeight);
        pause(0.01)
    end
    img_temp=XuReadHydraEviFromDirect_ver2(s_prj,1,idx+begin_frame_idx-1);
    img_temp=imresize(img_temp(:,3:62),[5120 recon_para.SliceCount],'box');
    sgm(:,idx,:)=-log((img_temp+eps)./(img_bkg+eps));
end


