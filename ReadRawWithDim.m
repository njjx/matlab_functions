function data=ReadRawWithDim(s)
%data=ReadRawWithDim(s)
%s is a string with format "name-xx-xx-xx"
%s is without ".raw"


p=strfind(s,'-');
if length(p)<2
    error('Wrong filename format!');
end
for idx=1:length(p)
    
    if idx>1
        pos_left=p(end-idx+1)+1;
        pos_right=p(end-idx+2)-1;
        temp=str2num(s(pos_left:pos_right));
        if isempty(temp)
            break;
        elseif idx>=3
            break;
        else
            dim(idx)=temp;
        end
    else
        pos_left=p(end)+1;
        temp=str2num(s(pos_left:end));
        if isempty(temp)
            break;
        elseif idx>=3
            break;
        else
            dim(idx)=temp;
        end
    end
end

fid=fopen([s,'.raw'],'r','l');

if length(dim)==3
    data=fread(fid,dim(1)*dim(2)*dim(3),'float32');
    data=reshape(data,[dim(3) dim(2)  dim(1)  ]);
elseif length(dim)==2
    data=fread(fid,dim(1)*dim(2),'float32');
    data=reshape(data,[ dim(2) dim(1)]);
else
    error('Wrong filename format!')
end

fclose(fid);