function pmatrix = Xu2DPmatrixLeastSquare(x,y,u,delta_u)

data_counts = length(u);
u = XuTallVector(u);
x = XuTallVector(x);
y = XuTallVector(y);

matrix_A = [x,y,ones(data_counts,1),-u.*x,-u.*y];
Y = u;

solution = XuLeastSquareSolution(matrix_A,Y);

pmatrix_est = [solution(1),solution(2), solution(3);solution(4), solution(5),1];

matrix_for_eu = pmatrix_est(:,1:2);

inv_matrix_for_eu = inv(matrix_for_eu);
e_u = inv_matrix_for_eu(:,1);
ratio = delta_u / norm(e_u,2);
pmatrix = pmatrix_est/ratio;






