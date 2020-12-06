function sinogram_noisy=XuSimuNoisySino(sinogram,photons)
%sinogram_noisy=XuSimuNoisySino(sinogram,photons)
sinogram_noisy=log(photons./poissrnd(photons.*exp(-sinogram)));