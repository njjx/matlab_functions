function image_rgb=XuRawToRGB(image_raw,display_range,color)
%image_rgb=XuRawToRGB(image_raw,display_range,color)
%image_raw is a float32 b&w image
%display_range is a 1 by 2 vector
%color is a 1 by 3 vector in range [0 0 0] (black) to [1 1 1] (white)
if display_range(2)-display_range(1)<=0
    error('Error range!')
end
[m,n]=size(image_raw);
image_raw_scale=(image_raw-display_range(1))/(display_range(2)-display_range(1))*256;
image_rgb=zeros(m,n,3);
for idx=1:3
    image_rgb(:,:,idx)=image_raw_scale*color(idx);
end
image_rgb=uint8(image_rgb);