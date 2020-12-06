function parameters=XuReadJsonc(json_file_name)
%parameters=XuReadJsonc(json_file_name)
%This function have potential bugs
%Please do not write the config file in the following format
%1. // or /* or */ in contents
%example: "b":{   // comments
%        // comments
%        "c": [1, 2, /*comments*/ 3],
%        "d": "string/*string*/string//"
%2. /* and */ and // in the same line
%example: "b":1, /* b*/ ,"c":0, //c
%3. The jsonc file should not end with ','. 

json_file_name=strrep(json_file_name,'.jsonc','');
json_file_name=strrep(json_file_name,'.JSONC','');
json_file_name=[json_file_name '.jsonc'];

fid=fopen(json_file_name,'r');
total_s=[];
s=fgetl(fid);
while ischar(s)
    if ~contains(s,'//')%judge whether the line contains "//"
        
        %if the line does not contain "//"
        %judge whether it contains "/"*
        if contains(s,'/*')
            
            %if the line contains "/*"
            %Read the content before the "/*"
            p=strfind(s,'/*');
            total_s=[total_s,s(1:p(1)-1)];
            
            %if the line contains "/*"
            %the next several lines might also be comments
            %so we need so search for "*/" to find the end of the comment
            %The loop will quit until we find a "*/"
            while ~contains(s,'*/')
                s=fgetl(fid);
            end
            
            %if the line contains "*/"
            %Read the content after the "*/"
            p=strfind(s,'*/');
            total_s=[total_s,s(p(1)+2:end)];            
        else
            total_s=[total_s,s];
        end
    else
        %if the line contains "//"
        %Read the content before the "//"
        p=strfind(s,'//');
        total_s=[total_s,s(1:p(1)-1)];
    end
    s=fgetl(fid);
end
parameters=jsondecode(total_s);
fclose(fid);