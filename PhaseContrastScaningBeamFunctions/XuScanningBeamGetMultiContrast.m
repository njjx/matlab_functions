function status = XuScanningBeamGetMultiContrast(s_jsonc_file)

status =0;
%===============================================================================
% Read config file and prepare parameters
%===============================================================================
js = MgReadJsoncFile(s_jsonc_file);

%% Read Roi position
roi_rows = js.ImageRoi(1):js.ImageRoi(2);
roi_cols = js.ImageRoi(3):js.ImageRoi(4);

% distance between frames in detector plane [unit: pixel]
shiftInterval = js.MoveSpeed / js.FrameRate * js.MagnificationRatio / js.DetectorPixelSize;

%===============================================================================
% Read phase stepping data to get I0(x,y), epsilon(x,y) and phi(x,y)
%===============================================================================

[I0,img_eps,img_phi] = XuCalculatePSForScanning(js.PSFolder);
I0 = I0(roi_rows, roi_cols);
img_eps = img_eps(roi_rows, roi_cols);
img_phi = img_phi(roi_rows, roi_cols);


%===============================================================================
% Read scanning beam air and obj data
%===============================================================================

% air
fprintf('Preparing air file %s...\n',js.AirFilename);

air = MgReadRawFile(js.AirFilename, 768, 1024, js.FrameNumAir, 2048, 0, 'uint16');

%corection of some wrong frames
for idx = 1:js.FrameNumAir
    temp = air(:,:,idx);
    first_column_value = temp(:,1);
    shift_idx=sum(first_column_value>10000);
    air(:,:,idx )= circshift(temp,[-shift_idx,0]);
end

air = mean(air, 3);
air = air(roi_rows, roi_cols, :);

% obj
fprintf('Preparing obj file %s...\n',js.PrjFilename);

obj = MgReadRawFile(js.PrjFilename, 768, 1024, js.FrameNumObj, 2048, 0, 'uint16');

%corection of some wrong frames
for idx = 1:js.FrameNumObj
    temp = obj(:,:,idx);
    first_column_value = temp(:,1);
    shift_idx=sum(first_column_value>10000);
    obj(:,:,idx )= circshift(temp,[-shift_idx,0]);
end

obj = obj(roi_rows, roi_cols, js.FrameStartIdxObj:end);%discard the first several frames which may be erroneous
js.FrameNumObj = js.FrameNumObj-js.FrameStartIdxObj+1;
%Change frame num obj to the correct number considering first several
%frames are discarded


air = repmat(air, 1, 1, js.FrameNumObj);

%%
I0_shift = repmat(I0, 1, 1, js.FrameNumObj);
eps_shift = repmat(img_eps, 1, 1, js.FrameNumObj);
phi_shift = repmat(img_phi, 1, 1, js.FrameNumObj);
%===============================================================================
% Process data and do the calculation
%===============================================================================
% align images

x_shift_interval_vec = zeros(1, js.FrameNumObj);
y_shift_interval_vec = js.MoveDirection*(0:js.FrameNumObj-1)*shiftInterval;

fprintf('Align air and obj ...\n');
air = MgAlignStackWithShift(air, x_shift_interval_vec, y_shift_interval_vec);
%second argument is shift along the long dimention of the detector, usually is zero
%Third arfument is shift along the short dimention of the detector. 
%If the object is moving from bottom to top, number is positive.
%If the object is moving from top to bottom, number is negative.


obj = MgAlignStackWithShift(obj, x_shift_interval_vec, y_shift_interval_vec);
I0_shift = MgAlignStackWithShift(I0_shift, x_shift_interval_vec, y_shift_interval_vec);
eps_shift = MgAlignStackWithShift(eps_shift, x_shift_interval_vec, y_shift_interval_vec);
phi_cos_shift = MgAlignStackWithShift(cos(phi_shift), x_shift_interval_vec, y_shift_interval_vec);
phi_sin_shift = MgAlignStackWithShift(sin(phi_shift), x_shift_interval_vec, y_shift_interval_vec);

% calculate results
fprintf('Calculating results ...\n');
[img_absorp_obj, img_dark_obj, img_phase_obj] = XuDpcMultiContrastScanModeNonUniform_ver2(obj, I0_shift,eps_shift,phi_cos_shift,phi_sin_shift);
[img_absorp_air, img_dark_air, img_phase_air] = XuDpcMultiContrastScanModeNonUniform_ver2(air, I0_shift,eps_shift,phi_cos_shift,phi_sin_shift);
%% subtract air

img_absorp = img_absorp_obj-img_absorp_air;
img_dark = img_dark_obj-img_dark_air;
img_phase = img_phase_obj-img_phase_air;

img_absorp = flipud(img_absorp);
img_dark = flipud(img_dark);
img_phase = flipud(img_phase);
%% save to files
%===============================================================================
fprintf('Saving to files \n');
MgMkdir(js.OutputFolder, false);
MgWriteTiff(sprintf('%s/%sabsorp.tif', js.OutputFolder, js.OutputFilePrefix), img_absorp);
MgWriteTiff(sprintf('%s/%sdark.tif', js.OutputFolder, js.OutputFilePrefix), img_dark);
MgWriteTiff(sprintf('%s/%sphase.tif', js.OutputFolder, js.OutputFilePrefix), img_phase);

XuWriteRawWithDim(sprintf('%s/%sabsorp', js.OutputFolder, js.OutputFilePrefix), img_absorp');
XuWriteRawWithDim(sprintf('%s/%sdark', js.OutputFolder, js.OutputFilePrefix), img_dark');
XuWriteRawWithDim(sprintf('%s/%sphase', js.OutputFolder, js.OutputFilePrefix), img_phase');

status =1;
end