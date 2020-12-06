function output_array = XuRemoveBadIdx(input_array, bad_idx_array)
%output_array = XuRemoveBadIdx(input_array, bad_idx)
output_array = input_array;
if max(bad_idx_array)>length(input_array)
    error('xxx');
end

good_idx_array = 1:length(input_array);
good_idx_array(bad_idx_array)=[];

output_array(bad_idx_array) = interp1(good_idx_array,input_array(good_idx_array),bad_idx_array,'linear','extrap');
    
end