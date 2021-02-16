function x = XuLeastSquareSolution(matrix_A, y)
%x = XuLeastSquareSolution(matrix_A, y)

if size(matrix_A,1)<size(matrix_A,2)
    error('Please input a tall matrix!');
end
if isvector(y)
    y=XuTallVector(y);
end
if size(matrix_A,1)~=size(y,1)
    error('Please number of rows in input matrix does not equal to the number of rows in y!');
end


x=inv(matrix_A'*matrix_A)*matrix_A'*y;
% 
% y_calc = matrix_A*x;
% relative_error = rms(y_calc(:)-y(:))/rms(y(:));
% fprintf('Relatively error is %.3f percent.\n',relative_error*100);
