function output = XuReadThorEviWithCropSplitImage(file_name,frame_num,bad_pixel_correct_or_not)

if nargin ==2
    bad_pixel_correct_or_not=1;
else
end

crop_idx = XuReadHydraCrop(file_name);
width = crop_idx(3)-crop_idx(1)-1;
height = crop_idx(4)-crop_idx(2)-1;

output = zeros(1024,512,frame_num);

temp = XuReadRawWithHeaderAndGap(file_name,...
    [width height frame_num],3264,192,'uint16');

output(crop_idx(1)+1:crop_idx(3)-1,crop_idx(2)+1:crop_idx(4)-1,:)=temp;


if bad_pixel_correct_or_not
    output = MgThorBadPixelCorrNoTranspose(output);
end