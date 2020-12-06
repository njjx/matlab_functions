function status=XuWriteRaw(s,data)
%status=WriteRaw(s,data)

filename=s;
filename = strrep(filename,'.raw','');
filename = strrep(filename,'.RAW','');
filename=[filename,'.raw'];
fid=fopen(filename,'w','l');
fwrite(fid,data,'float32');
fclose(fid);
status=1;