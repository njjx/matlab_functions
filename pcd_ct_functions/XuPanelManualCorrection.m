function sgm_c = XuPanelManualCorrection(sgm,panel_idx,coef)
sgm_c = sgm;
sgm_c((panel_idx-1)*256:panel_idx*256,:,:)=sgm_c((panel_idx-1)*256:panel_idx*256,:,:)*coef;