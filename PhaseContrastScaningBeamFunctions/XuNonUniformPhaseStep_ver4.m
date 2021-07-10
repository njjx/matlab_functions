function X = XuNonUniformPhaseStep_ver4(coef_k,I_k)
coef_real = zeros([size(coef_k,1),2*size(coef_k,2)-1]);
coef_real(:,1) = real(coef_k(:,1));

for idx = 2:size(coef_k,2)
    coef_real(:,2*(idx-1)) = real(coef_k(:,idx));
    coef_real(:,2*(idx-1)+1) = -imag(coef_k(:,idx));
end

X = XuLeastSquareSolution(coef_real,I_k);
end
% 
% 
% Y = ones(length(X),1);
% Y(3:2:end)=0;
% 
% plot(coef_real*X,'ks-')
% hold on;
% plot(I_k,'b-','linewidth',3);
% plot(coef_real*Y,'ro-');
% hold off;
% xlim([2 60]);
% 
% rms(I_k - coef_real*X)
% rms(I_k - coef_real*Y)