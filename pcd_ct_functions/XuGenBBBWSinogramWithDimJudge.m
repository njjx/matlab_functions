function status = XuGenBBBWSinogramWithDimJudge(s_jsonc_fpj, dim_or_not)
%status = XuGenBBBWSinogramWithDim(s_jsonc_fpj, dim_or_not)


fpj_para = XuReadJsonc (s_jsonc_fpj);
sgm_folder = fpj_para.OutputDir;
img_slice_count=fpj_para.SliceCount;
sgm_tissue=XuReadRaw([sgm_folder 'sgm_tissue.raw'],...
    [fpj_para.DetectorElementCount, fpj_para.Views, img_slice_count],'float32');
sgm_bone=XuReadRaw([sgm_folder 'sgm_bone.raw'],...
    [fpj_para.DetectorElementCount, fpj_para.Views, img_slice_count],'float32');

if dim_or_not
    WriteRawWithDim([sgm_folder 'sgm_tb'],sgm_tissue.*sgm_bone,3);
    WriteRawWithDim([sgm_folder 'sgm_bb'],sgm_bone.^2,3);
else
    WriteRaw([sgm_folder 'sgm_tb'],sgm_tissue.*sgm_bone);
    WriteRaw([sgm_folder 'sgm_bb'],sgm_bone.^2);
end

delete([sgm_folder 'sgm_tissue.raw']);
delete([sgm_folder 'sgm_bone.raw']);
status=1;