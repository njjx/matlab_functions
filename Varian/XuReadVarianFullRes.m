function data=XuReadVarianFullRes(fid,number_of_frames,height_begin,height_end)
%data=ReadVarianFullRes(fid,number_of_frames,height_begin,height_end)
if height_begin<1 || height_end>1536 || height_begin>height_end
    error("Wrong height range! [height_begin height_end] in [1 1536]");
end
disp('Reading raw data!')
data=zeros(2048,height_end-height_begin+1,number_of_frames);
for frameidx=1:number_of_frames
    if mod(frameidx,200)==0
        fprintf('%.1f percent finished!\n', 100*frameidx/number_of_frames)
    end
    fseek(fid,2048+(2048*1536*2)*(frameidx-1),'bof');
    single_frame_whole=fread(fid,[2048 1536],'uint16');
        data(:,:,frameidx)=single_frame_whole(:,height_begin:height_end);
end
data((data==0))=1;
data=fliplr(data);
disp('Reading finished!')