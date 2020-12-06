function [output_image,mr,mtheta]=XuPolarToCartesian(input_image,offcenter_x_in_pixels,offcenter_y_in_pixels)
%output_image=PolarToCartesian(input_image,offcenter_x_in_pixels,offcenter_y_in_pixels)

img_dim=size(input_image,1);
img_center_x=(img_dim+1)/2+offcenter_x_in_pixels;
img_center_y=(img_dim+1)/2+offcenter_y_in_pixels;
vec_x=(1:img_dim)-img_center_x;
vec_y=(1:img_dim)-img_center_y;

[mx my]=meshgrid(vec_x,vec_y);

theta_num=3.5*img_dim;
vec_theta=(0:theta_num)*3*pi/theta_num-1.5*pi;
r_max=round(img_dim)/1.5;
vec_r=-r_max:0.5:r_max;

[mr mtheta]=meshgrid(vec_r,vec_theta);

mxp=mr.*cos(mtheta);
myp=mr.*sin(mtheta);

output_image=interp2(mx,my,input_image,mxp,myp,'linear',0);