
dpc = unwrap(dpc,[],1);
dpc = unwrap(dpc,[],2);


% phase drift problem
mask = ones(size(amp));
[bg b] = dpcfilt_grad2d_mod(dpc,mask);
dpc = dpc - bg;
dpc = wrapphase(dpc,-pi);