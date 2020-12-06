function output = XuReadRawWithHeaderAndGap(file_name,size_array,header_byte,gap_byte,s_data_type)
fid=fopen(file_name,'r','l');
if fid<0
    str = sprintf('Cannot find file ''%s''!\n',file_name);
    warning(str);
    output = [];
    return;
else
    if isvector(size_array)
        size_array=[size_array,1,1];
    elseif length(size(size_array))==2
        size_array=[size_array 1];
    elseif length(size(size_array))>3
        error('Size array can have at most three values!');
    end
    
    
    output=zeros(size_array);
    fseek(fid,header_byte,-1);
    for idx = 1:size_array(3)
        output(:,:,idx) = fread(fid,size_array(1:2),s_data_type);
        fseek(fid,gap_byte,0);
    end
    fclose(fid);
end