function status = XuGenAngleJsonc(ima_file_name, s_jsonc)
%status = XuGenAngleJsonc(ima_file_name, s_jsonc)
status=0;
recon_para = XuReadJsonc(s_jsonc);

raw_data_folder=recon_para.RawDataFolder;

%% read dicom header and get the angular info

if exist([raw_data_folder ima_file_name],'file')
    
    dicom_header = dicominfo([raw_data_folder ima_file_name]);
    struct_angle.ScanAngle = (-1)* dicom_header.PositionerPrimaryAngleIncrement;
    %(-1)* is added, because the sign of the angle of the dicom file is the
    %opposite of the recon program.
    
    struct_angle.ScanAngle(1)=[];%the first frame is not captured the PCD
    jsonc_file_name = 'temp_angle_info.jsonc';%strrep(D(idx).name,'IMA','jsonc');
    
    XuStructToJsonc(['.\temp_config\' jsonc_file_name],struct_angle);
else
    fprintf('Cannot find dicom file! Angle info may use the previous saved one. \n')
end
status = 1;