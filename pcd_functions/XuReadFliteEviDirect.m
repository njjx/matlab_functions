function image=XuReadFliteEviDirect(s,framenum)
%image=XuReadFliteEviDirect(s,framenum)
%offset is 2496 and gap is 64
fid=fopen(s,'r','l');
fprintf('Reading %s ...\n',s);
fseek(fid,2496,-1);
image=zeros(1536,128,framenum);
pb=MgCmdLineProgressBar('Reading Frame #');
for frameidx=1:framenum
    if mod(frameidx,100)==0 || frameidx==framenum
        pb.print(frameidx,framenum);
    end
    image(:,:,frameidx)=fread(fid,[1536 128],'uint16');
    fseek(fid,64,0);
end
fclose(fid);