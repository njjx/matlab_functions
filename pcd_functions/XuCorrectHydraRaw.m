function input_image = XuCorrectHydraRaw(input_image)

dead_pixel_index=importdata('deadpixel.txt');

input_image(1286,3,:) = 1/2*(input_image(1285,3,:)+input_image(1287,3,:));
input_image(1286,4,:) = 1/4*(input_image(1285,3,:)+input_image(1287,5,:)+input_image(1285,5,:)+input_image(1287,3,:));
input_image(1287,4,:) = 1/2*(input_image(1287,3,:)+input_image(1287,5,:));
input_image(3594,62,:) = 1/2*(input_image(3593,62,:)+input_image(3595,62,:));

for idx=1:size(dead_pixel_index,1)
    RowIdx=dead_pixel_index(idx,1);
    ColIdx=dead_pixel_index(idx,2);
    input_image(RowIdx,ColIdx,:)=...
        (input_image(RowIdx+1,ColIdx,:)+input_image(RowIdx-1,ColIdx,:)+...
        input_image(RowIdx,ColIdx+1,:)+input_image(RowIdx,ColIdx-1,:))/4;
end

