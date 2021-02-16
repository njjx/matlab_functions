function output = XuNonParalyzableDistri(n,t,tau,k)

m = n*t;
z = n*tau;

k_upper = floor(m/z)-1;
if k>k_upper
    error('k need to be smaller than t/tau!')
else 
    if k~=0
        lambda = m-(k)*z;
        output = poisspdf(k,lambda)+gammainc(lambda+z,k) - gammainc(lambda,k);
    else
        output = exp(-m);
    end
end

end

