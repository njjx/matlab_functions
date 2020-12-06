function [data_low_gain, data_high_gain]=ReadVarianSeqDual2x4(fid,number_of_frames,height_begin,height_end)
%[data_low_gain, data_high_gain]=ReadVarianSeqDual2x4(fid,number_of_frames,height_begin,height_end)
if height_begin<1 || height_end>384 || height_begin>height_end
    error("Wrong height range! [height_begin height_end] in [1 384]");
end
disp('Reading raw data!')
data=zeros(2048,height_end-height_begin+1,number_of_frames);
for frameidx=1:number_of_frames
    if mod(frameidx,200)==0
        fprintf('%.1f percent finished!\n', 100*frameidx/number_of_frames)
    end
    fseek(fid,2048+(2048*384*2)*(frameidx-1),'bof');
    single_frame_whole=fread(fid,[2048 384],'uint16');
    if height_end<=384/2
        data(:,:,frameidx)=single_frame_whole(:,height_begin:height_end);
    elseif height_begin>384/2
        data(:,:,frameidx)=circshift(single_frame_whole(:,height_begin:height_end),1024);
    else
        data(:,:,frameidx)=[single_frame_whole(:,height_begin:384/2),circshift(single_frame_whole(:,384/2+1:height_end),1024)];
    end
end
data(find(data==0))=1;
data=fliplr(data);
data_low_gain=data(1025:2048,:,:);
data_high_gain=data(1:1024,:,:);
disp('Reading finished!')