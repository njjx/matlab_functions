function coeff = XuPolyFitForOneInput(input_vector, output_vector, order_cell)

input_vector = XuTallVector(input_vector);
output_vector = XuTallVector(output_vector);


matrix_A = zeros(length(input_vector),length(order_cell));

for idx = 1:length(order_cell)
    temp_order = order_cell{idx};
    matrix_A(:,idx) = input_vector.^temp_order(1);
end

coeff = XuLeastSquareSolution(matrix_A, output_vector);