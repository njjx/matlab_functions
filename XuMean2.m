function output = XuMean2(input)

output = squeeze(mean(mean(input,2),1));