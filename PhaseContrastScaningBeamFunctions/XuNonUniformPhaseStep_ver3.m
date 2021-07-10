function [ab_solved,df_solved,phi_solved] = XuNonUniformPhaseStep_ver3(coef_k,I_k)
coef_real = zeros([size(coef_k,1),2*size(coef_k,2)-1]);
coef_real(:,1) = real(coef_k(:,1));

for idx = 2:size(coef_k,2)
    coef_real(:,2*(idx-1)) = real(coef_k(:,idx));
    coef_real(:,2*(idx-1)+1) = -imag(coef_k(:,idx));
end

X = XuLeastSquareSolution(coef_real,I_k);
ab_solved = -log(X(1));
df_solved = -log(sqrt(X(3)^2+X(2)^2)/X(1));
phi_solved = angle(X(2)+i*X(3));
end