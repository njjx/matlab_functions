function img_input = XuCorrectVarianUserSync(img_input,frame_num)

for frame_idx = 1:frame_num
    temp = img_input(:,:,frame_idx);
    first_column_value = temp(:,1);
    shift_idx=sum(first_column_value>10000);
    temp = circshift(temp,[-shift_idx,0]);
    temp =XuCorrectVarianDeadPixel(temp);
    
    img_input(:,:,frame_idx ) = temp;
end