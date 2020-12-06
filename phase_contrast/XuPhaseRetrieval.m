function phase = XuPhaseRetrieval(phase_step_data)
%phase = XuPhaseRetrieval(phase_step_data)
%phase_step_data is a 3D matrix with dimension M x N x phase_steps
fft_data=fft(phase_step_data,[],3);
phase=angle(fft_data(:,:,2));