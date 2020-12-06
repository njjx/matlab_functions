function status = XuReconWithAngularInfo (s_jsonc)
%status = XuReconWithAngularInfo (s_jsonc)
%the sinogram file is with the dimensions
status=0;
recon_para = XuReadJsonc(s_jsonc);

raw_data_folder=recon_para.RawDataFolder;
raw_to_sgm_sub=recon_para.RawToSgmFileReplace;

D=dir([raw_data_folder,'\*.IMA']);
for idx=1:length(D)
    raw_data_file_name = D(idx).name;
    
    %% read dicom header and get the angular info
    dicom_header = dicominfo([raw_data_folder D(idx).name]);
    struct_angle.ScanAngle = (-1)* dicom_header.PositionerPrimaryAngleIncrement;
    %(-1)* is added, because the sign of the angle of the dicom file is the
    %opposite of the recon program. 
    
    struct_angle.ScanAngle(1)=[];%the first frame is not captured the PCD
    jsonc_file_name = 'temp_angle_info.jsonc';%strrep(D(idx).name,'IMA','jsonc');
    
    XuStructToJsonc(['.\temp_config\' jsonc_file_name],struct_angle);
    
    %% generate the sgm file name
    sgm_data_file_name = strrep(raw_data_file_name,'.IMA',...
        ['-' num2str(recon_para.SinogramWidth) '-' num2str(recon_para.SinogramHeight) '.raw']);
    sgm_data_file_name =strrep(sgm_data_file_name,char(raw_to_sgm_sub(1)),char(raw_to_sgm_sub(2)));
    recon_para.InputFiles = sgm_data_file_name;
    
    %% change the recon parameters and save to a temp jsonc file
    recon_para.ScanAngleFile=['./temp_config/' jsonc_file_name];
    XuStructToJsonc('temp_config/temp_fbp_config.jsonc',recon_para);
    
    %% recon
    cmd = ['mgfbp.exe '  'temp_config\temp_fbp_config.jsonc'];
    system(cmd);
end

status=1;