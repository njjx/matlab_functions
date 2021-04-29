function status = XuReconVer1(s_recon_config)
%This function wil modify a parent config file to match the current recon
%task

para = XuReadJsonc(s_recon_config);


s_date = para.Date;
s_energy_bin = para.EnergyBin;
bool_gen_sgm = para.GenSgm;
bool_gen_le = para.GenLeImages;
data_foler = para.DataFolder;
if isfield(para,'SgmOffset')
    sgm_offset = para.SgmOffset;
end
if isfield(para,'ImageRotation')
    image_rotation = para.ImageRotation;
end



%% create data folders for that date
mkdir(['data/' s_date '/calphan']);
mkdir(['data/' s_date '/air']);
mkdir('configs/temp_config/object');
XuModifyJsoncFile('configs/object/config_preprocessing.jsonc',...
    'RawDataPrjFolder',['./data/' s_date '/' data_foler  '/'],...
    'configs/temp_config/object/config_preprocessing.jsonc');
XuModifyJsoncFile('configs/temp_config/object/config_preprocessing.jsonc',...
    'RawDataBkgFolder',['./data/' s_date '/air/']);
XuModifyJsoncFile('configs/temp_config/object/config_preprocessing.jsonc',...
    'RawDataBkgName',['1_te.evi']);
XuModifyJsoncFile('configs/temp_config/object/config_preprocessing.jsonc',...
    'RawDataPrjName',['*_te.evi']);

para_preprocessing = XuReadJsonc('configs/temp_config/object/config_preprocessing.jsonc');

para_preprocessing = XuStructPassVal(para,para_preprocessing);

XuStructToJsonc('configs/temp_config/object/config_preprocessing.jsonc',para_preprocessing);

if exist('sgm_offset','var')
    XuModifyJsoncFile('configs/temp_config/object/config_preprocessing.jsonc',...
        'SgmGlobalShift',sgm_offset);
end
% if isfield(para,'DeleteImagesAfterAverage')
%     XuModifyJsoncFile('configs/temp_config/object/config_preprocessing.jsonc',...
%         'DeleteOriginalReconFilesAfterAverage',para.DeleteImagesAfterAverage);
% end

%% change the recon parameters
% including the folder for the pmatrix
XuModifyJsoncFile('configs/object/config_fbp.jsonc',...
    'InputDir',['./sgm/' s_date '/' data_foler, '/te'],...
    'configs/temp_config/object/config_fbp.jsonc');
XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
    'OutputDir',['./rec/' s_date '/'  data_foler, '/te']);
XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
    'PMatrixFile',['paras_and_pmatrix/' s_date '/pmatrix_file.jsonc']);
XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
    'SDDFile',['paras_and_pmatrix/' s_date '/sdd_file.jsonc']);
XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
    'SIDFile',['paras_and_pmatrix/' s_date '/sid_file.jsonc']);
XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
    'DetectorOffCenterFile',['paras_and_pmatrix/' s_date '/offcenter_file.jsonc']);
XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
    'ScanAngleFile',['paras_and_pmatrix/' s_date '/scan_angle.jsonc']);

para_fbp = XuReadJsonc('configs/temp_config/object/config_fbp.jsonc');

para_fbp = XuStructPassVal(para,para_fbp);

XuStructToJsonc('configs/temp_config/object/config_fbp.jsonc',para_fbp);


if exist('image_rotation','var')
    XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
        'ImageRotation',image_rotation(1));
end

%% judge whether the scan is a multi-sweep one
% if so, the folder containing the pmatrix values will change
if isfield(para, 'MultiSweepIdx')
    if para.MultiSweepIdx>0
        sweep_s = ['sweep_' num2str(para.MultiSweepIdx)];
        
        XuModifyJsoncFile('configs/temp_config/object/config_preprocessing.jsonc',...
    'RawDataPrjFolder',['./data/' s_date '/' data_foler '/'  sweep_s,   '/']);
        
        XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
            'InputDir',['./sgm/' s_date '/' data_foler '/'  sweep_s, '/te']);
        XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
            'OutputDir',['./rec/' s_date '/'  data_foler '/'  sweep_s, '/te']);
        
        sweep_mod_num = length(para.TotalScanAngle);
        
        sweep_s_pm = ['sweep_' num2str(XuMod(para.MultiSweepIdx,2))];
        XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
            'PMatrixFile',['paras_and_pmatrix/' s_date '/' sweep_s_pm '/pmatrix_file.jsonc']);
        XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
            'SDDFile',['paras_and_pmatrix/' s_date '/' sweep_s_pm '/sdd_file.jsonc']);
        XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
            'SIDFile',['paras_and_pmatrix/' s_date '/' sweep_s_pm '/sid_file.jsonc']);
        XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
            'DetectorOffCenterFile',['paras_and_pmatrix/' s_date '/' sweep_s_pm '/offcenter_file.jsonc']);
        XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
            'ScanAngleFile',['paras_and_pmatrix/' s_date '/' sweep_s_pm '/scan_angle.jsonc']);
        
        XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
            'TotalScanAngle',para.TotalScanAngle(XuMod(para.MultiSweepIdx,sweep_mod_num)));
        
        if exist('image_rotation','var')
            XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
                'ImageRotation',image_rotation(XuMod(para.MultiSweepIdx,sweep_mod_num)));
        end

        
    end
