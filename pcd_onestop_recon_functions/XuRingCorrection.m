function status = XuRingCorrection(config_rc_name)

status =0;

rc_para = XuReadJsonc(config_rc_name);
%%
img_dim = rc_para.ImageDimension;
img_slice_count = rc_para.SliceCount;
img_prefix = rc_para.InputPrefix;

%%

D=dir([rc_para.InputFolder ...
    '/*' img_prefix '*.raw']);

fprintf('**Please confirm: %d raw data files are to be processed:\n',length(D));
for idx=1:length(D)
    disp(['File #' num2str(idx) ':' rc_para.InputFolder, '/' D(idx).name]);
end
fprintf('******************************\n');
pause(0.5);

for file_idx =1:length(D)
    
    filename_origin = D(file_idx).name;
    
    image_temp = XuReadRaw([rc_para.InputFolder '\'...
        filename_origin], [img_dim img_dim img_slice_count]);
    
    
    filename_rc = strrep(filename_origin,...
        char(rc_para.OutputFileReplace(1)),...
        char(rc_para.OutputFileReplace(2)));
    
    filename_rc=strrep(filename_rc,'.raw','');
    
    if rc_para.ConvertToHU
        th_l=rc_para.ReconImageThresholdVals(1)+1000;
        th_h=rc_para.ReconImageThresholdVals(2)+1000;
    else
        th_l=rc_para.ReconImageThresholdVals(1);
        th_h=rc_para.ReconImageThresholdVals(2);
    end
    
    pb = MgCmdLineProgressBar('Processing Slice#');
    
    for idx=1:img_slice_count
        
        pb.print(idx,img_slice_count)
        close all;
        img_temp=image_temp(:,:,idx);
        
        
        if rc_para.ConvertToHU
            img_temp=img_temp+1000;%add 1000 if the image is CT number
            %air_roi = (img_temp < 500);   
        end
        
        %figure();
        imshow(img_temp',[th_l th_h]);
        %img_temp = img_temp+air_roi*1000;
        
        [img_pol,mr,mtheta]=XuPolarToCartesian(img_temp,0,0);
        
        theta_interval = radtodeg(3*pi/3.5/img_dim);
        mean_filter_width = round(rc_para.MeanFilterWidth/theta_interval);
        meadian_filter_width = round(rc_para.MedianFilterWidth*2);
        
        img_soft=img_pol.*(img_pol>th_l).*(img_pol<th_h);
        
        
        
        img_soft_corrected=StripeCorrection(img_soft',meadian_filter_width,...
            rc_para.CorrectionThreshold,mean_filter_width);
        
        if isfield(rc_para,'InnerRadius') && isfield(rc_para,'InnerCorrectionThreshold')
            inner_radius = rc_para.InnerRadius;
            img_soft_corrected_inner=StripeCorrection(img_soft',meadian_filter_width,...
                rc_para.InnerCorrectionThreshold,mean_filter_width);
            left_inner_idx = round(size(img_pol,2)/2+0.5-inner_radius/0.5);
            right_inner_idx = round(size(img_pol,2)/2+0.5+inner_radius/0.5);
            
            img_soft_corrected_inner(1:left_inner_idx-1,:)=0;
            img_soft_corrected_inner(right_inner_idx+1:end,:)=0;
            img_soft_corrected(left_inner_idx:right_inner_idx,:)=0;
            img_pol_corrected=img_pol.*(img_pol<th_l)+img_pol.*(img_pol>th_h)+...
                img_soft_corrected'+img_soft_corrected_inner';
            
        else
            img_pol_corrected=img_pol.*(img_pol<th_l)+img_pol.*(img_pol>th_h)+img_soft_corrected';
        end
        img_corr=CartesianToPolar(img_pol_corrected,mr,mtheta,img_dim,0,0);
        
        %img_corr = img_corr-air_roi*1000;
         pause(0.1);
        figure();
        imshow(img_corr',[th_l th_h]);
       
        
        if isfield(rc_para, 'Rotation')
            img_corr = imrotate(img_corr,rc_para.Rotation,'bilinear','crop');
        end
        
        if rc_para.ConvertToHU
            if idx==1
                WriteRaw([rc_para.OutputFolder, '\',...
                    filename_rc],img_corr-1000);
            else
                AddRaw([rc_para.OutputFolder, '\',...
                    filename_rc],img_corr-1000);
            end
        else
            if idx==1
                WriteRaw([rc_para.OutputFolder, '\',...
                    filename_rc],img_corr);
            else
                AddRaw([rc_para.OutputFolder, '\',...
                    filename_rc],img_corr);
            end
        end
    end
    
    
end

status = 1;
