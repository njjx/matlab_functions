
function xy_coor_sorted = XuArrangeBBPosition(x_coor,y_coor,N_bbs,delta_theta)
%xy_coor_sorted = XuArrangeBBPosition(x_coor,y_coor,N_bbs,delta_theta)


[x_c,y_c,radius] = XuGetCircFromPoints(x_coor,y_coor);%a rough estimate the circle
angle_coor = zeros(1,N_bbs);
for idx = 1:N_bbs
    angle_coor(idx) =   angle(x_coor(idx)-x_c+i*(y_c-y_coor(idx)));
end

data_temp = [radtodeg(angle_coor);x_coor;y_coor];
data_temp = data_temp';
data_temp = sortrows(data_temp,1,'ascend');

shift_flag = 0;

for bb_idx =1:N_bbs-1
    if data_temp(bb_idx+1,1)-data_temp(bb_idx,1)>delta_theta+10
        shift_flag = 1;
        break;
    end
end

if shift_flag == 1
    xy_coor_sorted = circshift(data_temp, [N_bbs-bb_idx 0]);
else
    xy_coor_sorted = data_temp;
end