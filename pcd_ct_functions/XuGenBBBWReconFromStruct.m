function status = XuGenBBBWReconFromStruct(bb_tb_recon_para,bone_corr_para)

bb_tb_recon_para.InputFiles=[char(bone_corr_para.OutputFileReplace(2)),'.*.raw'];
bb_tb_recon_para.InputDir=bone_corr_para.OutputDir;
bb_tb_recon_para.OutputDir=bone_corr_para.InputDir;
bb_tb_recon_para.SinogramHeight=bb_tb_recon_para.Views;

if exist('temp_config/temp_angle_info.jsonc','file')
    bb_tb_recon_para.ScanAngleFile = 'temp_config/temp_angle_info.jsonc';
else
    %fprintf("Uniform angle assumed.\n");
end
StructToJsonc('temp_config/config_fbp_bone_corr.jsonc',bb_tb_recon_para);
!mgfbp.exe temp_config/config_fbp_bone_corr.jsonc

status=1;