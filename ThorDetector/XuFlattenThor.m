function output_image = XuFlattenThor(input_prj_file, input_air_file,prj_frame_num,air_frame_num,s_mode)

image_to_be_corrected=XuReadThorEviWithCrop(input_prj_file,prj_frame_num);
image_flat_field=XuReadThorEviWithCrop(input_air_file,air_frame_num);
switch(lower(s_mode))
    case('pulsedfluoro')
        image_to_be_corrected = XuPickFramesPulsedFluoro(image_to_be_corrected);
        image_flat_field = XuPickFramesPulsedFluoro(image_flat_field);
    case('fluoro')
        image_to_be_corrected = XuPickFrames(image_to_be_corrected);
        image_flat_field = XuPickFrames(image_flat_field);
    case('radiol')
        image_to_be_corrected = XuPickFramesRadiog(image_to_be_corrected);
        image_flat_field = XuPickFramesRadiog(image_flat_field);
    otherwise
        disp('unknown mode.');
        exit();
end

output_image = XuThorGainCorrection(image_to_be_corrected,image_flat_field,[138:229],[1:64]);