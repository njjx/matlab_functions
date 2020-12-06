function image=XuReadHydraEviFromDirect_ver2_w_dead_pixel_correction(s,framenum,framenumbegin,display_cmd_or_not)
%Read Evi file from hydra detector
%s is the the name string of the file ("*.evi")
%image=readHydraEviFrom(fid,framenum,framenumbegin)
%framenumbegin is included in the reading
%e.g. readHydraEviFrom('test.evi',3,2)
%reads frame #2 #3 and #4

if nargin ==3
    display_cmd_or_not=0;
else
end

dead_pixel_index=importdata('deadpixel.txt');
if display_cmd_or_not==1
    pb=MgCmdLineProgressBar('Reading Frame#');
else
end

crop_idx = XuReadHydraCrop(s);
width = crop_idx(3) - crop_idx(1) - 1;
height = crop_idx(4) - crop_idx(2) - 1;

fid=fopen(s,'r','l');
fseek(fid,3456+(width*height*4+384)*(framenumbegin-1),-1);
image=zeros(5120,64,framenum);
for frameidx=1:framenum
    if display_cmd_or_not==1
        pb.print(frameidx, framenum);
    end
    image_cropped=fread(fid,[width height],'float32');
    
    input_image=zeros(5120,64);
    input_image(crop_idx(1)+1:crop_idx(3)-1,crop_idx(2)+1:crop_idx(4)-1) ...
        = image_cropped;
    image_temp=input_image;
    image_temp(1286,3) = 1/2*(input_image(1285,3)+input_image(1287,3));
    image_temp(1286,4) = 1/4*(input_image(1285,3)+input_image(1287,5)+input_image(1285,5)+input_image(1287,3));
    image_temp(1287,4) = 1/2*(input_image(1287,3)+input_image(1287,5));
    image_temp(3594,62) = 1/2*(input_image(3593,62)+input_image(3595,62));
    
    for idx=1:size(dead_pixel_index,1)
        RowIdx=dead_pixel_index(idx,1);
        ColIdx=dead_pixel_index(idx,2);
        image_temp(RowIdx,ColIdx)=...
            (image_temp(RowIdx+1,ColIdx)+image_temp(RowIdx-1,ColIdx)+...
            image_temp(RowIdx,ColIdx+1)+image_temp(RowIdx,ColIdx-1))/4;
    end
    %image_temp(image_temp==0)=1;
    
    image(:,:,frameidx)=image_temp;
    
    fseek(fid,384,0);
end
fclose(fid);