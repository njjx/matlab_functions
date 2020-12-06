function u_measured = Xu2DPamtrixGetMeasuredu(projection_image, threshold_val, overlap_idx)
%u_measured = Xu2DPamtrixGetMeasuredu(projection_image, threshold_val)
%This function is for measurement of the position of the BBs in a
%projection image

if nargin ==2
    overlap_or_not = 0;
elseif overlap_idx<=0
    overlap_or_not = 0;
else
    overlap_or_not = 1;
end


projection_image_bw = projection_image>threshold_val;
temp_s=regionprops(projection_image_bw,projection_image, 'WeightedCentroid');

detected_BBs_count = length(temp_s);

u_measured=zeros(1,detected_BBs_count);
for idx = 1:detected_BBs_count
    temp = temp_s(idx).WeightedCentroid;
    u_measured(idx) = temp(2)-1;%in cpp u idx begins with 0
end

if overlap_or_not==0
else
    overlap_idx = sort(overlap_idx);
    for idx = 1:length(overlap_idx)
        
        shift_idx = idx-1;
        
        overlap_idx_true = overlap_idx(idx)+shift_idx;
        
        overlap_position = round(u_measured(overlap_idx_true));
        
        x = (overlap_position-9:overlap_position+9)';
        y = projection_image(x);
        
        
        double_peak_flag = 0;
        
        y_diff =[0;diff(y)];
        
        for y_idx = 1:length(y)-1
            if y_diff(y_idx)<0 && y_diff(y_idx+1)>0 && y(y_idx)>threshold_val
                double_peak_flag=1;
                break;
            end
        end
        
        if double_peak_flag == 1
            f =fit(x,y,'gauss2');
            %plot(f,x,y)
            %pause(0.1);
            peak_pos_1 = f.b1-1;
            peak_pos_2 = f.b2-1;
            u_measured(overlap_idx_true) = min([peak_pos_1,peak_pos_2]);
            u_measured = [u_measured(1:overlap_idx_true) max([peak_pos_1,peak_pos_2]) u_measured(overlap_idx_true+1:end)];
        else
            
            f =fit(x,y,'gauss1');
            %plot(f,x,y);
            %pause(0.1);
            peak_pos_1 = f.b1-1;
            u_measured(overlap_idx_true) = peak_pos_1;
            u_measured = [u_measured(1:overlap_idx_true) peak_pos_1 u_measured(overlap_idx_true+1:end)];
            
        end
        
    end
end

