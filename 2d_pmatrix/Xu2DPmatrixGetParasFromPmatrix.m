function [paras, delta_u] = Xu2DPmatrixGetParasFromPmatrix(pmatrix)
inv_matrix_A = pmatrix(:,1:2);
matrix_A = inv(inv_matrix_A);
e_u = matrix_A(:,1);
x_do_x_s= matrix_A(:,2);
x_s = -matrix_A*pmatrix(:,3);
x_do = x_do_x_s+x_s;

theta_in_rad = angle(e_u(1)+1i*e_u(2));

paras=[theta_in_rad, x_do(1),x_s(1),x_do(2),x_s(2)];
delta_u = norm(e_u,2);