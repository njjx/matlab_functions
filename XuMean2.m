function output = XuMean2(input,squeeze_or_not)

if nargin==1
    squeeze_or_not=1;
end

if squeeze_or_not==1
    output = squeeze(mean(mean(input,2),1));
else
    output = mean(mean(input,2),1);
end