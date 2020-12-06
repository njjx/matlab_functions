function [datout] = wrapphase(datin, minang)

if (nargin < 1)
    fprintf('Usage:\n');
    fprintf('[datout] = wrap(datin, minang);\n');
    return;
end
if (nargin < 2)
  minang = -pi;
end

% tmp = (datin - minang)/(2*pi);
% frac = tmp - floor(tmp);
% datout = minang + 2*pi*frac;

datout = minang + mod(datin - minang, 2*pi);
end
