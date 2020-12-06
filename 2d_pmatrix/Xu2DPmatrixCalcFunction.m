function err = Xu2DPmatrixCalcFunction(matrix_elements,delta_u,x_obj,y_obj,u)
%Xu2DPmatrixCalcFunction(matrix_elements,delta_u,x_obj,y_obj,u)
%matrix_elemtents should have 5 elements in the following order:
%theta, x_do, x_s, y_do, y_s;
%'do' indicates the origin of the detector elemetemtents
%'s' indicates the source
%all distances should be with unit 'mm'
%delta_u is the length one detector elements
%then 
%e_x = delta_u*cos(theta);
%e_y = delta_u*sin(theta);
%basic equation is [u*e_x+ (x_do - x_s)]*[y_obj-y_s]=[u*e_y+ (y_do - y_s)]*[x_obj-x_s]
%Then u*y_obj*e_x - u*x_obj*e_y + y_obj*(x_do-x_s)-x_obj*(y_do-y_s)
%-u*e_x*y_s+u*e_y*x_s - (x_do-x_s)*y_s+ (y_do-y_s)*x_s =0;

theta = matrix_elements(1);
e_x = delta_u*cos(theta);
e_y = delta_u*sin(theta);
x_do = matrix_elements(2);
x_s = matrix_elements(3);
y_do = matrix_elements(4);
y_s = matrix_elements(5);

err = u(:).*y_obj(:).*e_x - u(:).*x_obj(:).*e_y + ...
    y_obj(:)*(x_do-x_s)-x_obj(:)*(y_do-y_s) ...
    -u(:)*e_x*y_s + u(:)*e_y*x_s ...
    -(x_do)*y_s+ (y_do)*x_s;


