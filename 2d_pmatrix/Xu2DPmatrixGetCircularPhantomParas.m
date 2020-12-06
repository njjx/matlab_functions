function output = Xu2DPmatrixGetCircularPhantomParas(rec_cal_phantom, threshold_val, delta_theta)
%output = Xu2DPmatrixGetCircularPhantomParas(rec_cal_phantom, threshold_val, delta_theta)
%theta = output(1);
%x_c = output(2);
%y_c = output(3);
%radius = output(4);
%delta_theta is in degrees

rec_cal_phantom_threshold = rec_cal_phantom>threshold_val;

s=regionprops(rec_cal_phantom_threshold, rec_cal_phantom,'weightedcentroid');

if length(s)~=round(360/delta_theta)
    error('Number of BBs detected is wrong; Use a different threshold val! ')
end

x_corr = zeros(1,length(s));
y_corr = zeros(1,length(s));
for idx = 1:length(s)
    temp = s(idx).WeightedCentroid;
    x_corr(idx) = temp(1);
    y_corr(idx) = temp(2);
end

[x_c,y_c,radius] = XuGetCircFromPoints(x_corr,y_corr);%a rough estimate the circle
angle_corr = zeros(1,length(s));
for idx = 1:length(s)
    angle_corr(idx) =   angle(x_corr(idx)-x_c+i*(y_corr(idx)-y_c));
end

data_temp = [radtodeg(angle_corr);x_corr;y_corr];
data_temp = data_temp';
data_temp = sortrows(data_temp,1,'ascend');

options = optimoptions('fsolve','Algorithm','levenberg-marquardt');%,'Display','none'

output = fsolve(@(x) Xu2DPamtrixCalPhanGetPoints(x,delta_theta,data_temp(:,2)',data_temp(:,3)'),...
    [data_temp(1,1),x_c,y_c,radius], options);

[mx, my] = meshgrid(1:size(rec_cal_phantom,1),1:size(rec_cal_phantom,1));
est_circ = (mx-output(2)).^2+(my-output(3)).^2<output(4)^2;

rec_cal_phantom_check = double(rec_cal_phantom_threshold)+0.2*double(est_circ);
imshow(rec_cal_phantom_check,[]);