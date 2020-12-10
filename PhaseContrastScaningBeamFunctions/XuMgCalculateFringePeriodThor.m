function period_in_pixel = XuMgCalculateFringePeriodThor(filename, frameCount)

%% genearte ROI image
data_air = XuReadThorEviWithCropSplitImage(filename,frameCount,1);
data_air = mean(data_air,3);

%% calculate fringe period
roi_size = 201;
begin_row_idx = 453;
begin_col_idx = 122;

data_air_roi = data_air(begin_row_idx:begin_row_idx+roi_size-1,begin_col_idx:begin_col_idx+roi_size-1);
period_in_pixel = XuCalcPeriod(data_air_roi);

end

