function data=XuReadVarianFluoro(fid,number_of_frames,height_begin,height_end)
%data=ReadVarianFullRes(fid,number_of_frames,height_begin,height_end)
if height_begin<1 || height_end>768 || height_begin>height_end
    error("Wrong height range! [height_begin height_end] in [1 768]");
end
disp('Reading raw data!')
data=zeros(1024,height_end-height_begin+1,number_of_frames);

pb = MgCmdLineProgressBar('Reading frames #');

for frameidx=1:number_of_frames
    pb.print(frameidx,number_of_frames);
    fseek(fid,2048+(1024*768*2)*(frameidx-1),-1);
    single_frame_whole=fread(fid,[1024 768],'uint16');
    data(:,:,frameidx)=single_frame_whole(:,height_begin:height_end);
end
data((data==0))=1;
disp('Reading finished!')