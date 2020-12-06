function pmatrix = Xu2DPMatrixGetFromSolution(matrix_elements,delta_u)
%pmatrix = Xu2DPMatrixGetFromSolution(matrix_elements,delta_u)
%matrix_elemtents should have 5 elements in the following order:
%theta, x_do, x_s, y_do, y_s;

theta = matrix_elements(1);
e_x = delta_u*cos(theta);
e_y = delta_u*sin(theta);
x_do = matrix_elements(2);
x_s = matrix_elements(3);
y_do = matrix_elements(4);
y_s = matrix_elements(5);

matrix_A = [e_x, x_do-x_s;e_y, y_do-y_s];

pmatrix = zeros(2,3);

pmatrix (:,1:2)= inv(matrix_A);
pmatrix (:,3) = -inv(matrix_A)*[x_s;y_s];