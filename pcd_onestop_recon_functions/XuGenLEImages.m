function status = XuGenLEImages(s_fbp_config,s_preprocesssing_config, gen_bkg_or_not)
%XuGenLEImages(s_preprocesssing_config,s_fbp_config, gen_bkg_or_not)
if nargin == 2
    gen_bkg_or_not = 1;
end

preprocess_para = XuReadJsonc(s_preprocesssing_config);
recon_para = XuReadJsonc(s_fbp_config);

fprintf('************Generating LE images ... *************\n');
%%

if gen_bkg_or_not==1
    input_folder = preprocess_para.RawDataBkgFolder;
    d_te = dir([input_folder,'/*te*']);
    d_he = dir([input_folder,'/*he*']);
    
    if length(d_te)~=length(d_he)
        error("TE and HE images mismatch!");
    end
    fprintf('Processing air scans ... \n');
    fprintf('**Please confirm: %d raw data files are to be processed:\n',length(d_te));
    for idx=1:length(d_te)
        disp(['File #' num2str(idx) ':' input_folder, '/' d_te(idx).name ' and ' d_he(idx).name]);
    end
    fprintf('******************************\n');
    pause(1);
    
    for file_idx = 1:length(d_te)
        fprintf('Reading air scan file #%d/%d ... \n', file_idx,length(d_te));
        img_te = XuReadHydraEviFromDirectVersionUnified([input_folder, '/',...
            d_te(file_idx).name],recon_para.SinogramHeight,1,...
            preprocess_para.DetectorFirmwareVersion);
        img_he = XuReadHydraEviFromDirectVersionUnified([input_folder, '/',...
            d_he(file_idx).name],recon_para.SinogramHeight,1,...
            preprocess_para.DetectorFirmwareVersion);
        img_le = img_te-img_he;
        crop_idx = XuReadHydraCrop([input_folder, '/',d_te(file_idx).name]);
        img_le(crop_idx(3):end,:,:)=[];
        img_le(1:crop_idx(1),:,:)=[];
        img_le(:,crop_idx(4):end,:)=[];
        img_le(:,1:crop_idx(2),:)=[];
        
        name_le = strrep(d_te(file_idx).name,'_te.evi','_le.evi');
        name_le = strrep(name_le,'_TE.EVI','_LE.EVI');
        
        XuWriteImgToEvi(img_le,[input_folder, '/', name_le],[input_folder, '/', d_te(file_idx).name]);
    end
end

%%
input_folder = preprocess_para.RawDataPrjFolder;
d_te = dir([input_folder, '/','*te*']);
d_he = dir([input_folder, '/','*he*']);
if length(d_te)~=length(d_he)
    error("TE and HE images mismatch!");
end

fprintf('Processing object scans ... \n');
fprintf('**Please confirm: %d raw data files are to be processed:\n',length(d_te));
for idx=1:length(d_te)
    disp(['File #' num2str(idx) ':' input_folder, '/' d_te(idx).name ' and ' d_he(idx).name]);
end
fprintf('******************************\n');
pause(1);

for file_idx = 1:length(d_te)
    
    fprintf('Reading object scan file #%d/%d ... \n', file_idx,length(d_te));
    img_te = XuReadHydraEviFromDirectVersionUnified([input_folder, '/',...
        d_te(file_idx).name],recon_para.SinogramHeight,1,...
        preprocess_para.DetectorFirmwareVersion);
    img_he = XuReadHydraEviFromDirectVersionUnified([input_folder, '/',...
        d_he(file_idx).name],recon_para.SinogramHeight,1,...
        preprocess_para.DetectorFirmwareVersion);
    img_le = img_te-img_he;
    crop_idx = XuReadHydraCrop([input_folder, '/',d_te(file_idx).name]);
    img_le(crop_idx(3):end,:,:)=[];
    img_le(1:crop_idx(1),:,:)=[];
    img_le(:,crop_idx(4):end,:)=[];
    img_le(:,1:crop_idx(2),:)=[];
    
    name_le = strrep(d_te(file_idx).name,'_te.evi','_le.evi');
    name_le = strrep(name_le,'_TE.EVI','_LE.EVI');
    
    XuWriteImgToEvi(img_le,[input_folder, '/', name_le],[input_folder, '/', d_te(file_idx).name]);
end

status =1;
end