function output_vector = XuPolyValForTwoInputs(coeff, input_vector_1,input_vector_2, order_cell)

input_vector_1 = XuTallVector(input_vector_1);
input_vector_2 = XuTallVector(input_vector_2);
coeff=squeeze(coeff);
coeff = XuTallVector(coeff);


matrix_A = [];

for idx = 1:length(order_cell)
    temp_order = order_cell{idx};
    matrix_A(:,idx) = input_vector_1.^temp_order(1).*input_vector_2.^temp_order(2);
end

output_vector = matrix_A*coeff;

%output_vector = XuTallVector(output_vector);