function [x_c,y_c,radius] = XuGetCircFromPoints(points_x_coor,points_y_coor)
%[x_c,y_c,radius] = XuGetCircFromPoints(points_x_coor,points_y_coor)

points_num = length(points_x_coor);

matrix_A = zeros(points_num,3);
matrix_A (:,1) = 2*squeeze(points_x_coor);
matrix_A (:,2) = 2*squeeze(points_y_coor);
matrix_A (:,3) = 1;

vec_Y = squeeze(points_x_coor.^2+points_y_coor.^2);
if size(vec_Y,1)<size(vec_Y,2)
    vec_Y=vec_Y';
end

vec_X = inv(matrix_A'*matrix_A)*(matrix_A')*vec_Y;

x_c = vec_X(1);
y_c = vec_X(2);
radius = sqrt(vec_X(3)+x_c^2+y_c^2);

