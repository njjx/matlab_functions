function abs_corr=XuThorPanelInterpWithIdx(abs,idx_up,idx_down)

height=size(abs,3);
abs_corr=abs;

upper_bound=height/2;
lower_bound=height/2+1;

upper_sgm_ave = mean(mean(abs(:,:,1:upper_bound),3),2);
%plot(upper_sgm_ave);

lower_sgm_ave = mean(mean(abs(:,:,lower_bound:end),3),2);
%plot(lower_sgm_ave);

for panel_idx = 1:2
    left_idx = idx_up-1+(panel_idx-1)*128;
    right_idx = idx_up+2+(panel_idx-1)*128;
    
    pLeft = polyfit(left_idx-6:left_idx,upper_sgm_ave(left_idx-6:left_idx)',1);
    left_val = polyval(pLeft,right_idx);
    pRight = polyfit(right_idx:right_idx+6,upper_sgm_ave(right_idx:right_idx+6)',1);
    right_val = polyval(pRight,right_idx);
    
    correction = (left_val-right_val)*(126:-1:1)/126;
    
    abs_corr(right_idx:right_idx+125,:,1:upper_bound)=abs(right_idx:right_idx+125,:,1:upper_bound)+correction';
    abs_corr(left_idx+1,:,1:upper_bound)=2/3*abs_corr(left_idx,:,1:upper_bound)+1/3*abs_corr(right_idx,:,1:upper_bound);
    abs_corr(left_idx+2,:,1:upper_bound)=1/3*abs_corr(left_idx,:,1:upper_bound)+2/3*abs_corr(right_idx,:,1:upper_bound);
    
    %plot(mean(mean(abs_corr(:,:,1:upper_bound),3),2));
    
end

for panel_idx = 1:2
    left_idx = idx_down-1+(panel_idx-1)*128;
    right_idx = idx_down+2+(panel_idx-1)*128;
    
    pLeft = polyfit(left_idx-6:left_idx,lower_sgm_ave(left_idx-6:left_idx)',1);
    left_val = polyval(pLeft,right_idx);
    pRight = polyfit(right_idx:right_idx+6,lower_sgm_ave(right_idx:right_idx+6)',1);
    right_val = polyval(pRight,right_idx);
    
    correction = (left_val-right_val)*(126:-1:1)/126;
    
    abs_corr(right_idx:right_idx+125,:,lower_bound:end)=abs(right_idx:right_idx+125,:,lower_bound:end)+correction';
    abs_corr(left_idx+1,:,lower_bound:end)=2/3*abs_corr(left_idx,:,lower_bound:end)+1/3*abs_corr(right_idx,:,lower_bound:end);
    abs_corr(left_idx+2,:,lower_bound:end)=1/3*abs_corr(left_idx,:,1:upper_bound)+2/3*abs_corr(right_idx,:,lower_bound:end);
    
    %plot(mean(mean(abs_corr(:,:,lower_bound:end),3),2));
    
end