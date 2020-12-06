function sgm_corr = XuPanelSpecificCorr(sgm,s_coeff)
%sgm_corr = XuPanelSpecificCorr(sgm,s_coeff)

sgm_corr=sgm;

load(s_coeff);

panel_width = round(size(sgm,1)/size(water_corr_coef,1));

for panel_idx = 1:size(water_corr_coef,1)
    panel_roi = (panel_width*(panel_idx-1)+1):(panel_width*panel_idx);
    sgm_roi = sgm(panel_roi,:);
    sgm_corr_roi = polyval(water_corr_coef(panel_idx,:),sgm_roi);
    sgm_corr(panel_roi,:) = sgm_corr_roi;
end
