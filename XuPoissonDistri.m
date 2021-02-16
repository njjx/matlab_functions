function output = XuPoissonDistri(lambda,k)
log_p = -lambda + k*log(lambda) - XuLogFactorial(k);
output = exp(log_p);