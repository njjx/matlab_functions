function period_in_pixel = XuCalcPeriod(img_roi,stripe_direction)
%img_roi is a square matrix with ODD number cols and rows
%Fringe stripes are horizontal by default
%stripe_direction can be 'horizontal' or 'vertical'

if nargin ==1
    stripe_direction = 'horizontal';
end

switch stripe_direction
    case 'horizontal'
    case 'vertical'
        img_roi = img_roi';
    otherwise
        error('stripe_direction can only be ''horizontal'' or ''vertical'' !');
end

roi_size =size(img_roi,1);

shift_dis = (roi_size-1)/2;

img_roi = img_roi-XuMean2(img_roi);

%imshow(img_roi,[]);

img_fft = fft2(img_roi);
img_fft = circshift(img_fft,[shift_dis shift_dis]);
%imshow(abs(img_fft),[]);

max_val = max(sum(abs(img_fft),2));

projection_image_bw = sum(abs(img_fft),2)>(max_val*0.3);
temp_s=regionprops(projection_image_bw',sum(abs(img_fft),1), 'WeightedCentroid');

center = temp_s(1).WeightedCentroid;

period_in_pixel = abs(length(img_fft)/(center(1)-(length(img_fft)+1)/2));