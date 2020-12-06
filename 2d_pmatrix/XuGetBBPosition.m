function [x_coor, y_coor] = XuGetBBPosition(rec_cal_phantom, threshold_val,N_bbs)

rec_cal_phantom_threshold = rec_cal_phantom>threshold_val;
figure();
imshow(rec_cal_phantom_threshold,[]);
s=regionprops(rec_cal_phantom_threshold, rec_cal_phantom,'weightedcentroid');

if length(s)~=N_bbs
    error('Number of BBs detected is wrong; Use a different threshold val! ')
end
x_coor = zeros(1,length(s));
y_coor = zeros(1,length(s));
for idx = 1:length(s)
    temp = s(idx).WeightedCentroid;
    x_coor(idx) = temp(1);
    y_coor(idx) = temp(2);
end