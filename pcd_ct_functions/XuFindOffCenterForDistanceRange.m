function status = XuFindOffCenterForDistanceRange(s_jsonc,distance_l,distance_h,s_inputfile_prefix)

if nargin == 2
    s_inputfile_prefix = '.*.sgm_abs_te.*.raw';
else
end

mkdir('temp');
para=XuReadJsonc(s_jsonc);
para.OutputDir='temp_recon';
para.InputFiles=s_inputfile_prefix;
para.HammingFilter=0;
mkdir(para.OutputDir);
for off_center_distance=(distance_l+0.01):0.1:(distance_h+0.01)

    para.SliceCount=1;
    para.DetectorOffcenter=off_center_distance;
    para.OutputFilePrefix=[num2str(off_center_distance)];


    XuStructToJsonc('temp/find_offcenter_distance.jsonc',para);
    !mgfbp.exe temp/find_offcenter_distance.jsonc
end
status = 1; 