function sgm_truncated = XuSgmTruncate(sgm,s_jsonc)
%sgm_truncated = XuSgmTruncate(sgm,s_jsonc)
sgm_truncated=sgm;
recon_para = XuReadJsonc(s_jsonc);
native_pixel_size=GetParaValue(recon_para,'NativePixelSize',0.1);
pixel_binning=recon_para.DetectorElementSize/native_pixel_size;

if isfield(recon_para,'SinogramBoundary')
    sgm_truncated(1:round(recon_para.SinogramBoundary(1)/pixel_binning),:)=0;
    sgm_truncated(round(recon_para.SinogramBoundary(2)/pixel_binning):end,:)=0;
end