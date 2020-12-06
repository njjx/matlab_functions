function prj_corr = XuPanelCorrection(prj_postlog, material, energyBin, slice_count, truncation_left, truncation_right, protocol)
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
        protocal_name = '20sDynamicCT-SinglePixel-';
    case '20sDynamicCT-HighFlux'
        protocal_name = '20sDynamicCT-HighFlux-';
    case '7sDynamicCT-SinglePixel'
        protocal_name = '7sDynamicCT-SinglePixel-';
    case '7sDynamicCT-SinglePixel-2'
        protocal_name = '7sDynamicCT-SinglePixel-2-';
    otherwise
        protocal_name = sprintf('%s-',protocol);
end

load_name = sprintf('%scali_%s_xu.mat',protocal_name, material);
variable_name = sprintf('cali_%s', upper(energyBin));

tmp = load(load_name, variable_name);
cali_para = tmp.(variable_name);

prj_postlog(isnan(prj_postlog)) = 0;
prj_postlog(isinf(prj_postlog)) = 0;

prj_corr = zeros(size(prj_postlog));

pixel_per_one_slice = round(60/slice_count);

rows = 64;
cols = 5120;

mu_pmma = 1/mean2(cali_para(3:62,truncation_left:truncation_right,end-1));

for slice_idx = 1:slice_count
    %slice_idx
    row_begin = 3+(slice_idx-1)*pixel_per_one_slice;
    row_end = 2+(slice_idx)*pixel_per_one_slice;
    for col = truncation_left:truncation_right
        %col
        temp_coef =zeros(size(squeeze(cali_para(1,1,:))));
        for row = row_begin:row_end          
            
            temp_coef = temp_coef+squeeze(cali_para(row,col,:));
        end
        temp_coef = temp_coef/pixel_per_one_slice*mu_pmma;
        %temp_coef(end)=0;
        %temp_coef(1)=0;
        prj_corr(col,:,slice_idx) = XuPolyValForOneInput(temp_coef, prj_postlog(col,:,slice_idx));
    end
end


prj_corr(isnan(prj_corr)) = 0;
prj_corr(isinf(prj_corr)) = 0;

end

