function image_merge=ImageZMerge(image_input, pixel_over_lap_in_pixel)
%image_output=Imagemerge(image_input, pixel_over_lap_in_pixel)

prj_frame_num=size(image_input,3);
image_width=size(image_input,1);
image_height=size(image_input,2);
prj_log=image_input;
image_merge_height=floor(pixel_over_lap_in_pixel*(prj_frame_num));
image_merge=zeros(image_width,image_merge_height);



for row_idx=1:image_merge_height
    frame_idx_max=ceil(row_idx/pixel_over_lap_in_pixel);
    row_idx_in_frame=row_idx-(frame_idx_max-1)*pixel_over_lap_in_pixel;
    
    frame_idx=frame_idx_max;
    frame_count=0;
    while row_idx_in_frame<=60 && frame_idx>=1
        
        if row_idx_in_frame<1
            ratio_next_row=row_idx_in_frame;
            ratio_previous_row=1-ratio_next_row;
            image_merge(:,row_idx)=image_merge(:,row_idx)+...
                ratio_previous_row*prj_log(:,floor(pixel_over_lap_in_pixel),frame_idx-1)+...
                ratio_next_row*prj_log(:,1,frame_idx);
        elseif row_idx_in_frame<image_height
            row_idx_in_frame_previous=floor(row_idx_in_frame);
            ratio_next_row=row_idx_in_frame-floor(row_idx_in_frame);
            ratio_previous_row=1-ratio_next_row;
            image_merge(:,row_idx)=image_merge(:,row_idx)+...
                ratio_previous_row*prj_log(:,row_idx_in_frame_previous,frame_idx)+...
                ratio_next_row*prj_log(:,row_idx_in_frame_previous+1,frame_idx);
        elseif row_idx_in_frame==image_height
            image_merge(:,row_idx)=image_merge(:,row_idx)+prj_log(:,image_height,frame_idx);
        end
        frame_count=frame_count+1;
        frame_idx=frame_idx-1;
        row_idx_in_frame=row_idx_in_frame+pixel_over_lap_in_pixel;
    end
    image_merge(:,row_idx)=image_merge(:,row_idx)/frame_count;
end