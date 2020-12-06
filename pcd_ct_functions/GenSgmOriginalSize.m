function sgm=GenSgmOriginalSize(s_prj,s_bkg,s_config)
%sgm=GenSgmOriginalSize(s_prj,s_bkg,s_config)

recon_para=jsondecodewithcomment(s_config);
img_bkg=readHydraEviFromDirect(s_bkg,recon_para.BkgNum,recon_para.BeginFrameIdx);

img_bkg=mean(img_bkg,3);
img_bkg=DeadPixelCorrection(img_bkg);
img_bkg=imresize(img_bkg(:,3:62),[5120 recon_para.SliceCount]);

sgm=zeros(5120,recon_para.SinogramHeight,recon_para.SliceCount);
pb=MgCmdLineProgressBar('Reading prj data ');
for idx=1:recon_para.SinogramHeight
    if mod(idx,50)==0
        pb.print(idx,recon_para.SinogramHeight);
        pause(0.01)
    end
    img_temp=readHydraEviFromDirect(s_prj,1,+recon_para.BeginFrameIdx-1);
    img_temp=DeadPixelCorrection(img_temp);
    img_temp=imresize(img_temp(:,3:62),[5120 recon_para.SliceCount]);
    sgm(:,idx,:)=-log((img_temp+eps)./(img_bkg+eps));
end
