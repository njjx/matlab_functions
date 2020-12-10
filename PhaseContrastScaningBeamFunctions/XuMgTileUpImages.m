function XuMgTileUpImages(config)

distance_between_processed_frames_det_in_pixel = config.distance_between_frames_det_in_pixel * config.phaseStepCount;
frame_num = config.StackFrameCount;
%%


data_abp = XuReadRaw(sprintf('%s/absorb-300-512-%d.raw', config.folder_stack, config.StackFrameCount),[300 512 frame_num]);
data_dark = XuReadRaw(sprintf('%s/dark-300-512-%d.raw', config.folder_stack, config.StackFrameCount),[300 512 frame_num]);
data_phi = XuReadRaw(sprintf('%s/phi-300-512-%d.raw', config.folder_stack, config.StackFrameCount),[300 512 frame_num]);

img_effective_idx = 20:300;

img_total_abp = zeros(length(img_effective_idx)+ceil(distance_between_processed_frames_det_in_pixel*frame_num),512);
img_total_dark = img_total_abp;
img_total_phi = img_total_abp;
weight = img_total_abp;
pb=MgCmdLineProgressBar('Stitching images #');
for frame_idx = 1:frame_num
    pb.print(frame_idx,frame_num);
    img_roi = data_abp(img_effective_idx,:,frame_idx);
    img_temp_abp = img_total_abp;
    img_temp_dark = img_total_abp;
    img_temp_phi = img_total_abp;
    weight_temp = img_total_abp;
    for col_idx = 1:512

        img_temp_abp(:,col_idx)=interp1((0:length(img_effective_idx)+1)+distance_between_processed_frames_det_in_pixel*(frame_idx-1),...
           [0; data_abp(img_effective_idx,col_idx,frame_idx);0],1:size(img_total_abp,1),'linear',0);
       img_temp_dark(:,col_idx)=interp1((0:length(img_effective_idx)+1)+distance_between_processed_frames_det_in_pixel*(frame_idx-1),...
           [0; data_dark(img_effective_idx,col_idx,frame_idx);0],1:size(img_total_abp,1),'linear',0);
       img_temp_phi(:,col_idx)=interp1((0:length(img_effective_idx)+1)+distance_between_processed_frames_det_in_pixel*(frame_idx-1),...
           [0; data_phi(img_effective_idx,col_idx,frame_idx);0],1:size(img_total_abp,1),'linear',0);
 
       weight_temp(:,col_idx)=interp1((0:length(img_effective_idx)+1)+distance_between_processed_frames_det_in_pixel*(frame_idx-1),...
            [0,ones(1,length(img_effective_idx)),0],1:size(img_total_abp,1),'linear',0);

    end
    img_total_abp = img_total_abp+img_temp_abp;
    img_total_dark = img_total_dark+img_temp_dark;
    img_total_phi = img_total_phi+img_temp_phi;
    weight = weight+weight_temp;
end
%%
MgMkdir(config.OutputFolder, false);

img_total_abp_after_weight = img_total_abp./weight;
img_total_dark_after_weight = img_total_dark./weight;
img_total_phi_after_weight = img_total_phi./weight;

XuWriteRawWithDim(sprintf('%s/absorb',config.OutputFolder), flipud(img_total_abp_after_weight));
XuWriteRawWithDim(sprintf('%s/dark',config.OutputFolder),flipud(img_total_dark_after_weight));
XuWriteRawWithDim(sprintf('%s/phi',config.OutputFolder),flipud(img_total_phi_after_weight));


end

