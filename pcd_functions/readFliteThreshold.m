function threshold=readFliteThreshold(fid)
fseek(fid,0,-1);
for idx=1:26
    string=fgetl(fid);
end
p=strfind(string,' ');
threshold=str2double(string(p(2):p(3)-1));