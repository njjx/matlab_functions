function crop_idx=XuReadHydraCrop(s_file)
%output how the evi file is cropped
%crop_idx=[crop_left crop_top crop_right crop_bottom];
%The image is cropped as
%1:crop_left; crop_right:5120;
%1:crop_top; crop_bottom:64.

fid = fopen(s_file,'r','l');

if fid <0
    str = sprintf('Cannot find file ''%s''!\n',s_file);
    error(str);
else
    
    for idx=1:2
        string=fgetl(fid);
    end
    
    string=fgetl(fid);
    p=strfind(string,' ');
    crop_left = round(str2double(string(p(1)+1:end)));
    
    string=fgetl(fid);
    p=strfind(string,' ');
    crop_top = round(str2double(string(p(1)+1:end)));
    
    string=fgetl(fid);
    p=strfind(string,' ');
    crop_right = round(1+crop_left+str2double(string(p(1)+1:end)));
    
    string=fgetl(fid);
    p=strfind(string,' ');
    crop_bottom = round(1+crop_top+str2double(string(p(1)+1:end)));
    
    crop_idx=[crop_left crop_top crop_right crop_bottom];
    
    fclose(fid);
end