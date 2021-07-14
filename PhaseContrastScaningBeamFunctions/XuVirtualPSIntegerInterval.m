function img_sol = XuVirtualPSIntegerInterval(img_scan,coefs,shiftInterval)
%img_sol = XuVirtualPSIntegerInterval(img_scan,coefs,shift_interval)

% if the shift direction is from up to bottom, 
% flip the scanning image up-side-down. 
if shiftInterval>0
    img_shift = img_scan;
    coefs_for_shift = coefs;
else
    img_shift = flip(img_scan,1);
    coefs_for_shift = flip(coefs,1);
end

order =size(coefs,3)-1;

shiftInterval_abs = abs(shiftInterval);

height_interval_multiple = ceil(size(img_scan,1)/abs(shiftInterval))*shiftInterval_abs;
img_shift(end+1:height_interval_multiple,:,:)=0;
coefs_for_shift (end+1:height_interval_multiple,:,:)=0;

img_shift_reshape = zeros(height_interval_multiple/shiftInterval_abs,...
    size(img_scan,2),size(img_scan,3)*shiftInterval_abs);

for z_idx = 1:size(img_scan,3)
    temp = img_shift(:,:,z_idx);
    for subshift_idx = 1:shiftInterval_abs
        img_shift_reshape(:,:,(z_idx-1)*shiftInterval_abs+subshift_idx) = ...
            temp(subshift_idx:shiftInterval_abs:end,:);
    end
    
end

for vertical_idx = 1:size(img_shift_reshape,1)
    img_shift_reshape(vertical_idx,:,:) = circshift(img_shift_reshape(vertical_idx,:,:),...
        [0 0 (vertical_idx-1)*shiftInterval_abs]);
end
%imshow3D(permute(img_shift_reshape,[3,2,1]),[]);
%imshow3D(permute(img_shift_reshape,[1,3,2]),[]);
img_sol = zeros(order*2+1,size(img_shift_reshape,2),size(img_shift_reshape,3));
for horizontal_idx = 1:size(img_shift_reshape,2)
    temp = squeeze(img_shift_reshape(:,horizontal_idx,:));
    for subshift_idx = 1:shiftInterval_abs
        temp_sol = XuNonUniformPhaseStep_ver4(squeeze(coefs_for_shift(subshift_idx:shiftInterval_abs:end,horizontal_idx,:)),...
            temp(:,subshift_idx:shiftInterval_abs:end));
        img_sol(:,horizontal_idx,subshift_idx:shiftInterval_abs:end) = temp_sol;
    end
end
img_sol = permute(img_sol,[3,2,1]);

img_sol(1:shiftInterval_abs*(size(img_shift_reshape,1)-1),:,:) = [];

img_sol = XuSolRealToComplex(img_sol);