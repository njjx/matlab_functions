function img_sol_complex = XuSolRealToComplex(img_sol)

order = (size(img_sol,3)-1)/2;
img_sol_complex(:,:,1) = img_sol(:,:,1);
img_sol_complex(:,:,2:order+1) = img_sol(:,:,2:2:end)+1i*img_sol(:,:,3:2:end);