function status=StructToJsonc(s_filename,struct_para)
%status=StructToJsonc(s_filename,struct_para)

status=0;
text=jsonencode(struct_para);
fid=fopen(s_filename,'w');
fprintf(fid,text);
fclose(fid);
status=1;