end
%%
if isfield(para,'GeometricCorrection')
    if ~para.GeometricCorrection
        XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
            'PMatrixFile',[]);
        XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
            'SDDFile',[]);
        XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
            'SIDFile',[]);
        XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
            'DetectorOffCenterFile',[]);
        XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
            'ScanAngleFile',[]);
    end
end

%% bone correction config files
XuModifyJsoncFile('configs/object/config_bone_corr.jsonc',...
    [],[],'configs/temp_config/object/config_bone_corr.jsonc');
XuModifyJsoncFile('configs/object/config_ring_correction.jsonc',...
    [],[],'configs/temp_config/object/config_ring_correction.jsonc');
XuModifyJsoncFile('configs/object/config_fpj.jsonc',...
    [],[],'configs/temp_config/object/config_fpj.jsonc');

XuModifyJsoncFile('configs/object/config_one_stop_recon.jsonc',...
    'ConfigFolder','configs/temp_config/object',...
    'configs/temp_config/object/config_one_stop_recon.jsonc');
XuModifyJsoncFile('configs/temp_config/object/config_one_stop_recon.jsonc',...
    'ReconOnly',~bool_gen_sgm);

%% whether le image will be generated
switch lower(s_energy_bin)
    case 'te'
        ;
    case 'he'
        ;
    case 'le'
        XuModifyJsoncFile('configs/temp_config/object/config_one_stop_recon.jsonc',...
            'AlreadyHaveLEImages',~bool_gen_le);
        XuModifyJsoncFile('configs/temp_config/object/config_one_stop_recon.jsonc',...
            'AlreadyHaveAirLEImages',~bool_gen_le);
    otherwise
        disp('energy bin can only be te, he, or le.');
        exit();
end
%% normalize HU value

if isfield(para,'MeasuredMuVersusMuYouWant')
    switch lower(s_energy_bin)
        case 'te'
            XuModifyJsoncFile('configs/temp_config/object/config_one_stop_recon.jsonc',...
                'MeasuredMuVersusMuYouWant',para.MeasuredMuVersusMuYouWant(1:2));
        case 'he'
            XuModifyJsoncFile('configs/temp_config/object/config_one_stop_recon.jsonc',...
                'MeasuredMuVersusMuYouWant',para.MeasuredMuVersusMuYouWant(3:4));
        case 'le'
            XuModifyJsoncFile('configs/temp_config/object/config_one_stop_recon.jsonc',...
                'MeasuredMuVersusMuYouWant',para.MeasuredMuVersusMuYouWant(5:6));
        otherwise
            disp('energy bin can only be te, he, or le.');
            exit();
    end
else % default values for the 7s dyna CT scan protocol
    switch lower(s_energy_bin)
        case 'te'
            XuModifyJsoncFile('configs/temp_config/object/config_one_stop_recon.jsonc',...
                'MeasuredMuVersusMuYouWant',[-42 50]);
        case 'he'
            XuModifyJsoncFile('configs/temp_config/object/config_one_stop_recon.jsonc',...
                'MeasuredMuVersusMuYouWant',[-75 50]);
            if strcmp(para.Protocol,'7sDynamicCT-SinglePixel-th80')
                XuModifyJsoncFile('configs/temp_config/object/config_one_stop_recon.jsonc',...
                    'MeasuredMuVersusMuYouWant',[0 0]);
            end
        case 'le'
            XuModifyJsoncFile('configs/temp_config/object/config_one_stop_recon.jsonc',...
                'MeasuredMuVersusMuYouWant',[-12 50]);
            if strcmp(para.Protocol,'7sDynamicCT-SinglePixel-th80')
                XuModifyJsoncFile('configs/temp_config/object/config_one_stop_recon.jsonc',...
                    'MeasuredMuVersusMuYouWant',[0 0]);
            end
        otherwise
            disp('energy bin can only be te, he, or le.');
            exit();
    end
end

XuModifyJsoncFile('configs/temp_config/object/config_one_stop_recon.jsonc',...
    'EnergyBin',s_energy_bin);
%% whether bone and ring corrections are performed

if isfield(para,'BoneCorrection')
    XuModifyJsoncFile('configs/temp_config/object/config_one_stop_recon.jsonc',...
    'BoneCorrection',para.BoneCorrection);
end

if isfield(para,'RingCorrection')
    XuModifyJsoncFile('configs/temp_config/object/config_one_stop_recon.jsonc',...
    'RingCorrection',para.RingCorrection);
end

%%

XuWholeReconProcessWithConfigDualEnergy('configs/temp_config/object/config_one_stop_recon.jsonc');

status =1;