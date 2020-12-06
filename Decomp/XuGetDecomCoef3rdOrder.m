function P=XuGetDecomCoef3rdOrder(sgm_l,sgm_h,sgm_A)


matrix=[sgm_l(:),sgm_h(:),sgm_l(:).^2,sgm_h(:).*sgm_l(:),sgm_h(:).^2,...
    sgm_l(:).^3,sgm_l(:).^2.*sgm_h(:),sgm_h(:).^2.*sgm_l(:),sgm_h(:).^3];

P=inv(matrix'*matrix)*matrix'*sgm_A(:);