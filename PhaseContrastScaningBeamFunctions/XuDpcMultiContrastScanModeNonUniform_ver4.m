function img_sol = XuDpcMultiContrastScanModeNonUniform_ver4(obj_3d, coef_4d)
% Calculate the DPC multi-contrast images line-by-line
% img_sol = XuDpcMultiContrastScanModeNonUniform_ver4(obj_3d, coef_4d)
% Calculate DPC multi contrast images.
% obj_3d: [M x N x S] projection data with object.
% coef_4d: [M x N x S x 2*(order)+1] projection data of air.
% img_sol: [M x N x 2*(order)+1] solved coefficients in real number. 

[rows, cols, S] = size(obj_3d);
img_sol = zeros(rows, cols, 2*size(coef_4d,4)-1);

p = MgCmdLineProgressBar("Processing ");
for row_idx = 1:rows
    p.print(row_idx,rows);
    idx_non_nan = squeeze(min(~isnan(obj_3d(row_idx, :, :)), [], 2));
    
    if sum(idx_non_nan)>8
        for col_idx = 1:cols

            obj_3d_roi = squeeze(obj_3d(row_idx,col_idx,idx_non_nan));
            coef_3d_roi = squeeze(coef_4d(row_idx,col_idx,idx_non_nan,:));

            temp=XuNonUniformPhaseStep_ver4(coef_3d_roi,obj_3d_roi);
            temp = reshape(temp,[1 1 length(temp)]);
            img_sol(row_idx,col_idx,:)=temp;
        end
    end
    
end


