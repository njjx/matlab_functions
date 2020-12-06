function sgm_prelog_noisy = XuGenSgmPrelogNoisyGaussianApprox(sgm_prelog,N)
%sgm_prelog_noisy = XuGenSgmPrelogNoisy(sgm_prelog,N)

sgm_prelog_N = N.*sgm_prelog;
sgm_prelog_noisy = sgm_prelog_N+randn(size(sgm_prelog_N)).*sqrt(sgm_prelog_N);