function [X,ndx,dbg] = natsortrows(X,rgx,varargin)
% Alphanumeric / Natural-Order sort the rows of a cell array of strings (1xN char).
%
% (c) 2014-2019 Stephen Cobeldick
%
% Alphanumeric sort of the rows of a cell matrix of strings: sorts by both
% character order and also the values of any numbers that occur within the
% strings. SORTROWS <col> input is supported, to select columns to sort by.
%
%%% Example:
% >> X = {'x2','10';'x10','0';'x1','0';'x2','2'};
% >> sortrows(X) % Wrong numeric order:
% ans =
%     'x1'     '0'
%     'x10'    '0'
%     'x2'     '10'
%     'x2'     '2'
% >> natsortrows(X)
% ans =
%     'x1'     '0'
%     'x2'     '2'
%     'x2'     '10'
%     'x10'    '0'
%
%%% Syntax:
%  Y = natsortrows(X)
%  Y = natsortrows(X,rgx)
%  Y = natsortrows(X,rgx,<options>)
% [Y,ndx,dbg] = natsortrows(X,...)
%
% To sort filenames or filepaths correctly use NATSORTFILES (File Exchange 47434).
% To sort all of the strings in a cell array use NATSORT (File Exchange 34464).
%
%% File Dependency %%
%
% NATSORTROWS requires the function NATSORT (File Exchange 34464). The optional
% arguments <options> are passed directly to NATSORT (except for the SORTROWS-
% style <col> numeric vector, which is parsed locally). See NATSORT for case
% sensitivity, sort direction, numeric substring matching, and other options.
%
%% Examples %%
%
% >> A = {'B','2','X';'A','100','X';'B','10','X';'A','2','Y';'A','20','X'};
% >> sortrows(A) % wrong numeric order:
% ans =
%    'A'  '100'  'X'
%    'A'    '2'  'Y'
%    'A'   '20'  'X'
%    'B'   '10'  'X'
%    'B'    '2'  'X'
% >> natsortrows(A)
% ans =
%    'A'    '2'  'Y'
%    'A'   '20'  'X'
%    'A'  '100'  'X'
%    'B'    '2'  'X'
%    'B'   '10'  'X'
% >> natsortrows(A,[],'descend')
% ans =
%     'B'    '10'     'X'
%     'B'    '2'      'X'
%     'A'    '100'    'X'
%     'A'    '20'     'X'
%     'A'    '2'      'Y'
%
% >> sortrows(A,[2,-3]) % Wrong numeric order:
% ans =
%    'B'   '10'  'X'
%    'A'  '100'  'X'
%    'A'    '2'  'Y'
%    'B'    '2'  'X'
%    'A'   '20'  'X'
% >> natsortrows(A,[],[2,-3])
% ans =
%    'A'    '2'  'Y'
%    'B'    '2'  'X'
%    'B'   '10'  'X'
%    'A'   '20'  'X'
%    'A'  '100'  'X'
%
% >> B = {'ABCD';'3e45';'67.8';'+Inf';'-12';'+9';'NaN'};
% >> sortrows(B) % wrong numeric order:
% ans =
%    '+9'
%    '+Inf'
%    '-12'
%    '3e45'
%    '67.8'
%    'ABCD'
%    'NaN'
% >> natsortrows(B,'[-+]?(NaN|Inf|\d+\.?\d*(E[-+]?\d+)?)')
% ans =
%    '-12'
%    '+9'
%    '67.8'
%    '3e45'
%    '+Inf'
%    'NaN'
%    'ABCD'
%
%% Input and Output Arguments %%
%
%%% Inputs (*=default):
% X   = CellArrayOfCharRowVectors, size MxN. With rows to be sorted.
% rgx = Regular expression to match number substrings, '\d+'*
%     = [] uses the default regular expression, which matches integers.
% <options> can be supplied in any order and are passed directly to NATSORT.
%           SORTROWS input <col> is also accepted: a numeric vector where
%           each integer specifies which column of <X> to sort by, and
%           negative integers indicate that the sort order is descending.
%
%%% Outputs:
% Y   = CellArrayOfCharRowVectors, input <X> with the rows sorted as per <col>.
% ndx = NumericVector, size Mx1. Row indices such that Y = X(ndx,:).
% dbg = CellVectorOfCellArrays, size 1xN. Each cell contains the debug cell array
%       for one column of input <X>. Helps debug the regular expression. See NATSORT.
%
% See also SORT SORTROWS NATSORT NATSORTFILES CELLSTR REGEXP IREGEXP SSCANF
%% Input Wrangling %%
%
assert(iscell(X),'First input <X> must be a cell array.')
tmp = cellfun('isclass',X,'char') & cellfun('size',X,1)<2 & cellfun('ndims',X)<3;
assert(all(tmp(:)),'First input <X> must be a cell array of char row vectors (1xN char).')
assert(ndims(X)<3,'First input <X> must be a matrix (size RxC).') %#ok<ISMAT>
%
if nargin>1
    varargin = [{rgx},varargin];
end
%
%% Select Columns to Sort %%
%
[nmr,nmc] = size(X);
ndx = 1:nmr;
drn = {'descend','ascend'};
dbg = {};
isn = cellfun(@isnumeric,varargin);
isn(1) = false;
%
if any(isn)
    assert(nnz(isn)==1,'The <col> input is over-specified (only one numeric input allowed).')
    col = varargin{isn};
    assert(isvector(col)&&isreal(col)&&all(fix(col)==col)&&all(col)&&all(abs(col)<=nmc),...
        'The <col> input must be a vector of column indices into the first input <X>.')
    sgn = (3+sign(col))/2;
    idc = abs(col);
else
    idc = 1:nmc;
end
%
%% Sort Columns %%
%
for k = numel(idc):-1:1
    if any(isn)
        varargin{isn} = drn{sgn(k)};
    end
    if nargout<3 % faster:
        [~,ids] = natsort(X(ndx,idc(k)),varargin{:});
    else % for debugging:
        [~,ids,tmp] = natsort(X(ndx,idc(k)),varargin{:});
        [~,idd] = sort(ndx);
        dbg{idc(k)} = tmp(idd,:);
    end
    ndx = ndx(ids);
end
%
ndx = ndx(:);
X = X(ndx,:);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%natsortrows