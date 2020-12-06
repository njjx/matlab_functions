function value = XuReadJsoncField(s_jsonc, field_name)
para = XuReadJsonc(s_jsonc);

if isfield(para, field_name)
    eval(['value = para.' field_name ';']);
else
    error('Did not find the field!');
end