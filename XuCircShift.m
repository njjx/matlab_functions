function output = XuCircShift(input,distance_in_pixel,dim)

if nargin ==2
    dim = 1;
else
end

if dim ==2
    input = input';
end

output = input;
size_input = size(input);


for idx = 1:size_input(2)
    output(:,idx) = interp1(1:size_input(1),input(:,idx),(1:size_input(1))-distance_in_pixel,'linear',0);
end
if dim ==2
    output= output';
end

