function abs_corr=XuThorPanelInterpWithIdx(abs,idx_up,idx_down)

height=size(abs,3);
abs_corr=abs;

upper_bound=height/2;
lower_bound=height/2+1;
abs_corr(idx_up,:,1:upper_bound)=2/3*abs(idx_up-1,:,1:upper_bound)+1/3*abs(idx_up+2,:,1:upper_bound);
abs_corr(idx_up+1,:,1:upper_bound)=1/3*abs(idx_up-1,:,1:upper_bound)+2/3*abs(idx_up+2,:,1:upper_bound);
abs_corr(idx_up+128,:,1:upper_bound)=2/3*abs(idx_up+128-1,:,1:upper_bound)+1/3*abs(idx_up+128+2,:,1:upper_bound);
abs_corr(idx_up+128+1,:,1:upper_bound)=1/3*abs(idx_up+128-1,:,1:upper_bound)+2/3*abs(idx_up+128+2,:,1:upper_bound);

abs_corr(idx_down,:,lower_bound:end)=2/3*abs(idx_down-1,:,lower_bound:end)+1/3*abs(idx_down+2,:,lower_bound:end);
abs_corr(idx_down+1,:,lower_bound:end)=1/3*abs(idx_down-1,:,lower_bound:end)+2/3*abs(idx_down+2,:,lower_bound:end);
abs_corr(idx_down+128,:,lower_bound:end)=2/3*abs(idx_down+127,:,lower_bound:end)+1/3*abs(idx_down+130,:,lower_bound:end);
abs_corr(idx_down+129,:,lower_bound:end)=1/3*abs(idx_down+127,:,lower_bound:end)+2/3*abs(idx_down+130,:,lower_bound:end);