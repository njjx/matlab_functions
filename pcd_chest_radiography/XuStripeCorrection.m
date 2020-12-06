function image_output=XuStripeCorrection(image_input,med_filt_width,threshold,mean_filt_width)
%image_output=StripeCorrection(image_input,med_filt_width,threshold,mean_filt_width)
%strip is along horizontal direction in imshow

data_med_filtered=image_input;
for idx=1:size(image_input,2)
    data_med_filtered(:,idx)=medfilt1(image_input(:,idx),med_filt_width);
end
data_med_diff=data_med_filtered-image_input;

data_med_diff_thresholded=data_med_diff.*(abs(data_med_diff)<threshold);

data_med_diff_thresholded_average=image_input;
for idx=1:size(image_input,1)
    data_med_diff_thresholded_average(idx,:)=...
        smooth(data_med_diff_thresholded(idx,:),mean_filt_width);
end

image_output=data_med_diff_thresholded_average+image_input;