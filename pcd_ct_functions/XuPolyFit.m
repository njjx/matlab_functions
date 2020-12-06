function coef_output=XuPolyFit(vec_input,vec_target,order)
%coef=XuPolyFit(vec_input,vec_target,order)
%this polyfit force the zero order coeff to be zero

if size(vec_input,1)<size(vec_input,2)
    vec_input=vec_input';
end

if size(vec_target,1)<size(vec_target,2)
    vec_target=vec_target';
end

matrix_input=zeros(length(vec_input),length(order));

for idx=1:length(order)
    matrix_input(:,idx)=vec_input.^order(idx);
end

coef=(matrix_input'*matrix_input)^(-1)*matrix_input'*vec_target;

coef_output=zeros(1,round(max(order))+1);
for idx=1:length(order)
    coef_output(order(idx)+1)=coef(idx);
end

coef_output=fliplr(coef_output);