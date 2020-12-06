function output = XuTallVector(input)

if isvector(input)
    
    if size(input,1)<size(input,2)
        output = input';
    else
        output = input;
    end
else
    error('input is not a vector.')
end