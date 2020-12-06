function status = XuGenBBBWSinogramWithDim(s_jsonc_fpj)
%status = XuGenBBBWSinogramWithDim(s_jsonc_fpj)
fpj_para = XuReadJsonc (s_jsonc_fpj);
sgm_folder = fpj_para.OutputDir;
img_slice_count=fpj_para.SliceCount;
sgm_tissue=XuReadRaw([sgm_folder 'sgm_tissue.raw'],...
    [fpj_para.DetectorElementCount, fpj_para.Views, img_slice_count],'float32');
sgm_bone=XuReadRaw([sgm_folder 'sgm_bone.raw'],...
    [fpj_para.DetectorElementCount, fpj_para.Views, img_slice_count],'float32');
WriteRawWithDim([sgm_folder 'sgm_tb'],sgm_tissue.*sgm_bone);
WriteRawWithDim([sgm_folder 'sgm_bb'],sgm_bone.^2);

delete([sgm_folder 'sgm_tissue.raw']);
delete([sgm_folder 'sgm_bone.raw']);
status=1;