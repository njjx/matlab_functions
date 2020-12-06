function image_merge=XuImageLogAndMergeHLGain(prj_l,prj_h,bkg_l,bkg_h)
%image_merge=ImageLogAndMergeHLGain(prj_l,prj_h,bkg_l,bkg_h)
map_l=ones(size(bkg_h));
map_h=(bkg_h<9000).*(prj_h<9000);
log_image_l=-log(prj_l./ bkg_l);
log_image_h=-log(prj_h./ bkg_h);
output_image=(log_image_h.*map_h+log_image_l.*map_l)./(map_h+map_l);
image_merge=[zeros(size(output_image)),zeros(size(output_image))];
image_merge(:,1:2:end)=output_image;
image_merge(:,2:2:end)=output_image;