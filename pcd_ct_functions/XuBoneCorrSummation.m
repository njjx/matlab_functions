function img_corr = XuBoneCorrSummation(img,s_jsonc_bone_fbp,s_jsonc_bone_corr)

recon_para = XuReadJsonc(s_jsonc_bone_fbp);
bone_corr_para = XuReadJsonc(s_jsonc_bone_corr);
img_folder=recon_para.OutputDir;
img_dim=recon_para.ImageDimension;
img_slice_count=recon_para.SliceCount;

rec_tb=ReadRaw([img_folder 'rec_tb-' num2str(img_dim) '-' num2str(img_dim), '.raw'], ...
    [img_dim img_dim img_slice_count],'float32');
rec_bb=ReadRaw([img_folder 'rec_bb-' num2str(img_dim) '-' num2str(img_dim), '.raw'], ...
    [img_dim img_dim img_slice_count],'float32');

img_corr=img+bone_corr_para.BoneBoneCoef*rec_bb+bone_corr_para.BoneTissueCoef*rec_tb;
