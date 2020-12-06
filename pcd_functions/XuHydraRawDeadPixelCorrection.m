function img_output = XuHydraRawDeadPixelCorrection(img_input,frame_num)


img_output = img_input;
dead_pixel_index=importdata('deadpixel.txt');

for frameidx=1:frame_num

    image_temp=img_input(:,:,frameidx);
    image_temp(1286,3) = 1/2*(img_input(1285,3)+img_input(1287,3));
    image_temp(1286,4) = 1/4*(img_input(1285,3)+img_input(1287,5)+img_input(1285,5)+img_input(1287,3));
    image_temp(1287,4) = 1/2*(img_input(1287,3)+img_input(1287,5));
    image_temp(3594,62) = 1/2*(img_input(3593,62)+img_input(3595,62));
    
    for idx=1:size(dead_pixel_index,1)
        RowIdx=dead_pixel_index(idx,1);
        ColIdx=dead_pixel_index(idx,2);
        image_temp(RowIdx,ColIdx)=...
            (image_temp(RowIdx+1,ColIdx)+image_temp(RowIdx-1,ColIdx)+...
            image_temp(RowIdx,ColIdx+1)+image_temp(RowIdx,ColIdx-1))/4;
    end
    %image_temp(image_temp==0)=1;
    
    img_output(:,:,frameidx)=image_temp;
end