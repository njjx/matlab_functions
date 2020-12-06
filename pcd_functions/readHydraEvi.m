function image=readHydraEvi(fid,framenum)
%Read Evi file from hydra detector
%readHydraEvi(fileId, Number of frames)
fseek(fid,2368,-1);
image=zeros(5120,64,framenum);
for frameidx=1:framenum
    image(:,:,frameidx)=fread(fid,[5120 64],'float32');
    fseek(fid,64,0);
end