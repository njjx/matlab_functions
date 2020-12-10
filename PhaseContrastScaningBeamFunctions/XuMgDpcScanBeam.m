function XuMgDpcScanBeam(config_filename)

config = MgReadJsoncFile(config_filename);

% step 1 (optional): calculate fringe period
if ~isnumeric(config.FringePeriod)
    config.FringePeriod = XuMgCalculateFringePeriodThor(config.FringePeriod{1}, config.FringePeriod{2});
end


% step 2: gen multi contrast imgs
% new parameters will be added to config
config = XuMgGenMultiContrastImgs(config);


% step 3: stitch image stack
XuMgTileUpImages(config);

if ~config.SaveTempFiles
    rmdir(config.folder_stack, 's');
end

end

