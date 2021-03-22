function [ab_solved,df_solved,phi_solved] = XuNonUniformPhaseStep_ver2(I0_k,eps_k,phi_cos_k,phi_sin_k,I_k)
matrix_A = [ XuTallVector(I0_k), XuTallVector(I0_k.*eps_k.*phi_cos_k), -XuTallVector(I0_k.*eps_k.*phi_sin_k) ];
X = XuLeastSquareSolution(matrix_A,I_k);
ab_solved = -log(X(1));
df_solved = -log(sqrt(X(3)^2+X(2)^2)/X(1));
phi_solved = angle(X(2)+i*X(3));
end