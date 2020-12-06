function data=XuReadRaw(s_file_with_dot_raw,data_size,s_format)
%data=XuReadRaw(s_file_with_dot_raw,data_size,s_format)
%example:
%data=XuReadRaw('sample.raw',[512 512 1],'float32')

if nargin == 2
    s_format = 'float32';
end

fid=fopen(s_file_with_dot_raw,'r','l');

if fid<0
    str = sprintf('Cannot find file ''%s''!\n',s_file_with_dot_raw);
    data=[];
    warning(str);
else
    data_size_total=cumprod(data_size);
    data_size_total=data_size_total(end);
    data=fread(fid,data_size_total,s_format);
    data=reshape(data,data_size);
    fclose(fid);
end


