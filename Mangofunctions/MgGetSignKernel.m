function [kernel,x] = MgGetSignKernel(n)
% Get digitized sign kernel 1/(2\pi i k)
% n: number of elements
% kernel: sign kernel, length is 2n-1
% x: corresponding index of each kernel element.

func = @(x) sinc(x);

kernel = zeros(1,2*n-1);

for k = 1:2*n-1
    t = k-n;
    kernel(k) = integral(func, 0, t);
end

x = -(n-1):(n-1);


end