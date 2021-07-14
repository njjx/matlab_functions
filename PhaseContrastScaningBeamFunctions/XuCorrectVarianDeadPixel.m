function img = XuCorrectVarianDeadPixel(img)
%img = XuCorrectVarianDeadPixel(img)
% size of img should be 1024 * 768 * frames

img(427,370,:) = 1/4*(img(426,370,:)...
    +img(428,370,:)+...
    img(427,371,:)+img(427,369,:));