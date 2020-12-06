function overlap_idx = Xu2DPmatrixMatchBBsFindOverlapIdx(u_measured, u_est, x_coor, y_coor)

u_measured = XuTallVector(u_measured);
u_est = XuTallVector(u_est);
x_coor = XuTallVector(x_coor);
y_coor = XuTallVector(y_coor);


temp_matrix = [u_est,x_coor,y_coor];
temp_matrix = sortrows(temp_matrix,1,'ascend');
u_measured = sort(u_measured);
detected_BBs_count = length(u_measured);
if  length(u_est)-detected_BBs_count==1
    r_calc = zeros(1,detected_BBs_count);
    for u_idx = 1:detected_BBs_count
        u_measure_temp = [u_measured(1:u_idx); ...
            u_measured(u_idx); u_measured(u_idx+1:end)];
        r_calc(u_idx) = XuRSquared(u_measure_temp,temp_matrix(:,1));
    end
    [max_val, overlap_idx] = max(r_calc);
elseif length(u_est)-detected_BBs_count==2
    % if there are two groups of points overlap with each other
    r_calc = zeros(detected_BBs_count,detected_BBs_count);
    for u_idx = 1:detected_BBs_count-1
        for u_idx_2 = u_idx+1:detected_BBs_count
            u_measure_temp = [u_measured(1:u_idx); ...
                u_measured(u_idx); ...
                u_measured(u_idx+1:u_idx_2);...
                u_measured(u_idx_2); ...
                u_measured(u_idx_2+1:end)...
                ];
            r_calc(u_idx,u_idx_2) = XuRSquared(u_measure_temp,temp_matrix(:,1));
        end
    end
    
    [row_val,col_idx] = max(r_calc,[],2);
    [col_val,row_idx] = max(row_val);
    col_idx = col_idx(row_idx);
    
    overlap_idx(1) = row_idx;
    overlap_idx(2) = col_idx;
elseif length(u_est)-detected_BBs_count==0
    overlap_idx = 0;
else
    overlap_idx = -100;
end