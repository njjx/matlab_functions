function image=readHydraEviFromDirect(s,framenum,framenumbegin)
%Read Evi file from hydra detector
%s is the the name string of the file ("*.evi")
%image=readHydraEviFrom(fid,framenum,framenumbegin)
%framenumbegin is included in the reading
%e.g. readHydraEviFrom('test.evi',3,2)
%reads frame #2 #3 and #4
fid=fopen(s,'r','l');
fseek(fid,2368+(5120*64*4+64)*(framenumbegin-1),-1);
image=zeros(5120,64,framenum);
for frameidx=1:framenum
    image(:,:,frameidx)=fread(fid,[5120 64],'float32');
    fseek(fid,64,0);
end
fclose(fid);