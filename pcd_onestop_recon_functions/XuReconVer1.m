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
    if isfield(para,'AllSweepRotation')
        image_rotation = image_rotation+para.AllSweepRotation;
    end
end



%% change preprocessing parameters
mkdir('configs/temp_config/object');
para_preprocessing = XuReadJsonc('configs/object/config_preprocessing.jsonc');
para_preprocessing.RawDataPrjFolder = ['./data/' s_date '/' data_foler  '/'];
para_preprocessing.RawDataBkgFolder = ['./data/' s_date '/air/'];
para_preprocessing.RawDataBkgName = '1_te.evi';
para_preprocessing.RawDataPrjName = '*_te.evi';
para_preprocessing = XuStructPassVal(para,para_preprocessing);

XuStructToJsonc('configs/temp_config/object/config_preprocessing.jsonc',para_preprocessing);
% This is a histortical issue. field "SgmOffset" should be "SgmGlobalShift"
% Therefore, instead of passing the parameters in the struct, direct judge
% whether we have the sgm_offset variable. 
if exist('sgm_offset','var')
    XuModifyJsoncFile('configs/temp_config/object/config_preprocessing.jsonc',...
        'SgmGlobalShift',sgm_offset);
end

%% change the recon parameters
para_fbp = XuReadJsonc('configs/object/config_fbp.jsonc');
para_fbp.InputDir = ['./sgm/' s_date '/' data_foler, '/te'];
para_fbp.OutputDir = ['./rec/' s_date '/'  data_foler, '/te'];
para_fbp.PMatrixFile = ['paras_and_pmatrix/' s_date '/pmatrix_file.jsonc'];
para_fbp.SDDFile = ['paras_and_pmatrix/' s_date '/sdd_file.jsonc'];
para_fbp.SIDFile = ['paras_and_pmatrix/' s_date '/sid_file.jsonc'];
para_fbp.DetectorOffCenterFile = ['paras_and_pmatrix/' s_date '/offcenter_file.jsonc'];
para_fbp.ScanAngleFile = ['paras_and_pmatrix/' s_date '/scan_angle.jsonc'];
para_fbp.SwingAngleFile = ['paras_and_pmatrix/' s_date '/delta_theta_file.jsonc'];
para_fbp = XuStructPassVal(para,para_fbp);
XuStructToJsonc('configs/temp_config/object/config_fbp.jsonc',para_fbp);

%The reason we do not directly pass the image rotation to para_fbp is
%because of the AllSweepRotation field in the multi-sweep protocol. 
if exist('image_rotation','var')
    XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
        'ImageRotation',image_rotation(1));
end

%% judge whether the scan is a multi-sweep one
% if so, the folder containing the pmatrix values will change
% the input raw data folder will also change
if isfield(para, 'MultiSweepIdx')
    if para.MultiSweepIdx>0
        sweep_s = ['sweep_' num2str(para.MultiSweepIdx)];
        
        XuModifyJsoncFile('configs/temp_config/object/config_preprocessing.jsonc',...
            'RawDataPrjFolder',['./data/' s_date '/' data_foler '/'  sweep_s,   '/']);
        
        para_fbp = XuReadJsonc('configs/temp_config/object/config_fbp.jsonc');
        para_fbp.InputDir = ['./sgm/' s_date '/' data_foler '/'  sweep_s, '/te'];
        para_fbp.OutputDir = ['./rec/' s_date '/'  data_foler '/'  sweep_s, '/te'];
        para_fbp.PMatrixFile = ['paras_and_pmatrix/' s_date '/' sweep_s  '/pmatrix_file.jsonc'];
        para_fbp.SDDFile = ['paras_and_pmatrix/' s_date  '/' sweep_s  '/sdd_file.jsonc'];
        para_fbp.SIDFile = ['paras_and_pmatrix/' s_date  '/' sweep_s  '/sid_file.jsonc'];
        para_fbp.DetectorOffCenterFile = ['paras_and_pmatrix/' s_date  '/' sweep_s  '/offcenter_file.jsonc'];
        para_fbp.ScanAngleFile = ['paras_and_pmatrix/' s_date  '/' sweep_s  '/scan_angle.jsonc'];
        para_fbp.SwingAngleFile = ['paras_and_pmatrix/' s_date  '/' sweep_s  '/delta_theta_file.jsonc'];

        if isfield(para,'TotalScanAngle')
            para_fbp.TotalScanAngle = para.TotalScanAngle(para.MultiSweepIdx);
        end
        para_fbp.SinogramHeight = para.SinogramHeight(para.MultiSweepIdx);
        para_fbp.Views = para.Views(para.MultiSweepIdx);
        
        if exist('image_rotation','var')
            para_fbp.ImageRotation = image_rotation(para.MultiSweepIdx);
        end
        XuStructToJsonc('configs/temp_config/object/config_fbp.jsonc',para_fbp); 
    end
end
%% option not to apply the geometrical correction 
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
        XuModifyJsoncFile('configs/temp_config/object/config_fbp.jsonc',...
            'SwingAngleFile',[]);
    end
end

%% bone correction config files
%direct copy and paste
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
%% Set the mu value for water
if isfield(para, 'WaterMu')
    XuModifyJsoncFile('configs/temp_config/object/config_one_stop_recon.jsonc',...
        'MeasuredMuVersusMuYouWant',[]);
elseif isfield(para,'MeasuredMuVersusMuYouWant')
    % if there is a field called 'MeasuredMuVersusMuYouWant', then use this
    % to modify the water mu value
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
else
    % no field like  'MeasuredMuVersusMuYouWant'or 'WaterMu'
    % use default values for the 7s dyna CT scan protocol
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
%%

para_bone_corr = XuReadJsonc('configs/object/config_bone_corr.jsonc');
para_bone_corr = XuStructPassVal(para,para_bone_corr);
XuStructToJsonc('configs/temp_config/object/config_bone_corr.jsonc',para_bone_corr);

para_bone_corr = XuReadJsonc('configs/object/config_ring_correction.jsonc');
para_bone_corr = XuStructPassVal(para,para_bone_corr);
XuStructToJsonc('configs/temp_config/object/config_ring_correction.jsonc',para_bone_corr);

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