function [absorp, dark, phi] = XuMCbkgprj(phase_step_data_bkg,phase_step_data_prj)
%[abs, dark, phi] = XuMCbkgprj(phase_step_data_bkg,phase_step_data_prj)
%phase_step_data_bkg is a 3D matrix with dimension M x N x phase_steps
%phase_step_data_prj is a 3D matrix with dimension M x N x phase_steps

nsteps=size(phase_step_data_bkg,3);
fft_data=fft(phase_step_data_bkg,[],3);
phi_bkg=angle(fft_data(:,:,2));
N0_bkg=abs(fft_data(:,:,1))/nsteps;
N1_bkg=2*abs(fft_data(:,:,2))/nsteps;

fft_data=fft(phase_step_data_prj,[],3);
phi_prj=angle(fft_data(:,:,2));
N0_prj=abs(fft_data(:,:,1))/nsteps;
N1_prj=2*abs(fft_data(:,:,2))/nsteps;

absorp=-log((N0_prj+eps)./(N0_bkg+eps));
dark=-log((N1_prj+eps)./(N1_bkg+eps))-absorp;
phi=angle(exp(1i*(phi_prj-phi_bkg)));