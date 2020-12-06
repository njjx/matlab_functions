function err = Xu2DPamtrixCalPhanGetPoints(paras, delta_theta, x_coor,y_coor)
%Xu2DPamtrixCalPhanGetPoints(paras, delta_theta, x_corr,y_corr)
%This function is for acuquiring the position of the BBs
%This function calculate error for a set of given paras and 
%given delta_theta, x_coor and y_coor
%theta = paras(1);
%x_c = paras(2);
%y_c = paras(3);
%radius = paras(4);


theta = paras(1);
x_c = paras(2);
y_c = paras(3);
radius = paras(4);

N=length(x_coor);

x_from_model = x_c + radius*cos(degtorad(theta)+(0:N-1)*degtorad(delta_theta));
y_from_model = y_c + radius*sin(degtorad(theta)+(0:N-1)*degtorad(delta_theta));
err = [x_from_model - x_coor; y_from_model - y_coor];

