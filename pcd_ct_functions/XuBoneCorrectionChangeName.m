function corr_name = XuBoneCorrectionChangeName(file_name,s_jsonc)
%corr_name = XuBoneCorrectionChangeName(file_name,s_jsonc)

bone_corr_para=XuReadJsonc(s_jsonc);
if ~isempty(findstr(file_name,char(bone_corr_para.RecCorrectionFileReplace(1))))
    corr_name=strrep(file_name,char(bone_corr_para.RecCorrectionFileReplace(1)),...
        char(bone_corr_para.RecCorrectionFileReplace(2)));
    corr_name=strrep(corr_name,'.raw','');%delete suffix
else
    error('No string to substitute!');
end