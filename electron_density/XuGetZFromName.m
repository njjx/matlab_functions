function z=XuGetZFromName(s)
%z=XuGetZFromName(s)
element_name=s;
name_and_z=importdata('name_and_z.txt');
for idx=1:size(name_and_z.textdata,1)
    if strcmp(element_name,char(name_and_z.textdata(idx,2)))
        break;
    end
end
z=name_and_z.data(idx);