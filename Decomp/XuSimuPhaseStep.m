function phase_step=XuSimuPhaseStep(sinogram_atten,sinogram_dpc,n_phse_step,visibility,photons)
%XuSimuPhaseStep=XuSimuSinoPhaseStep(sinogram_atten,sinogram_dpc,n_phse_step,visibility,photons)
%photons are the total number of photons!
N_0=photons/n_phse_step*exp(-sinogram_atten);
N_1=N_0*visibility;
phase_step=zeros([size(sinogram_atten),n_phse_step]);
for idx=1:n_phse_step
    phase_step(:,:,idx)=(N_0+N_1.*cos(2*pi*(idx-1)/n_phse_step+sinogram_dpc));
end