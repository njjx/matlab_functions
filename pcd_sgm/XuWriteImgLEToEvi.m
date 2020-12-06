function status = XuWriteImgLEToEvi(img_le,s)
%status = XuWriteRawToSimuEvi(sgm,s)
sgm_height = size(img_le,3);

pb=MgCmdLineProgressBar('Saving frame #');

for view_idx = 1:sgm_height
    pb.print(view_idx,sgm_height);
    if view_idx == 1
        fid = fopen(s,'w+','l');
        fseek(fid,0,-1);
%         fprintf(fid,'PlainText_Header_Bytes 2048\rn');
%         fprintf(fid,'Image_Type Single\rn');
%         fprintf(fid,'ROI_X 0\rn');
%         fprintf(fid,'ROI_Y 0\rn');
%         fprintf(fid,'Width 5120\rn');
%         fprintf(fid,'Height 64\rn');
%         fprintf(fid,'Offset_To_First_Image 3456\rn');
%         fseek(fid,3456,-1);
        fwrite(fid,zeros(1,864),'float32');
        temp = img_le(:,:,view_idx);
        fwrite(fid,temp,'float32');
        fclose(fid);
    else
        fid = fopen(s,'a+','l');
        fseek(fid,0,1);
        fwrite(fid,zeros(1,96),'float32');
        temp = img_le(:,:,view_idx);
        fwrite(fid,temp,'float32');
        fclose(fid);
    end
end

status =1; 