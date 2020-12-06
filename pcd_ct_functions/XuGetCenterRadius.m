function [center_x, center_y, radius]=XuGetCenterRadius(image)
%[center_x, center_y, radius]=GetCenterRadius(image)
%image should better be binary

[mx my]=meshgrid(1:size(image,1) ,1:size(image,2));
center_x=sum(sum(mx.*image))/sum(sum(image));
center_y=sum(sum(my.*image))/sum(sum(image));
radius=sqrt(sum(sum(image)/pi));