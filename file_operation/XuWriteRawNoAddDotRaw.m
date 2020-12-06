function status=XuWriteRawNoAddDotRaw(s,data)
%status=XuWriteRawNoAddDotRaw(s,data)

filename=s;
fid=fopen(filename,'w','l');
fwrite(fid,data,'float32');
fclose(fid);
status=1;