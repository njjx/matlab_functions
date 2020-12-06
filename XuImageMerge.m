function output_image=XuImageMerge(base_image, overlay_image, display_range,color)
%output_image=XuImageMerge(base_image, overlay_image, display_range,color)
%base_image is a uint8 RGB image
%overlay_image is a float32 b&w image
%display_range is a 1 by 2 vector
%color is a 1 by 3 vector in range [0 0 0] (black) to [1 1 1] (white)

if display_range(2)-display_range(1)<=0
    error('Error range!')
end
[m,n]=size(overlay_image);
if size(overlay_image)==size(base_image(:,:,1))
    image_alpha=(overlay_image-display_range(1))/(display_range(2)-display_range(1));
    image_alpha(find(image_alpha<0))=0;
    image_alpha(find(image_alpha>1))=1;
    image_alpha=repmat(image_alpha,[1 1 3]);
    overlay_image_rgb=255*repmat(reshape(color,[1 1 3]),[m n 1]);
    output_image=uint8(image_alpha.*overlay_image_rgb+(1-image_alpha).*double(base_image));
else
    error('Error image size!')
end
