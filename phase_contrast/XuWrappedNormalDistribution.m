function P=XuWrappedNormalDistribution(x,mu,sigma)
%P=XuWrappedNormalDistribution(x,mu,sigma)
K=-100:100;
for fidx=1:length(mu)
    
    P=zeros(1,length(x));
    for idx=1:length(K)
        P=P+1/sqrt(2*pi*sigma(fidx)^2)*exp(-(x-mu(fidx)+2*K(idx)*pi).^2/2/sigma(fidx)^2);
    end
    
    P=P/sum(P)/(x(2)-x(1));
end