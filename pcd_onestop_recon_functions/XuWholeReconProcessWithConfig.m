function status = XuWholeReconProcessWithConfig(s_config)

paras = XuReadJsonc(s_config);

folder = paras.ConfigFolder;

if isfield(paras,'ReconOnly')
    if paras.ReconOnly
        XuModifyJsoncFile([folder paras.ConfigPreprocessing],...
            'ReconAndAverageOnly',1,...
            [folder '/config_pre_temp.jsonc']);
    else
        XuModifyJsoncFile([folder paras.ConfigPreprocessing],...
            'ReconAndAverageOnly',0,...
            [folder '/config_pre_temp.jsonc']);
    end
    XuOneStopRecon([folder paras.ConfigFbp], [folder '/config_pre_temp.jsonc']);
else
    XuOneStopRecon([folder paras.ConfigFbp], [folder paras.ConfigPreprocessing]);
end



if paras.BoneCorrection
    XuOneStopBoneCorr([folder paras.ConfigFbp],[folder paras.ConfigFpj],...
        [folder paras.ConfigBoneCorrection],[folder paras.ConfigPreprocessing]);
end

if paras.RingCorrection
    XuOneSteopRingCorrection([folder paras.ConfigFbp],...
        [folder paras.ConfigRingCorrection]);
end

status = 1;