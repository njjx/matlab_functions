function data_name = XuFromReconNameWithDimToDicomDataName(recon_name,s_jsonc)
% data_name = XuFromReconNameWithDimToDicomDataName(recon_name,s_jsonc)
recon_para=XuReadJsonc(s_jsonc);
sgm_name = strrep(recon_name,recon_para.OutputFileReplace(2),recon_para.OutputFileReplace(1));
ima_name = strrep(sgm_name,recon_para.RawToSgmFileReplace(2),recon_para.RawToSgmFileReplace(1));
ima_name = strrep(ima_name,recon_para.OutputFileReplace(4),'');
ima_name = strrep(ima_name,'-.raw','.ima');
data_name = char(ima_name);