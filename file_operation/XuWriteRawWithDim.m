function status=XuWriteRawWithDim(s,data)
%status=WriteRaw(s,data)

filename=s;
dim=size(data);

for idx=1:length(dim)
    
    filename=[filename,'-',num2str(dim(idx))];
end
filename=[filename,'.raw'];
fid=fopen(filename,'w','l');
fwrite(fid,data,'float32');
fclose(fid);
status=1;