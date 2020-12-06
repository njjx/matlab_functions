function output = XuEdgeSpreadFunctionResample(edge_spread_function, resampling_pixel_size)
%output = XuEdgeSpreadFunctionResample(edge_spread_function, resampling_pixel_size)

StartIdx=floor(min(edge_spread_function(1,:)));
EndIdx=ceil(max(edge_spread_function(1,:)));


ResamplingInterval=resampling_pixel_size;
ResamplingCordinates=StartIdx:ResamplingInterval:EndIdx;
ResamplingPoints=(EndIdx-StartIdx)/ResamplingInterval+1;

Count=zeros(1,ResamplingPoints);
ResamplingSum=zeros(1,ResamplingPoints);
for Idx=1:size(edge_spread_function,2)
    ResamplingIdx=round((edge_spread_function(1,Idx)-StartIdx)/ResamplingInterval)+1;
    Count(1,ResamplingIdx)=Count(1,ResamplingIdx)+1;
    ResamplingSum(1,ResamplingIdx)=ResamplingSum(1,ResamplingIdx)+edge_spread_function(2,Idx);
end

ResamplingValues=ResamplingSum./Count;

output = [ResamplingCordinates;ResamplingValues];