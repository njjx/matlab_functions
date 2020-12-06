function img_cal=XuSimuCal(img_dim,pos_x,pos_y,radius,intensity)
%img_cal=XuSimuCal(img_dim,pos_x,pos_y,radius,intensity)

[mx,my]=meshgrid(1:img_dim,1:img_dim);
img_cal=intensity*exp(-((mx-pos_y).^2+(my-pos_x).^2)/2/radius^2);