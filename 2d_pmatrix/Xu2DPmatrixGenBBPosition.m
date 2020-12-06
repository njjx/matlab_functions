function [x, y] = Xu2DPmatrixGenBBPosition(paras, delta_theta, img_dim, pixel_size)

%theta = paras(1);
%x_c = paras(2);
%y_c = paras(3);
%radius = paras(4);

N = round(360/delta_theta);
theta = paras(1);
x_c = paras(2);
y_c = paras(3);
radius = paras(4);
x_solved = x_c + radius*cos(degtorad(theta)+(0:N-1)*degtorad(delta_theta));
y_solved = y_c + radius*sin(degtorad(theta)+(0:N-1)*degtorad(delta_theta));

%matlab transpose the image; so the order of x and y should be flipped
x = (y_solved-(img_dim/2+0.5))*pixel_size;
y = ((img_dim/2+0.5)-x_solved)*pixel_size;