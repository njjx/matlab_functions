function beta_sdd_sid_offcenterdis_deltatheta = Xu2DPmatrixGetSDDSIDetcFromPmatrixInOne(pmatrix,det_elt_counts)

[paras, delta_u] =  Xu2DPmatrixGetParasFromPmatrix(pmatrix);

theta = paras(1);
x_do = paras(2);
x_s = paras(3);
y_do = paras(4);
y_s = paras(5);

beta = angle(x_s+1i*y_s);

delta_theta = theta-beta+pi/2;
delta_theta = angle(exp(1i*delta_theta));

sid = norm([x_s,y_s],2);

%x_do+ue_ux=ax_s -> x_s*a- e_ux*u =x_do
%y_do+ue_uy=ay_s -> y_s*a- e_uy*u =y_do

matrix_A = [x_s, -delta_u*cos(theta);y_s, -delta_u*sin(theta)];
Y = [x_do;y_do];
X = XuLeastSquareSolution(matrix_A,Y);

sdd =(1- (X(1)))*sid;

offcenter_dis = ((det_elt_counts-1)/2-X(2))*delta_u;

beta_sdd_sid_offcenterdis_deltatheta(1) = beta; 
beta_sdd_sid_offcenterdis_deltatheta(2) = sdd; 
beta_sdd_sid_offcenterdis_deltatheta(3) = sid; 
beta_sdd_sid_offcenterdis_deltatheta(4) = offcenter_dis;
beta_sdd_sid_offcenterdis_deltatheta(5) = delta_theta;



