function sgm_noisy = XuGenSgmNoisy(sgm,N)
%sgm_noisy = XuGenSgmNoisy(sgm,N)
%sgm is postlog

sgm_prelog=exp(-sgm);

sgm_prelog_N = N.*sgm_prelog;
sgm_prelog_N_noisy = poissrnd(sgm_prelog_N);
sgm_noisy = log(N./sgm_prelog_N_noisy);