function [x,P]=wrappednormaldistribution(mu,sigma)
%[x,P]=wrappednormaldistribution(mu,sigma)
K=-100:100;
x=(-1+0.002:0.002:1-0.002)*pi;
for fidx=1:length(mu)
    
    P=zeros(1,length(x));
    for idx=1:length(K)
        P=P+1/sqrt(2*pi*sigma(fidx)^2)*exp(-(x-mu(fidx)+2*K(idx)*pi).^2/2/sigma(fidx)^2);
    end
    
    P=P/sum(P);
end