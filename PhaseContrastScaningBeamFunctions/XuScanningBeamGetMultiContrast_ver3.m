function status = XuScanningBeamGetMultiContrast_ver3(s_jsonc_file)
%status = XuScanningBeamGetMultiContrast_ver3(s_jsonc_file)
%This version is for integer shift intervals

status =0;
%===============================================================================
% Read config file and prepare parameters
%===============================================================================
js = MgReadJsoncFile(s_jsonc_file);

%% Read Roi position
roi_rows = js.ImageRoi(1):js.ImageRoi(2);
roi_cols = js.ImageRoi(3):js.ImageRoi(4);

%===============================================================================
% Read phase stepping data to get A0(x,y), A1(x,y), B1(x,y), etc.
%===============================================================================

order = 1; % only considers 1 cos(phi) and sin(phi)
coefs = XuCalculatePSForScanning_ver2(js.PSFolder,roi_rows, roi_cols,order);

%===============================================================================
% Read scanning beam air and obj data
%===============================================================================


% air
fprintf('Reading air file %s...\n',js.AirFilename);
air = XuReadRawFile(js.AirFilename, 768, 1024, js.FrameNumAir, 2048, 0, 'uint16');
%correction of some wrong frames
fprintf('Correcting air file ...\n');
air = XuCorrectVarianUserSync(air,js.FrameNumAir);
air = mean(air, 3);
air = air(roi_rows, roi_cols, :);

% obj
fprintf('Reading obj file %s...\n',js.PrjFilename);
obj = XuReadRawFile(js.PrjFilename, 768, 1024, js.FrameNumObj, 2048, 0, 'uint16');
%corection of some wrong frames
fprintf('Correcting obj file ...\n');
obj = XuCorrectVarianUserSync(obj,js.FrameNumObj);

% correction of tube output
if isfield(js,'AirRoi')
    roi_rows_air = js.AirRoi(1):js.AirRoi(2);
    roi_cols_air = js.AirRoi(3):js.AirRoi(4);
    obj_air_val = XuMean2(obj(roi_rows_air,roi_cols_air,:));
    obj_air_ratio = mean(obj_air_val)./obj_air_val;
    obj = obj.*reshape(obj_air_ratio,[1 1 size(obj,3)]);
elseif isfield(js,'TemporalCalibrationFile')% Read temporal calibration file
    ratio_t = XuReadJsoncField(js.TemporalCalibrationFile,'Value');
    if length(ratio_t)>=size(obj,3)
        ratio_t = ratio_t(1:size(obj,3));
    else
        ratio_t(end+1: (end+size(obj,3)-length(ratio_t))) = ratio_t(end);
    end
    obj = obj.*reshape(ratio_t,[1 1 size(obj,3)]);
end

obj = obj(roi_rows, roi_cols, js.FrameStartIdxObj:end);%discard the first several frames which may be erroneous
js.FrameNumObj = js.FrameNumObj-js.FrameStartIdxObj+1;
%Change frame num obj to the correct number considering first several
%frames are discarded
air = repmat(air, 1, 1, js.FrameNumObj);

%% For integer shift interval distances, directly shift the obj data file
fprintf('Calculating scanning beam results ...\n');
shiftInterval = js.MoveDirection * ...
    round(js.MoveSpeed / js.FrameRate * js.MagnificationRatio / js.DetectorPixelSize);
img_sol_air = XuVirtualPSIntegerInterval(air,coefs,shiftInterval);
img_sol_obj = XuVirtualPSIntegerInterval(obj,coefs,shiftInterval);


%% subtract air
img_absorp = -log(abs(img_sol_obj(:,:,1))./abs(img_sol_air(:,:,1)));
img_dark = -log(abs(img_sol_obj(:,:,2))./abs(img_sol_air(:,:,2)));
img_dark = img_dark-img_absorp;
img_phase = angle(img_sol_obj(:,:,2))-angle(img_sol_air(:,:,2));

% figure();
% imshow(-log(abs(img_sol_obj(:,:,2))./abs(img_sol_obj(:,:,1))),[0 0.3]);
% figure();
% imshow(-log(abs(img_sol_air(:,:,2))./abs(img_sol_air(:,:,1))),[0 0.3]);
figure();
imshow(img_absorp,[]);
% 
img_dark = XuStripeCorrection(img_dark',7,0.1,100);
img_dark = img_dark';
img_phase = XuStripeCorrection(img_phase',7,0.1,100);
img_phase = img_phase';
figure();
imshow(img_dark,[]);
figure();
imshow(img_phase,[]);
%% save to files
%===============================================================================
fprintf('Results are saved to %s.\n',js.OutputFolder);
MgMkdir(js.OutputFolder, false);

MgWriteTiff(sprintf('%s/%sabsorp.tif', js.OutputFolder, js.OutputFilePrefix), img_absorp);
MgWriteTiff(sprintf('%s/%sdark.tif', js.OutputFolder, js.OutputFilePrefix), img_dark);
MgWriteTiff(sprintf('%s/%sphase.tif', js.OutputFolder, js.OutputFilePrefix), img_phase);

s_size = ['-' num2str(size(img_absorp,2)) '-' num2str(size(img_absorp,1))];

XuWriteRaw(sprintf('%s/%sabsorp%s', js.OutputFolder, js.OutputFilePrefix,s_size), img_absorp');
XuWriteRaw(sprintf('%s/%sdark%s', js.OutputFolder, js.OutputFilePrefix,s_size), img_dark');
XuWriteRaw(sprintf('%s/%sphase%s', js.OutputFolder, js.OutputFilePrefix,s_size), img_phase');


status =1;
end