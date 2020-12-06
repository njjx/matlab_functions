function nps_2d_corrected = Xu2DNPSCorrection(nps_2d,radius_fraction)
%nps_2d should be the one without shift
roi_size = size(nps_2d,1);
shift_distance = roi_size/2;

cov_func = fft2(nps_2d);
cov_func_shift = circshift(cov_func,[shift_distance,shift_distance]);

[mx,my] = meshgrid(-shift_distance:shift_distance-1,-shift_distance:shift_distance-1);

roi_for_trend = (mx.^2+my.^2 >= (radius_fraction*shift_distance)^2);
trend = real(XuSum2(roi_for_trend.*cov_func_shift)/XuSum2(roi_for_trend));

cov_func_shift_corr = cov_func_shift-trend;

cov_func_corr = circshift(cov_func_shift_corr,[-shift_distance,-shift_distance]);

nps_2d_corrected = real(ifft2(cov_func_corr));