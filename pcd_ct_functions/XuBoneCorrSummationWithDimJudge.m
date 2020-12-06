function img_corr = XuBoneCorrSummationWithDimJudge(img,s_jsonc_bone_fbp,s_jsonc_bone_corr, dim_or_not)

recon_para = XuReadJsonc(s_jsonc_bone_fbp);
bone_corr_para = XuReadJsonc(s_jsonc_bone_corr);
img_folder=recon_para.OutputDir;
img_dim=recon_para.ImageDimension;
img_slice_count=recon_para.SliceCount;

if dim_or_not
    rec_tb=ReadRaw([img_folder 'rec_tb-' num2str(img_dim) '-' ...
        num2str(img_dim) '-' num2str(img_slice_count), '.raw'], ...
        [img_dim img_dim img_slice_count],'float32');
    rec_bb=ReadRaw([img_folder 'rec_bb-' num2str(img_dim) '-' ...
        num2str(img_dim) '-' num2str(img_slice_count), '.raw'], ...
        [img_dim img_dim img_slice_count],'float32');
else
    rec_tb=ReadRaw([img_folder 'rec_tb', '.raw'], ...
        [img_dim img_dim img_slice_count],'float32');
    rec_bb=ReadRaw([img_folder 'rec_bb', '.raw'], ...
        [img_dim img_dim img_slice_count],'float32');
end



if length(bone_corr_para.BoneBoneCoef) == 1 && length(bone_corr_para.BoneTissueCoef) ==1
    img_corr=img+bone_corr_para.BoneBoneCoef*rec_bb+bone_corr_para.BoneTissueCoef*rec_tb;
else
    img_corr=[];
    [bb_coef, bt_coef] = meshgrid(bone_corr_para.BoneBoneCoef,bone_corr_para.BoneTissueCoef);
    idx =0;
    for ii = 1:length(bone_corr_para.BoneBoneCoef)
        for jj = 1:length(bone_corr_para.BoneTissueCoef)
            idx = idx+1;
            fprintf('index #%d-%d: bb_coeff:%f; tb_coeff:%f\n',...
                (idx-1)*img_slice_count+1,(idx)*img_slice_count,...
                bb_coef(jj,ii),bt_coef(jj,ii));
            img_temp =img+ bb_coef(jj,ii)*rec_bb + bt_coef(jj,ii)*rec_tb;
            img_corr = [img_corr, img_temp(:)];
        end
    end
    
end
