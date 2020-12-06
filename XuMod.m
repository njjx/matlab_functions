function output = XuMod(X,Y)

output = mod(X,Y);
if output == 0
    output = Y;
end

end