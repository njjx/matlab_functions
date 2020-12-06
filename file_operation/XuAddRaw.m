function status=XuAddRaw(s,data)
%status=AddRaw(s,data)

filename= lower(s);
filename=strrep(filename,'.raw','');

filename=[filename,'.raw'];
fid=fopen(filename,'a','l');
fwrite(fid,data,'float32');
fclose(fid);
status=1;