function [sgm,bkg_count] = XuGenSgmFromEviFiles(s_prj,s_bkg,s_fbp_config,s_preprocessing_config)
% Generate sinogram from EVI files
% s_prj: object scan file name.
% s_bkg: air/bkg scan file name.
% s_fbp_config: fbp config file name.
% s_preprocessing_config: preprocess config file name.


js_fbp = MgReadJsoncFile(s_fbp_config);
js_preprocess = MgReadJsoncFile(s_preprocessing_config);

%check whether the config file contains the BeginFrameIdx to skip
%to skip the first serval frames. if not, set to 1
begin_obj_frame_idx=GetParaValue(js_preprocess,'BeginFrameIdx',1);
%check whether the config file contains the BeginBkgFrameIdx to skip
%to skip the first serval frames. if not, set to begin_frame_idx
begin_bkg_frame_idx = GetParaValue(js_preprocess,'BeginBkgFrameIdx',begin_obj_frame_idx);

%==========================================================
% Read EVI data
%==========================================================
% Read air/bkg EVI file data
prj_bkg = MgReadEviDataCrop(s_bkg, 5120, 64);
prj_bkg(:,:,1:begin_bkg_frame_idx-1)=[];
prj_bkg = permute(prj_bkg,[2 1 3]);

prj_bkg = mean(prj_bkg, 3);

% Read object EVI file data
prj_obj = MgReadEviDataCrop(s_prj, 5120, 64);
prj_obj(:,:,1:begin_obj_frame_idx-1)=[];
prj_obj = permute(prj_obj,[2 1 3]);

%==========================================================
% Perform bad pixel correction if required
%==========================================================
if isfield(js_preprocess, 'DeadPixelCorrection')
    if js_preprocess.DeadPixelCorrection
        prj_bkg = XuCorrectHydraRaw(prj_bkg);
        prj_obj = XuCorrectHydraRaw(prj_obj);
    end
end

%==========================================================
% Convert to post-log
%==========================================================
views = size(prj_obj, 3);
if isfield(js_preprocess, 'PostlogBinning') && js_preprocess.PostlogBinning
    %----------------------------------------------------
    % Take log and then perform binning along z direction
    %----------------------------------------------------
    sgm = log(prj_bkg ./ prj_obj);
    sgm = imresize3(sgm, [5120, js_fbp.SliceCount, views]);
else
    %----------------------------------------------------
    % Perform binning along z direction and then take log
    %----------------------------------------------------
    prj_bkg_bin = imresize(prj_bkg, [5120, js_fbp.SliceCount]);
    prj_obj_bin = imresize3(prj_obj, [5120, js_fbp.SliceCount, views]);
    
    sgm = log(prj_bkg_bin ./ prj_obj_bin);
end
sgm = permute(sgm,[1 3 2]);

sgm(isnan(sgm)) = 0;
sgm(isinf(sgm)) = 0;



%==========================================================
% bkg_count
%==========================================================
if isfield(js_preprocess, 'SinogramBoundary')
    bkg_count = mean2(prj_bkg(round(js_preprocess.SinogramBoundary(1)):round(prj_bkg(js_preprocess.SinogramBoundary(2))),:));
else
    bkg_count=0;
end

end

