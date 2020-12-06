function [mean,stdev]=wrappednormal_t(mu,sigma)
%[mean,stdev]=wrappednormal_t(mu,sigma)
% mean=zeros(1,length(mu));
% stdev=zeros(1,length(mu));

A=(pi+mu)/sqrt(2)./sigma;
B=(pi-mu)/sqrt(2)./sigma;

mean=mu+pi*(-erf(A)+erf(B));
stdev=sqrt(sigma.^2-2*sigma.*sqrt(2*pi).*(exp(-A.^2)+exp(-B.^2))+2*pi^2*(2-erf(A)-erf(B))-pi^2*(erf(A)-erf(B)).^2);

end