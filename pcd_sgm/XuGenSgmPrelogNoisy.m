function sgm_prelog_noisy = XuGenSgmPrelogNoisy(sgm_prelog,N)
%sgm_prelog_noisy = XuGenSgmPrelogNoisy(sgm_prelog,N)

sgm_prelog_N = N.*sgm_prelog;
sgm_prelog_noisy = poissrnd(sgm_prelog_N);