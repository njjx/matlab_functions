function status = XuModifyJsoncFile(s_jsonc, field_name, value, s_jsonc_output)

if nargin ==3
    s_jsonc_output =s_jsonc;
end

para = XuReadJsonc(s_jsonc);

if isempty(field_name)
    XuStructToJsonc(s_jsonc_output,para);
    return;
end

if isfield(para, field_name)
else
    str = sprintf('Original jsonc file do not have the field ''%s'' .',field_name);
    warning(str);
end

if isempty(value)
    para = rmfield(para,field_name);
else
    eval(['para.' field_name ' = value;']);
end

XuStructToJsonc(s_jsonc_output,para);
status = 1;