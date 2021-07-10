function status = XuImshow3DSlice(img,slice_idx,display_range)

if nargin ==2
    display_range = [];
end

imshow(img(:,:,slice_idx),display_range);

status=1;

end