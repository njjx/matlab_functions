function status = XuScanningBeamGetMultiContrast_ver2(s_jsonc_file)

status =0;
%===============================================================================
% Read config file and prepare parameters
%===============================================================================
js = MgReadJsoncFile(s_jsonc_file);

%% Read Roi position
roi_rows = js.ImageRoi(1):js.ImageRoi(2);
roi_cols = js.ImageRoi(3):js.ImageRoi(4);



%===============================================================================
% Read phase stepping data to get I0(x,y), epsilon(x,y) and phi(x,y)
%===============================================================================

order = 1; % only considers 1 cos(phi) and sin(phi)
coefs = XuCalculatePSForScanning_ver2(js.PSFolder,roi_rows, roi_cols,order);

%===============================================================================
% Read scanning beam air and obj data
%===============================================================================


% air
fprintf('Preparing air file %s...\n',js.AirFilename);
air = MgReadRawFile(js.AirFilename, 768, 1024, js.FrameNumAir, 2048, 0, 'uint16');
%correction of some wrong frames
for frame_idx = 1:js.FrameNumAir
    temp = air(:,:,frame_idx);
    first_column_value = temp(:,1);
    shift_idx=sum(first_column_value>10000);
    air(:,:,frame_idx )= circshift(temp,[-shift_idx,0]);
end
air = mean(air, 3);
air = air(roi_rows, roi_cols, :);

% obj
fprintf('Preparing obj file %s...\n',js.PrjFilename);
obj = MgReadRawFile(js.PrjFilename, 768, 1024, js.FrameNumObj, 2048, 0, 'uint16');
%corection of some wrong frames
for frame_idx = 1:js.FrameNumObj
    temp = obj(:,:,frame_idx);
    first_column_value = temp(:,1);
    shift_idx=sum(first_column_value>10000);
    obj(:,:,frame_idx )= circshift(temp,[-shift_idx,0]);
end

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

%%
coefs_3D = reshape(coefs,[size(coefs,1),size(coefs,2),1,size(coefs,3)]);
coefs_3D = repmat(coefs_3D,[1 1 js.FrameNumObj,1]);

%===============================================================================
% Process data and do the calculation
%===============================================================================
% align images

if length(js.MagnificationRatio)==1
    js.MagnificationRatio(2) = js.MagnificationRatio;
    js.MagnificationRatio(3) = 1;
end

mag_ratio = linspace(js.MagnificationRatio(1),js.MagnificationRatio(2),js.MagnificationRatio(3));

for mag_idx = 1:js.MagnificationRatio(3)
    
    mag_idx
    
    % distance between frames in detector plane [unit: pixel]
    
    shiftInterval = js.MoveSpeed / js.FrameRate * mag_ratio(mag_idx) / js.DetectorPixelSize;
    if isfield(js,'RoundShiftIntervalToInteger')
        if(js.RoundShiftIntervalToInteger == 1)
            shiftInterval = round(shiftInterval);
        end
    end
    x_shift_interval_vec = zeros(1, js.FrameNumObj);
    y_shift_interval_vec = js.MoveDirection*(0:js.FrameNumObj-1)*shiftInterval;
    
    fprintf('Align air and obj ...\n');
    air_stack = MgAlignStackWithShift(air, x_shift_interval_vec, y_shift_interval_vec);
    %second argument is shift along the long dimention of the detector, usually is zero
    %Third arfument is shift along the short dimention of the detector.
    %If the object is moving from bottom to top, number is positive.
    %If the object is moving from top to bottom, number is negative.
    
    
    obj_stack = MgAlignStackWithShift(obj, x_shift_interval_vec, y_shift_interval_vec);
    
    coefs_stack = zeros([size(obj_stack),size(coefs_3D,4)]);
    
    for idx = 1:size(coefs_3D,4)
        coefs_stack(:,:,:,idx) = MgAlignStackWithShift(coefs_3D(:,:,:,idx), x_shift_interval_vec, y_shift_interval_vec);
    end
    
    % calculate results
    fprintf('Calculating results ...\n');
    img_sol_obj = XuDpcMultiContrastScanModeNonUniform_ver4(obj_stack, coefs_stack);
    img_sol_air = XuDpcMultiContrastScanModeNonUniform_ver4(air_stack, coefs_stack);
    
    img_sol_obj = XuSolRealToComplex(img_sol_obj);
    img_sol_air = XuSolRealToComplex(img_sol_air);
    %% subtract air
    
    
    
    img_absorp = -log(abs(img_sol_obj(:,:,1))./abs(img_sol_air(:,:,1)));
    img_dark = -log(abs(img_sol_obj(:,:,2))./abs(img_sol_air(:,:,2)));
    img_dark = img_dark-img_absorp;
    img_phase = angle(img_sol_obj(:,:,2))-angle(img_sol_air(:,:,2));
    
    img_absorp = flipud(img_absorp);
    img_dark = flipud(img_dark);
    img_phase = flipud(img_phase);
%     figure();
%     imshow(abs(img_sol_air(:,:,2)),[]);
%     figure();
%     imshow(abs(img_sol_obj(:,:,2)),[]);   
%     figure();
%     imshow(img_phase,[]);   
    
    
    %% save to files
    %===============================================================================
    fprintf('Saving to files \n');
    MgMkdir(js.OutputFolder, false);

    MgWriteTiff(sprintf('%s/%sabsorp.tif', js.OutputFolder, js.OutputFilePrefix), img_absorp);
    MgWriteTiff(sprintf('%s/%sdark.tif', js.OutputFolder, js.OutputFilePrefix), img_dark);
    MgWriteTiff(sprintf('%s/%sphase.tif', js.OutputFolder, js.OutputFilePrefix), img_phase);
    
    if mag_idx==1
        
        length_img = size(img_absorp,1);
        
        s_size = ['-' num2str(size(img_absorp,2)) '-' num2str(length_img) '-' num2str(js.MagnificationRatio(3)) ];
        
        XuWriteRaw(sprintf('%s/%sabsorp%s', js.OutputFolder, js.OutputFilePrefix,s_size), img_absorp');
        XuWriteRaw(sprintf('%s/%sdark%s', js.OutputFolder, js.OutputFilePrefix,s_size), img_dark');
        XuWriteRaw(sprintf('%s/%sphase%s', js.OutputFolder, js.OutputFilePrefix,s_size), img_phase');
    else
        img_absorp = imresize(img_absorp,[length_img size(img_absorp,2) ],'box');
        img_dark = imresize(img_dark,[length_img size(img_dark,2) ],'box');
        img_phase = imresize(img_phase,[length_img size(img_phase,2) ],'box');
        
        XuAddRaw(sprintf('%s/%sabsorp%s', js.OutputFolder, js.OutputFilePrefix,s_size), img_absorp');
        XuAddRaw(sprintf('%s/%sdark%s', js.OutputFolder, js.OutputFilePrefix,s_size), img_dark');
        XuAddRaw(sprintf('%s/%sphase%s', js.OutputFolder, js.OutputFilePrefix,s_size), img_phase');
        
    end
end

status =1;
end