function image=readevi(fid,framenum)
fseek(fid,2496,-1);
image=zeros(1536,128,framenum);
for frameidx=1:framenum
    image(:,:,frameidx)=fread(fid,[1536 128],'uint16');
    fseek(fid,64,0);
end