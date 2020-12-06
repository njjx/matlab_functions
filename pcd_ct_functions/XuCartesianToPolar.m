function output_image=XuCartesianToPolar(input_image,mr,mtheta,img_dim,...
    offcenter_x_in_pixels,offcenter_y_in_pixels)

if nargin==4
    offcenter_x_in_pixels=0;
    offcenter_y_in_pixels=0;
else
end

img_center_x=(img_dim+1)/2+offcenter_x_in_pixels;
img_center_y=(img_dim+1)/2+offcenter_y_in_pixels;
vec_x=(1:img_dim)-img_center_x;
vec_y=(1:img_dim)-img_center_y;

[mx my]=meshgrid(vec_x,vec_y);

mrc=sqrt(mx.^2+my.^2);
mthetac=angle(mx+1i*my);

output_image=interp2(mr,mtheta,input_image,mrc,mthetac,'linear',0);