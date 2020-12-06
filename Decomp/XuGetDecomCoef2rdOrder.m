function P=XuGetDecomCoef2rdOrder(sgm_l,sgm_h,sgm_A)


matrix=[sgm_l(:),sgm_h(:),sgm_l(:).^2,sgm_h(:).*sgm_l(:),sgm_h(:).^2];

P=inv(matrix'*matrix)*matrix'*sgm_A(:);