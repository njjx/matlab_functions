function status=WriteRawWithDim(s,data,dim_set)
%status=WriteRaw(s,data)

if nargin ==2
    dim_set = length(size(data));
end

filename=s;
dim=size(data);

for idx=1:dim_set
    if idx<=length(dim)
    filename=[filename,'-',num2str(dim(idx))];
    else
        filename=[filename,'-1'];
    end
end
filename=[filename,'.raw'];
fid=fopen(filename,'w','l');
fwrite(fid,data,'float32');
fclose(fid);
status=1;