function status = XuWriteImgToEvi(img,s_imag,s_ref)
%status = XuWriteRawToSimuEvi(img,s_imag,s_ref)
sgm_height = size(img,3);

fid = fopen(s_ref,'r','l');
head_info = fread(fid, 3456, 'int8');
fclose(fid);

pb=MgCmdLineProgressBar('Saving frame #');

for view_idx = 1:sgm_height
    pb.print(view_idx,sgm_height);
    if view_idx == 1
        fid = fopen(s_imag,'w','l');
        fseek(fid,0,-1);
        fwrite(fid,head_info,'int8');
        temp = img(:,:,view_idx);
        fwrite(fid,temp,'float32');
        fclose(fid);
    else
        fid = fopen(s_imag,'a','l');
        fseek(fid,0,1);
        fwrite(fid,zeros(1,96),'float32');
        temp = img(:,:,view_idx);
        fwrite(fid,temp,'float32');
        fclose(fid);
    end
end

status =1; 