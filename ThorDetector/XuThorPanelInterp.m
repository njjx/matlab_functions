function abs_corr=XuThorPanelInterp(abs)

height=size(abs,3);
abs_corr=abs;

upper_bound=height/2-1;
lower_bound=height/2;
abs_corr(190,:,1:upper_bound)=2/3*abs(189,:,1:upper_bound)+1/3*abs(192,:,1:upper_bound);
abs_corr(191,:,1:upper_bound)=1/3*abs(189,:,1:upper_bound)+2/3*abs(192,:,1:upper_bound);
abs_corr(318,:,1:upper_bound)=2/3*abs(317,:,1:upper_bound)+1/3*abs(320,:,1:upper_bound);
abs_corr(319,:,1:upper_bound)=1/3*abs(317,:,1:upper_bound)+2/3*abs(320,:,1:upper_bound);

abs_corr(170,:,lower_bound:end)=2/3*abs(169,:,lower_bound:end)+1/3*abs(172,:,lower_bound:end);
abs_corr(171,:,lower_bound:end)=1/3*abs(169,:,lower_bound:end)+2/3*abs(172,:,lower_bound:end);
abs_corr(298,:,lower_bound:end)=2/3*abs(297,:,lower_bound:end)+1/3*abs(300,:,lower_bound:end);
abs_corr(299,:,lower_bound:end)=1/3*abs(297,:,lower_bound:end)+2/3*abs(300,:,lower_bound:end);