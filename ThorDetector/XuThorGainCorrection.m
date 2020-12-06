function image_corrected = XuThorGainCorrection (image_to_be_corrected, image_flat_field,roi_x,roi_y)

if nargin==2
    roi_x=393:628;
    roi_y=100:220;
else
end

image_to_be_corrected_ave=mean(image_to_be_corrected,3);
image_flat_field_ave=mean(image_flat_field,3);

image_flat_field_val=mean2(image_flat_field_ave(roi_x,roi_y));
corr_factor=image_flat_field_val./image_flat_field_ave;
corr_factor(find(corr_factor>5))=1;

image_corrected=image_to_be_corrected_ave.*corr_factor;%make a correction