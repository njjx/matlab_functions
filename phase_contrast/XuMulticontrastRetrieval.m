function [N0, N1, phi] = XuMulticontrastRetrieval(phase_step_data)
%[N0, N1, phi] = XuPhaseRetrieval(phase_step_data)
%phase_step_data is a 3D matrix with dimension M x N x phase_steps

nsteps=size(phase_step_data,3);
fft_data=fft(phase_step_data,[],3);
phi=angle(fft_data(:,:,2));
N0=abs(fft_data(:,:,1))/nsteps;
N1=2*abs(fft_data(:,:,2))/nsteps;

