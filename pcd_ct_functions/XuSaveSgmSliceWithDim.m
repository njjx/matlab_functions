function status = XuSaveSgmSliceWithDim(sgm_name,sgm,slice_idx, s_jsonc)
%status = XuSaveSgmSliceWithDim(sgm_name,sgm_resize,slice_idx, s_jsonc)
status=0;
recon_para = XuReadJsonc(s_jsonc);
sgm_folder=recon_para.InputDir;

file_name_w_path = [sgm_folder '\' sgm_name];
file_name_w_path = [file_name_w_path '-' num2str(recon_para.SinogramWidth)...
    '-' num2str(recon_para.SinogramHeight) '-' num2str(recon_para.SliceCount)];

if slice_idx==1
    WriteRaw(file_name_w_path,sgm);
else
    AddRaw(file_name_w_path,sgm);
end
status=1;