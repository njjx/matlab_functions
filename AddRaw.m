function status=AddRaw(s,data)
%status=AddRaw(s,data)

filename=s;
filename=[filename,'.raw'];
fid=fopen(filename,'a','l');
fwrite(fid,data,'float32');
fclose(fid);
status=1;