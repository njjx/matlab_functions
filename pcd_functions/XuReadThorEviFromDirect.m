function image=XuReadThorEviFromDirect(s,framenum,framenumbegin)
%Read Evi file from Thor detector
%s is the the name string of the file ("*.evi")
%image=readHydraEviFrom(fid,framenum,framenumbegin)
%framenumbegin is included in the reading
%e.g. readHydraEviFrom('test.evi',3,2)
%reads frame #2 #3 and #4

if nargin == 2
    framenumbegin=1;
end

fid=fopen(s,'r','l');
fseek(fid,3264+(512*1024*2+192)*(framenumbegin-1),-1);
image=zeros(1024,512,framenum);
for frameidx=1:framenum
    image(:,:,frameidx)=fread(fid,[1024 512],'uint16');
    fseek(fid,192,0);
end
fclose(fid);