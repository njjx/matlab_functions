function [img_absorp, img_dark, img_phase] = XuDpcMultiContrastScanModeNonUniform(obj_3d, I0_3d, eps_3d,phi_cos_3d,phi_sin_3d, scanMode, phasePeriod, moirePeriodCount, sampleInterval)
% Calculate the DPC multi-contrast images line-by-line
% [img_absorp, img_dark, img_phase] = MgDpcMultiContrast(obj_3d, air_3d, phasePeriod, sampleInterval)
% Calculate DPC multi contrast images.
% obj_3d: [M x N x S] projection data with object.
% air_3d: [M x N x S] projection data of air.
% scanMode: 'v' 'vertical' or 'h' 'horizontal'.
% phasePeriod (optional): phase step size, defalut is S.
% moirePeriodCount (optional): number of moire period in one phase step
% period, default is 1.
% sampleInterval (optional): sample interval along z direction, default is phasePeriod.

[rows, cols, S] = size(obj_3d);
img_dark = zeros(rows, cols);
img_absorp = zeros(rows, cols);
img_phase = zeros(rows, cols);


if nargin == 3
    phasePeriod = S;
    moirePeriodCount = 1;
    sampleInterval = 1;
elseif nargin == 4
    moirePeriodCount = 1;
    sampleInterval = 1;
elseif nargin == 5
    sampleInterval = 1;
end

p = MgCmdLineProgressBar("Processing ");

if  scanMode == "h" || scanMode == "horizontal"
    for row = 1:rows
        p.print(row, rows);
        idx_non_nan = squeeze(min(~isnan(obj_3d(row, :, :)), [], 2));
        
        if sum(idx_non_nan)>5
            
            obj_3d_roi = squeeze(obj_3d(row,:,idx_non_nan));
            I0_3d_roi = squeeze(I0_3d(row,:,idx_non_nan));
            eps_3d_roi = squeeze(eps_3d(row,:,idx_non_nan));
            phi_sin_3d_roi = squeeze(phi_sin_3d(row,:,idx_non_nan));
            phi_cos_3d_roi = squeeze(phi_cos_3d(row,:,idx_non_nan));
            
            for col_idx = 1:cols
                [img_absorp(row,col_idx),  img_dark(row,col_idx), img_phase(row,col_idx)]=...
                    XuNonUniformPhaseStep_ver2(I0_3d_roi(col_idx,:), eps_3d_roi(col_idx,:), ...
                    phi_cos_3d_roi(col_idx,:),phi_sin_3d_roi(col_idx,:),...
                    obj_3d_roi(col_idx,:));
                
            end
        else
        end
    end
elseif scanMode == "v" || scanMode == "vertical"
    for col = 1:cols
        idx_non_nan = squeeze(min(~isnan(obj_3d(:, col, :)), [], 1));
        [img_absorp(:,col), img_dark(:,col), img_phase(:,col)] = MgDpcMultiContrast(obj_3d(:,col,idx_non_nan), air_3d(:,col,idx_non_nan), phasePeriod, moirePeriodCount, sampleInterval);
    end
end

end

