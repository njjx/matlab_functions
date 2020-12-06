function threshold=XuReadHydraThreshold(fid)
%Read threshold from the hydra detector
%return the threshold number given in the evi file (not in the interface!)
fseek(fid,0,-1);
for idx=1:27
    string=fgetl(fid);
end
p=strfind(string,' ');
threshold=str2double(string(p(2):p(3)-1));