function output=XuGetParaValue(struct_para,s_field_name,value)
%output=GetParaValue(struct_para,s_field_name,value)
%if s_field_name does not exist for the struct, output will be set to value

if isfield(struct_para,s_field_name)
    output=eval(['struct_para.' s_field_name]);
else
    output=value;
end