function output_image = XuCorrectHydraRaw(input_image)

dead_pixel_index=importdata('deadpixel.txt');

image_temp=input_image;
image_temp(1286,3) = 1/2*(input_image(1285,3)+input_image(1287,3));
image_temp(1286,4) = 1/4*(input_image(1285,3)+input_image(1287,5)+input_image(1285,5)+input_image(1287,3));
image_temp(1287,4) = 1/2*(input_image(1287,3)+input_image(1287,5));
image_temp(3594,62) = 1/2*(input_image(3593,62)+input_image(3595,62));

for idx=1:size(dead_pixel_index,1)
    RowIdx=dead_pixel_index(idx,1);
    ColIdx=dead_pixel_index(idx,2);
    image_temp(RowIdx,ColIdx)=...
        (image_temp(RowIdx+1,ColIdx)+image_temp(RowIdx-1,ColIdx)+...
        image_temp(RowIdx,ColIdx+1)+image_temp(RowIdx,ColIdx-1))/4;
end
output_image = image_temp;
