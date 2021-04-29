function image=XuReadHydraEviFromDirect_ver2_w_crop(s,framenum,framenumbegin)
%Read Evi file from hydra detector with crop
%image size is NOT 5120 * 64
%s is the the name string of the file ("*.evi")
%image=readHydraEviFrom(fid,framenum,framenumbegin)
%framenumbegin is included in the reading
%e.g. readHydraEviFrom('test.evi',3,2)
%reads frame #2 #3 and #4

if nargin ==2
    framenumbegin=1;
end

crop_idx = XuReadHydraCrop(s);
width = crop_idx(3) - crop_idx(1) - 1;
height = crop_idx(4) - crop_idx(2) - 1;


fid=fopen(s,'r','l');
fseek(fid,3456+(width*height*4+384)*(framenumbegin-1),-1);
image=zeros(width,height,framenum);
for frameidx=1:framenum
    img_temp = fread(fid,[width height],'float32');
    image(:,:,frameidx) = img_temp;
    fseek(fid,384,0);
end
fclose(fid);