function prj_corr = MgPanelCorrection(prj_postlog, material, energyBin)
% Do the panel correction for post-log projection data.
% The correction data is for C-arm system 125 kVp with 2 mm Cu filtration.
% Threshods are 20, 55 keV without local keV convert.
% prj_postlog: post-log projection data (size: 64 x 5120 x views)
% material: 'PMMA' or 'Al'
% energyBin: 'TE', 'LE' or 'HE'
% prj_corr: unit mm. You need to multiply a linear attenuation coefficient
% to convert it to sinogram.

load_name = sprintf('cali_%s.mat', material);
variable_name = sprintf('cali_%s_%s', material, energyBin);

tmp = load(load_name, variable_name);
cali_para = tmp.(variable_name);

prj_corr = zeros(size(prj_postlog));

rows = 64;
cols = 5120;

% do the correction
for row = 1:rows
    for col = 1:cols
        prj_corr(row,col,:) = polyval(cali_para{row, col}, prj_postlog(row, col,:));
    end
end

prj_corr(isnan(prj_corr)) = 0;
prj_corr(isinf(prj_corr)) = 0;

end

