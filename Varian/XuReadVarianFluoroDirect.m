function data=XuReadVarianFluoroDirect(file_name,number_of_frames,height_begin,height_end)
fid = fopen(file_name,'r','l');
data=[];
if fid <1
    str = sprintf('Cannot find file %s!',file_name);
    disp(str);
else
     data=XuReadVarianFluoro(fid,number_of_frames,height_begin,height_end);
     fclose(fid);
end



