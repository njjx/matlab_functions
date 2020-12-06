function [mean,stdev]=XuWrappedNormalApproxMeanStd(mu,sigma)
%calculate the mean and std of the wrapped normal ditribution based on 
%some approximation
%[mean,stdev]=wrappednormal_t(mu,sigma)
% mu and sigma can be vectors

A=(pi+mu)/sqrt(2)./sigma;
B=(pi-mu)/sqrt(2)./sigma;

mean=mu+pi*(-erf(A)+erf(B));
stdev=sqrt(sigma.^2-2*sigma.*sqrt(2*pi).*(exp(-A.^2)+exp(-B.^2))+2*pi^2*(2-erf(A)-erf(B))-pi^2*(erf(A)-erf(B)).^2);

end