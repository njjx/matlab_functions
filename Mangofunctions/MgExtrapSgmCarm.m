function sgm_corr = MgExtrapSgmCarm(sgm, mu_tissue)

if nargin < 2
    mu_tissue = 0.017;
end

% detector element size [mm]
dx = 0.4;

idx_left = 196:210;
idx_right = 1005:1019;

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
        
        idx = idx_left(1);
        for col = 1:idx-1
            r = (idx - col) * dx;
            if r < abs(R)
                sgm(row, col, slice) = 2*mu_tissue * sqrt(R^2 - r^2);
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
            if r < abs(R)
                sgm(row, col, slice) = 2*mu_tissue * sqrt(R^2 - r^2);
            end
        end
        
    end
    ratio = sgm(:, idx_left(1), slice) ./ sgm(:, idx_left(1)-1, slice);
    sgm(:, 1:idx_left(1)-1, slice) = sgm(:, 1:idx_left(1)-1, slice) .* ratio;
    
    ratio = sgm(:, idx_right(end), slice) ./ sgm(:, idx_right(end)+1, slice);
    sgm(:, idx_right(end)+1:N, slice) = sgm(:, idx_right(end)+1:N, slice) .* ratio;
end

sgm_corr = sgm;

end

