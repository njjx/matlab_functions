function X = XuNonUniformPhaseStep_ver4(coef_k,I_k)

% roi = 1:30;
% coef_k = coef_k(roi,:);
% I_k = I_k(roi,:);

coef_real = zeros([size(coef_k,1),2*size(coef_k,2)-1]);
coef_real(:,1) = real(coef_k(:,1));

for idx = 2:size(coef_k,2)
    coef_real(:,2*(idx-1)) = real(coef_k(:,idx));
    coef_real(:,2*(idx-1)+1) = -imag(coef_k(:,idx));
end
% I_k = I_k./coef_real(:,1);
% coef_real = coef_real./coef_real(:,1);


X = XuLeastSquareSolution(coef_real,I_k);
% plot(abs(X(2,:)+1i*X(3,:)),'-')
% hold on;

%%
% 
% I_k_p = I_k - coef_real(:,1).*(X(1,:)*1.1);
% X_p = XuLeastSquareSolution(coef_real(:,2:3),I_k_p);
% figure();
% plot(angle(X_p(1,:)+1i*X_p(2,:)) - angle(X(2,:)+1i*X(3,:)),'b-s')
% figure();
% plot(log(abs(X_p(1,:)+1i*X_p(2,:))./abs(X(2,:)+1i*X(3,:))),'b-s')
% %%
% Y = coef_real*X;
% 
% figure();
% plot(coef_real(:,2),'k-')
% hold on;
% plot(coef_real(:,3),'b-')
% plot(I_k(:,510),'r-')
% plot(Y(:,510),'r--')
% hold off;


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