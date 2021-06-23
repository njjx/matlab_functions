function sgm_corr = XuExtrapSgmCarm(sgm, s_config_preprocessing, s_config_fbp,mu_water)

if nargin ==3
    fbp_para = XuReadJsonc(s_config_fbp);
    mu_tissue = fbp_para.WaterMu;
else
    fbp_para = XuReadJsonc(s_config_fbp);
    mu_tissue = mu_water;
end
preprocessing_para = XuReadJsonc(s_config_preprocessing);

% detector element size [mm]
dx = fbp_para.DetectorElementSize;

pixel_binning = dx/0.1;

idx_left = round(preprocessing_para.SinogramBoundary(1)/pixel_binning)+1:...
    round(preprocessing_para.SinogramBoundary(1)/pixel_binning)+15;%196:210;
idx_right = round(preprocessing_para.SinogramBoundary(2)/pixel_binning)-15:...
    round(preprocessing_para.SinogramBoundary(2)/pixel_binning)-1;;

sgm(1:round(preprocessing_para.SinogramBoundary(1)/pixel_binning),:,:)=0;
sgm(round(preprocessing_para.SinogramBoundary(2)/pixel_binning):end,:,:)=0;

sgm = permute(sgm,[ 2 1 3]);

[M, N, S] = size(sgm);


for slice = 1:S
    % start interp
    for row = 1:M
        %-----------------------------------
        % left
        %-----------------------------------
        p = sgm(row, idx_left(1), slice);
        % calculate slope
        s = polyfit(idx_left, sgm(row, idx_left, slice), 1);
        s = s(1);
        % position x
        x = p*s/(4*mu_tissue^2);
        % radius R
        R = sqrt(p^2/(4*mu_tissue^2) + x^2);
        
        exp_ratio = 0.75;
        
        idx = idx_left(1);
        for col = 1:idx-1
            r = (idx - col) * dx;
            if r < abs(exp_ratio*R)
                sgm(row, col, slice) = 2*mu_tissue * sqrt(R^2 - (r/exp_ratio)^2);
            end
        end
        
        %-----------------------------------
        % right
        %-----------------------------------
        p = sgm(row, idx_right(end), slice);
        % calculate slope
        s = polyfit(idx_right, sgm(row, idx_right, slice), 1);
        s = s(1);
        % position x
        x = p*s/(4*mu_tissue^2);
        % radius R
        R = sqrt(p^2/(4*mu_tissue^2) + x^2);
        
        idx = idx_right(end);
        for col = idx+1:N
            r = (col - idx) * dx;
            if r < abs(exp_ratio*R)
                sgm(row, col, slice) = 2*mu_tissue * sqrt(R^2 - (r/exp_ratio)^2);
            end
        end
        
    end
    ratio = sgm(:, idx_left(1), slice) ./ sgm(:, idx_left(1)-1, slice);
    sgm(:, 1:idx_left(1)-1, slice) = sgm(:, 1:idx_left(1)-1, slice) .* ratio;
    
    ratio = sgm(:, idx_right(end), slice) ./ sgm(:, idx_right(end)+1, slice);
    sgm(:, idx_right(end)+1:N, slice) = sgm(:, idx_right(end)+1:N, slice) .* ratio;
end

sgm_corr = sgm;
sgm_corr = permute (sgm_corr,[2 1 3]);

sgm_corr = real(sgm_corr);
sgm_corr(find(isnan(sgm_corr)))=0;

end

