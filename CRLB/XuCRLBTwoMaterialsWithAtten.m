function cov_matrix=XuCRLBTwoMaterialsWithAtten(energy,spec_1,spec_2,N_10,N_20,mu_1,mu_2,density_1,density_2,A_1,A_2)
%cov_matrix=XuCRLBTwoMaterialsWithAtten(energy,spec_1,spec_2,...
%     N_10,N_20,mu_1,mu_2,density_1,density_2,A_1,A_2)
%Calculate the CRLB covariance matrix
%spec_1 and spec_2 are two spectra, 
%N_10 and N_20 are the number of post object photons for two spectra, 
%mu_1 and mu_2 are the attenuation coefficient of the two materials
%density are the densities of the two materials
%A_1 and A_2 are the thickness of the two materials. 

spec_1=spec_1/sum(spec_1);
spec_2=spec_2/sum(spec_2);


spec_1_filtered=spec_1.*exp(-mu_1*A_1-mu_2*A_2);
spec_2_filtered=spec_2.*exp(-mu_1*A_1-mu_2*A_2);

M=zeros(2,2);
M(1,1)=sum(mu_1.*spec_1_filtered)/sum(spec_1_filtered);
M(1,2)=sum(mu_1.*spec_2_filtered)/sum(spec_2_filtered);
M(2,1)=sum(mu_2.*spec_1_filtered)/sum(spec_1_filtered);
M(2,2)=sum(mu_2.*spec_2_filtered)/sum(spec_2_filtered);

N_1=N_10*sum(spec_1_filtered);
N_2=N_20*sum(spec_2_filtered);

cov_matrix=inv(M')*[1/N_1 0;0 1/N_2]*inv(M);


