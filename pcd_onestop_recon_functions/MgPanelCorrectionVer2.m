function prj_corr = MgPanelCorrectionVer2(prj_postlog, material, energyBin, slice_count, truncation_left, truncation_right, protocol)
% Do the panel correction for post-log projection data.
% The correction data is for C-arm system 125 kVp with 2 mm Cu filtration.
% Threshods are 20, 55 keV without local keV convert.
% prj_postlog: post-log projection data (size: 5120 x  views x slice_count)
% material: 'PMMA' or 'Al'
% energyBin: 'TE', 'LE' or 'HE'
% prj_corr: unit mm. You need to multiply a linear attenuation coefficient
% to convert it to sinogram.
% protocol is optional

if nargin == 6
    protocol = '20sDynamicCT-SinglePixel';
else
end

switch protocol
    case '20sDynamicCT-SinglePixel' 
        input_folder = '20sDynamicCT-SinglePixel-';
    case '20sDynamicCT-HighFlux'
        input_folder = '20sDynamicCT-HighFlux-';
    otherwise
        error("Unknown protocol '%s'\n", protocal);
end

load_name = sprintf('%scali_%s.mat',input_folder, material);
variable_name = sprintf('cali_%s_%s', material, energyBin);

tmp = load(load_name, variable_name);
cali_para = tmp.(variable_name);
cali_para = cali_para';

cali_para{1720,48} = 1/2*(cali_para{1720,47}+cali_para{1720,49});

prj_corr = zeros(size(prj_postlog));

pixel_per_one_slice = round(60/slice_count);

rows = 64;
cols = 5120;

for slice_idx = 1:slice_count
    row_begin = 3+(slice_idx-1)*pixel_per_one_slice;
    row_end = 2+(slice_idx)*pixel_per_one_slice;
    for col = truncation_left:truncation_right
        temp_coef =zeros(size(cali_para{1,1}));
        for row = row_begin:row_end          
            
            temp_coef = temp_coef+cali_para{col, row};
        end
        temp_coef = temp_coef/pixel_per_one_slice*0.0185;
        prj_corr(col,:,slice_idx) = polyval(temp_coef, prj_postlog(col,:,slice_idx));
    end
end


prj_corr(isnan(prj_corr)) = 0;
prj_corr(isinf(prj_corr)) = 0;

end

