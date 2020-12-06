function status=WriteRaw(s,data)
%status=WriteRaw(s,data)

filename=s;
filename=[filename,'.raw'];
fid=fopen(filename,'w','l');
fwrite(fid,data,'float32');
fclose(fid);
status=1;