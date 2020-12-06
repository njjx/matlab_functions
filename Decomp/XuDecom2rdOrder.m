function sgm_A=XuDecom2rdOrder(sgm_l,sgm_h,P)
matrix=[sgm_l(:),sgm_h(:),sgm_l(:).^2,sgm_h(:).*sgm_l(:),sgm_h(:).^2];
sgm_A=matrix*P;
sgm_A=reshape(sgm_A,size(sgm_l));