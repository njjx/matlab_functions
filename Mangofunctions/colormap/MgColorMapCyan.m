function c = MgColorMapCyan(m)
%c = MgColorMapCyan(m)
%   MgColorMapCyan(M) returns an M-by-3 matrix containing a "cyan" colormap.
%   MgColorMapCyan, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB uses the length of the
%   default colormap.
%
%   For example, to reset the colormap of the current figure:
%
%       colormap(MgColorMapCyan)
%


if nargin < 1
   f = get(groot,'CurrentFigure');
   if isempty(f)
      m = size(get(groot,'DefaultFigureColormap'),1);
   else
      m = size(f.Colormap,1);
   end
end

r = (0:m-1)'/max(m-1,1); 
c = [zeros(m,1) r r];
