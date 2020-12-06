function output = XuBinHydra(input,slicecount)
output = input(:,3:62);
output = imresize(output,[5120 slicecount],'box');
output = imresize(output,[5120 60],'box');
output(:,3:62)= output;
output(:,1:2)=0;
output(:,63:64)=0;
