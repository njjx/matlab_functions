function sgm_name = XuGenSgmName(file_name, s_jsonc)
%XuGenSgmName(file_name, s_jsonc)

recon_para = XuReadJsonc(s_jsonc);
raw_to_sgm_sub=recon_para.RawToSgmFileReplace;
if isfield(recon_para,'RawToSgmFilePrefix')
    raw_to_sgm_pre = recon_para.RawToSgmFilePrefix;
end
if ~isempty(findstr(file_name,char(raw_to_sgm_sub(1))))
    sgm_name=strrep(file_name,char(raw_to_sgm_sub(1)),...
        char(raw_to_sgm_sub(2)));
    sgm_name=strrep(sgm_name,'.EVI','');%delete suffix
    sgm_name=strrep(sgm_name,'.evi','');%delete suffix
    
    if isfield(recon_para,'RawToSgmFilePrefix')
        sgm_name = [raw_to_sgm_pre sgm_name];
    end
    
else
    error(['No string to substitute!']);
    exit();
end