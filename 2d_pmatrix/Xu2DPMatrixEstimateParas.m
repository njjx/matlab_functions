function output = Xu2DPMatrixEstimateParas(beta_in_rad, sdd, sid, offcenter,det_elt_count, delta_u, delta_theta_in_rad)
%output = Xu2DPMatrixEstimateParas(beta_in_rad, sdd, sid, offcenter,det_elt_count, delta_u, delta_theta_in_rad)
%delta_theta_in_rad is optional
%This calculate the paras for a given view
%the output have 5 elements in the following order:
%theta, x_do, x_s, y_do, y_s;

if nargin == 6
    delta_theta_in_rad =0;
end

x_s = sid*cos(beta_in_rad); 
y_s = sid*sin(beta_in_rad); 

det_center_side_distance = (det_elt_count/2 - 0.5)*delta_u;
theta_in_rad = beta_in_rad - pi/2 + delta_theta_in_rad;

x_do = (sid - sdd) * cos(beta_in_rad) - (det_center_side_distance-offcenter) * cos (theta_in_rad);
y_do = (sid - sdd) * sin(beta_in_rad) - (det_center_side_distance-offcenter) * sin (theta_in_rad);


output = zeros(1,5);
output(1) = theta_in_rad;
output(2) = x_do;
output(3) = x_s;
output(4) = y_do;
output(5) = y_s;