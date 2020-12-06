function solution = Xu2DPmatrixSolve(matrix_elements_estimate,delta_u,x_obj,y_obj,u)
%Xu2DPmatrixSolve(matrix_elements_estimate,delta_u,x_obj,y_obj,u)
%matrix_elements_estimate should have 5 elements in the following order:
%theta, x_do, x_s, y_do, y_s;

options = optimoptions('fsolve','Display','none','Algorithm','levenberg-marquardt');

solution = fsolve(@(x) Xu2DPmatrixCalcFunction(x,delta_u,x_obj,y_obj,u), matrix_elements_estimate, options);