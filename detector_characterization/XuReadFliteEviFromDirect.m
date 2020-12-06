function image=XuReadThorEviFromDirect(s,framenum,framenumbegin)
%Read Evi file from Flite detector
%s is the the name string of the file ("*.evi")
%image=readHydraEviFrom(fid,framenum,framenumbegin)
%framenumbegin is included in the reading
%e.g. readHydraEviFrom('test.evi',3,2)
%reads frame #2 #3 and #4

if nargin == 2
    framenumbegin=1;
end

fid=fopen(s,'r','l');
fseek(fid,2496+(1536*128*2+64)*(framenumbegin-1),-1);
image=zeros(1536,128,framenum);
for frameidx=1:framenum
    image(:,:,frameidx)=fread(fid,[1536 128],'uint16');
    fseek(fid,64,0);
end
fclose(fid);