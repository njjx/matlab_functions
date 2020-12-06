% Remove a 2D linear function (gradient) of form y = b0 + b1*x1 + b2*x2 from
% the given image img. 

function [bgr, b] = dpcfilt_grad2d_mod(img, mask)


% Prepare linear regression of the form:  y = b0 + b1*x1 + b2*x2

% Create matrices with the value of first and second dimension index
[xx1, xx2] = ndgrid(1:size(img,1), 1:size(img,2));

if nargin > 1
  % mask supplied by user
  if size(img,1) ~= size(mask,1)
    error('img and mask must be of the same size')
  end
  if size(img,2) ~= size(mask,2)
    error('img and mask must be of the same size')
  end
  ind = find(mask);
  n = numel(ind);
  if n == 0
    error('Mask is all zero.')
  end
  x = [ones(n, 1), reshape(xx1(ind), n, 1), reshape(xx2(ind), n, 1)];
  y = reshape(img(ind), n, 1);
else
  % no mask: use all pixels
  n = size(img,1) * size(img,2);
  x = [ones(n, 1), reshape(xx1, n, 1), reshape(xx2, n, 1)];
  y = reshape(img, n, 1);
end

% Linear regression in 2D using Matlab functions
[b, bint] = regress(y, x);

%Alternatively use this function that performs the same steps
%[b, bint] = regress2d(y, xx1, xx2)

% calculate the 2D linear function of the background
bgr = b(1) + xx1*b(2) + xx2*b(3);

%Remove the background
%img2 = img - bgr;

return;

