function image_corrected = XuFliteGainCorrection (image_to_be_corrected, image_flat_field)

image_to_be_corrected_ave=mean(image_to_be_corrected,3);
image_flat_field_ave=mean(image_flat_field,3);

image_flat_field_val=mean2(image_flat_field_ave(128*6+10:128*7-10,10:110));
corr_factor=image_flat_field_val./image_flat_field_ave;
corr_factor(find(corr_factor>5))=1;

image_corrected=image_to_be_corrected_ave.*corr_factor;%make a correction