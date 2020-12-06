function status = XuFindOffCenter(s_jsonc)


mkdir('temp');
para=XuReadJsonc(s_jsonc);
para.OutputDir='temp_recon';
para.InputFiles='Water_.*.raw';
para.HammingFilter=0;
mkdir(para.OutputDir);
for off_center_distance=13.01:0.1:14.01

    para.SliceCount=1;
    para.DetectorOffcenter=off_center_distance;
    para.OutputFilePrefix=[num2str(off_center_distance)];


    XuStructToJsonc('temp/find_offcenter_distance.jsonc',para);
    !mgfbp.exe temp/find_offcenter_distance.jsonc
end
status = 1; 