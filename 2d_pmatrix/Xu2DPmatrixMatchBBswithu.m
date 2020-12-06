function [u_measured_adj, u_est_adj, x_coor_adj, y_coor_adj]= Xu2DPmatrixMatchBBswithu(u_measured, u_est, x_coor, y_coor)

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
    [max_val, u_idx_pick] = max(r_calc);
    
%      u_measured = [u_measured(1:u_idx_pick);u_measured(u_idx_pick);u_measured(u_idx_pick+1:end)];
%     
    u_measured(u_idx_pick) = [];
    temp_matrix(u_idx_pick:u_idx_pick+1,:)=[];
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
    
    u_idx_pick = row_idx;
    u_idx_pick_2 = col_idx;
    
%     u_measured = [u_measured(1:u_idx_pick);u_measured(u_idx_pick);u_measured(u_idx_pick+1:end)];
%     u_measured = [u_measured(1:u_idx_pick_2+1);u_measured(u_idx_pick_2+1);u_measured(u_idx_pick_2+2:end)];
%     
    u_measured(u_idx_pick) = [];
    temp_matrix(u_idx_pick:u_idx_pick+1,:)=[];
    u_measured(u_idx_pick_2-1) = [];
    temp_matrix(u_idx_pick_2-1:u_idx_pick_2,:)=[];
    
elseif length(u_est)-detected_BBs_count>2
    % in this case, some elements of the u_est are deleted
    % this view will be find out by the following R^2 calculation
    temp_matrix = temp_matrix(1:detected_BBs_count,1);
    %error('Wrong number of points detected!')
elseif length(u_est)-detected_BBs_count<0
    % in this case, some elements of the u_measured are deleted
    % this view will be find out by the following R^2 calculation
    u_measured = u_measured(1:length(u_est));
    %error('Wrong number of points detected!')
end

u_measured_adj = u_measured;
u_est_adj = temp_matrix(:,1);
x_coor_adj = temp_matrix(:,2);
y_coor_adj = temp_matrix(:,3);