function [basis_1,basis_2] = XuDecomposeDualEnergy(img_l,img_h,mu_1,mu_2)

mu_1 = XuTallVector(mu_1);
mu_2 = XuTallVector(mu_2);

coeff_matrix = XuLeastSquareSolution([mu_1,mu_2],[img_l(:)';img_h(:)']);

basis_1 = coeff_matrix(1,:);
basis_1 = reshape(basis_1, size(img_l));

basis_2 = coeff_matrix(2,:);
basis_2 = reshape(basis_2, size(img_l));