function struct_output=XuStructPassVal(struct_source,struct_target)
%struct_output=XuStructPassVal(struct_source,struct_target)
%pass the values of the source struct to the target struct
%the function will pick the memebers that both exist in the source and target struct

struct_output=struct_target;

fn=fieldnames(struct_source);

for idx=1:length(fn)
    if isfield(struct_output,char(fn(idx)))
        temp=eval(['struct_source.' char(fn(idx))]);
        eval(['struct_output.' char(fn(idx)) '=temp;']);
    end
end
