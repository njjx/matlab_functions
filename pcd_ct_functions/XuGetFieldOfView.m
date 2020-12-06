function field_of_view_in_pixel = XuGetFieldOfView(s_config)
%field_of_view_in_pixel = XuGetFieldOfView(s_config)

recon_para = XuReadJsonc(s_config);

distance_of_farmost_pixel = recon_para.SinogramWidth/2*...
    recon_para.DetectorElementSize-abs(recon_para.DetectorOffcenter);

distance_from_tube_to_farmost_pixel = sqrt(recon_para.SourceDetectorDistance^2+...
    distance_of_farmost_pixel^2);

field_of_view_in_mm = recon_para.SourceIsocenterDistance*...
    distance_of_farmost_pixel/distance_from_tube_to_farmost_pixel;

field_of_view_in_pixel = field_of_view_in_mm/recon_para.PixelSize;