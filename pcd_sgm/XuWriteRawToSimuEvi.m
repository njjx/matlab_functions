function status = XuWriteRawToSimuEvi(sgm,s)
%status = XuWriteRawToSimuEvi(sgm,s)
sgm_height = size(sgm,2);

pb=MgCmdLineProgressBar('Saving frame #');

for view_idx = 1:sgm_height
    pb.print(view_idx,sgm_height);
    if view_idx == 1
        fid = fopen(s,'w','l');
        fseek(fid,0,-1);
        fwrite(fid,zeros(1,864),'float32');
        temp = repmat(sgm(:,view_idx),[1,64]);
        temp(:,[1:2,63:64])=0;
        fwrite(fid,temp,'float32');
        fclose(fid);
    else
        fid = fopen(s,'a','l');
        fseek(fid,0,1);
        fwrite(fid,zeros(1,96),'float32');
        temp = repmat(sgm(:,view_idx),[1,64]);
        temp(:,[1:2,63:64])=0;
        fwrite(fid,temp,'float32');
        fclose(fid);
    end
end

status =1; 