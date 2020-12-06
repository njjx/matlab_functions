function parameters=jsondecodewithcomment(json_file_name)
fid=fopen(json_file_name,'r');
total_s=[];
s=fgetl(fid);
while ischar(s)
    if ~contains(s,'//')%judge whether the line contains "//"
        
        %if the line does not contain "//"
        %judge whether it contains "/"*
        if contains(s,'/*')
            
            %if the line contains "/*"
            %the next several lines might also be comments
            %so we need so search for "*/" to find the end of the comment
            %The loop will quit until we find a "*/"
            while ~contains(s,'*/')
                s=fgetl(fid);
            end
        else
            total_s=[total_s,s];
        end
    else
        p=strfind(s,'//');
        total_s=[total_s,s(1:p(1)-1)];
    end
    s=fgetl(fid);
end
%total_s=['{',total_s,'}'];
%disp(total_s);
parameters=jsondecode(total_s);
fclose(fid);