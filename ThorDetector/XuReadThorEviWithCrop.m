function output = XuReadThorEviWithCrop(file_name,frame_num,bad_pixel_correct_or_not)

if nargin ==2
    bad_pixel_correct_or_not=1;
else
end

crop_idx = XuReadHydraCrop(file_name);
width = crop_idx(3)-crop_idx(1)-1;
height = crop_idx(4)-crop_idx(2)-1;

output = zeros(2048,256,frame_num);

temp = XuReadRawWithHeaderAndGap(file_name,...
    [width height frame_num],3264,192,'uint16');

output(crop_idx(1)+1:crop_idx(3)-1,crop_idx(2)+1:crop_idx(4)-1,:)=temp;

output_reshape =  zeros(1024,512,frame_num);
output_reshape(:,1:256,:) = output(1:1024,:,:);
output_reshape(:,257:512,:) = flipud(output(1025:end,:,:));

if bad_pixel_correct_or_not
    output_reshape = XuThorBadPixelCorr(output_reshape);
end

output(1:1024,:,:)=output_reshape(:,1:256,:);
output(1025:end,:,:)=flipud(output_reshape(:,257:512,:));


output = output(crop_idx(1)+1:crop_idx(3)-1,crop_idx(2)+1:crop_idx(4)-1,:);