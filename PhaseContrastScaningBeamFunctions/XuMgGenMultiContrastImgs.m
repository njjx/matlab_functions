function config = XuMgGenMultiContrastImgs(config)

% last few views need to be processed 
% frame_num for tile_up_code need to be calculated
% set input & output folder in jsonc file
%%
frame_num = config.FrameNum;

prj_name = config.PrjFilename;
air_name = config.AirFilename;

%%
expo_time = 1/config.FrameRate; %s
distance_between_frames = expo_time*config.MoveSpeed;%mm at object

distance_between_frames_det = distance_between_frames*config.MagnificationRatio; %mm

distance_between_frames_det_in_pixel = ...
    distance_between_frames_det/config.DetectorPixelSize;% pixels

phaseStepCount = config.FringePeriod/distance_between_frames_det_in_pixel;
phaseStepCount = ceil(phaseStepCount);

config.distance_between_frames_det_in_pixel = distance_between_frames_det_in_pixel;
config.phaseStepCount = phaseStepCount;
%%
I0_for_cali = MgReadTiff(config.I0Filename);
mean_I0 = mean2(I0_for_cali(100:272,502:674));
cali_ratio = mean_I0./I0_for_cali;

%%
% TODO: optimize XuReadThorEviWithCropSplitImage memory usage
data_prj = XuReadThorEviWithCropSplitImage(prj_name,frame_num,1);
data_prj = data_prj.*cali_ratio';
val_z = XuMean2(data_prj);
val_z_filter = medfilt1(val_z,5);
ratio = reshape(val_z_filter./val_z,[1 1 frame_num]);
data_prj = data_prj.*ratio;



data_air = XuReadThorEviWithCropSplitImage(air_name,frame_num,1);
data_air = data_air.*cali_ratio';
val_z = XuMean2(data_air);
val_z_filter = medfilt1(val_z,5);
ratio = reshape(val_z_filter./val_z,[1 1 frame_num]);
data_air = data_air.*ratio;

data_air = mean(data_air(:,:,:),3);
data_air = repmat(data_air,[1 1 round(phaseStepCount)]);
%%

roi = 174+300:174+300+299;
pb = MgCmdLineProgressBar('Processing images #');

% tmporary folder to save image stacks
folder_stack = sprintf('%s/%s_stack_tmp', config.OutputFolder, date);
MgMkdir(folder_stack, true);

config.folder_stack = folder_stack;

data_air_shift = data_air(roi, :, :);
for ps_idx = 1:round(phaseStepCount)
    % TODO: optimize XuCircShift performance
    data_air_shift(:,:,ps_idx) = XuCircShift(data_air(roi,:,ps_idx),(ps_idx-1)*distance_between_frames_det_in_pixel);
end

frame_num_stack = numel(3:phaseStepCount:frame_num-round(phaseStepCount)+1);
config.StackFrameCount = frame_num_stack;

for idx = 3:phaseStepCount:frame_num-round(phaseStepCount)+1
    pb.print(idx, frame_num-round(phaseStepCount)+1);
    data_prj_shift = data_prj(roi,:,idx:idx+phaseStepCount-1);
    for ps_idx = 1:phaseStepCount
        data_prj_shift(:,:,ps_idx) = XuCircShift(data_prj(roi,:,idx+ps_idx-1),(ps_idx-1)*distance_between_frames_det_in_pixel);
    end
    
    [absorp, dark, phi] = XuMCbkgprj(data_air_shift(:,:,:),data_prj_shift(:,:,:));
    if idx == 3
        filename = sprintf('%s/absorb-300-512-%d', folder_stack, frame_num_stack);
        XuWriteRaw(filename,absorp);
        filename = sprintf('%s/dark-300-512-%d', folder_stack, frame_num_stack);
        XuWriteRaw(filename,dark);
        filename = sprintf('%s/phi-300-512-%d', folder_stack, frame_num_stack);
        XuWriteRaw(filename,phi);
    else
        filename = sprintf('%s/absorb-300-512-%d', folder_stack, frame_num_stack);
        XuAddRaw(filename,absorp);
        filename = sprintf('%s/dark-300-512-%d', folder_stack, frame_num_stack);
        XuAddRaw(filename,dark);
        filename = sprintf('%s/phi-300-512-%d', folder_stack, frame_num_stack);
        XuAddRaw(filename,phi);
    end
end
%%


end

