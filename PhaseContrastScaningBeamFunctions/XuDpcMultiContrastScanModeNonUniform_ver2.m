function [img_absorp, img_dark, img_phase] = XuDpcMultiContrastScanModeNonUniform_ver2(obj_3d, I0_3d, eps_3d,phi_cos_3d,phi_sin_3d)
% Calculate the DPC multi-contrast images line-by-line
% [img_absorp, img_dark, img_phase] = XuDpcMultiContrastScanModeNonUniform_ver2(obj_3d, I0_3d, eps_3d,phi_cos_3d,phi_sin_3d)
% Calculate DPC multi contrast images.
% obj_3d: [M x N x S] projection data with object.
% air_3d: [M x N x S] projection data of air.
% scanMode: 'v' 'vertical' or 'h' 'horizontal'.

[rows, cols, S] = size(obj_3d);
img_dark = zeros(rows, cols);
img_absorp = zeros(rows, cols);
img_phase = zeros(rows, cols);

p = MgCmdLineProgressBar("Processing ");
for row_idx = 1:rows
    p.print(row_idx,rows);
    idx_non_nan = squeeze(min(~isnan(obj_3d(row_idx, :, :)), [], 2));
    
    if sum(idx_non_nan)>8
        for col_idx = 1:cols
            
            
            
            obj_3d_roi = squeeze(obj_3d(row_idx,col_idx,idx_non_nan));
            I0_3d_roi = squeeze(I0_3d(row_idx,col_idx,idx_non_nan));
            eps_3d_roi = squeeze(eps_3d(row_idx,col_idx,idx_non_nan));
            phi_sin_3d_roi = squeeze(phi_sin_3d(row_idx,col_idx,idx_non_nan));
            phi_cos_3d_roi = squeeze(phi_cos_3d(row_idx,col_idx,idx_non_nan));
            
            [img_absorp(row_idx,col_idx),  img_dark(row_idx,col_idx), img_phase(row_idx,col_idx)]=...
                XuNonUniformPhaseStep_ver2(I0_3d_roi, eps_3d_roi, ...
                phi_cos_3d_roi,phi_sin_3d_roi,...
                obj_3d_roi);
            
        end
    end
    
end


