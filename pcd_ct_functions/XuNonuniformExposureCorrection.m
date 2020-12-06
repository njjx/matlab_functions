function sgm_c = XuNonuniformExposureCorrection (sgm, s_exposure_file)
%sgm_c = XuNonuniformExposureCorrection (sgm, s_exposure_file)


output_profile = importdata(s_exposure_file);
output_curve = output_profile(:,1).*output_profile(:,2);
output_curve = output_curve/mean(output_curve);

if size(sgm,2)~=length(output_curve)
    printf('Wrong exposure profile dimension!\n');
    exit();
end

sgm_c = sgm + log(output_curve');