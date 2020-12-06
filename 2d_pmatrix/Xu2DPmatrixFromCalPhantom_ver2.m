function status = Xu2DPmatrixFromCalPhantom_ver2(config_pmatrix_name,config_fbp_name,s_date)

if nargin == 2
    s_date = [];
else
end

status = 0;
%%
pmatrix_para = XuReadJsonc(config_pmatrix_name);
N_bbs = pmatrix_para.NumberOfBBs;% number of bbs in the phantom
delta_theta =  pmatrix_para.AngularInterval;%estimated angular interval in degrees
rec_cal_phan_name  = pmatrix_para.ReconCalPhanImage;
ref_cal_phan_name  = pmatrix_para.ReferenceCalPhanImage;
%%


fbp_para = XuReadJsonc(config_fbp_name);
views = fbp_para.Views;
total_angle = fbp_para.TotalScanAngle;
sdd_o = fbp_para.SourceDetectorDistance;
sid_o = fbp_para.SourceIsocenterDistance;
offcenter_o = fbp_para.DetectorOffcenter;
delta_u = fbp_para.DetectorElementSize;
det_elt_count = fbp_para.SinogramWidth;
image_rotation = fbp_para.ImageRotation;
img_dim = fbp_para.ImageDimension;
img_size = fbp_para.ImageSize;
pixel_size = img_size/img_dim;
slice_count = fbp_para.SliceCount;

%% generate x y positions from the pcd cbct image and the reference mdct image
rec_cal_phantom = XuReadRaw(rec_cal_phan_name,...
    [img_dim img_dim slice_count],'float32');
rec_cal_phantom=mean(rec_cal_phantom,3);
[x_coor, y_coor] = XuGetBBPosition(rec_cal_phantom,pmatrix_para.ReconCalPhanImageThreshold,N_bbs);

xy_coor_measured_sorted = XuArrangeBBPosition(x_coor,y_coor,N_bbs,delta_theta);

rec_cal_phantom_truth = XuReadRaw(ref_cal_phan_name,...
    [img_dim img_dim 1],'float32');
[x_coor_truth, y_coor_truth] = XuGetBBPosition(rec_cal_phantom_truth,pmatrix_para.ReferenceCalPhanImageThreshold,N_bbs);

xy_coor_truth_sorted = XuArrangeBBPosition(x_coor_truth,y_coor_truth,N_bbs,delta_theta);

%% generate fitted x y positions
matrix_A = [XuTallVector(xy_coor_truth_sorted(:,2)),XuTallVector(xy_coor_truth_sorted(:,3)),ones(11,1)];
transform_for_x = XuLeastSquareSolution(matrix_A,xy_coor_measured_sorted(:,2));
transform_for_y = XuLeastSquareSolution(matrix_A,xy_coor_measured_sorted(:,3));
x_coor_fitted = matrix_A*transform_for_x;
y_coor_fitted = matrix_A*transform_for_y;
x_real_image = (y_coor_fitted-(img_dim/2+0.5))*pixel_size;
y_real_image = ((img_dim/2+0.5)-x_coor_fitted)*pixel_size;

%% read sinogram

sgm = XuReadRaw(pmatrix_para.SinogramCalPhanName,[fbp_para.SinogramWidth fbp_para.SinogramHeight]);

%%
pmatrix_collect = [];
pmatrix_collect_est = [];%reference p matrix

pb=MgCmdLineProgressBar('Processing view#');
for view_idx =1:views
    pb.print(view_idx,views);
    
    beta = deg2rad( total_angle/views*(view_idx-1)+image_rotation);
    
    paras_est = Xu2DPMatrixEstimateParas(beta,sdd_o,sid_o,...
        offcenter_o,det_elt_count,delta_u);
    %a rough estimate of the x_do, x_s and e_u
    
    p_matrix_est = Xu2DPMatrixGetFromSolution(paras_est,delta_u);
    %get an estimated p matrix from the estimated paras
    
    temp_su_s = p_matrix_est*[x_real_image';y_real_image';ones(1,N_bbs)];
    u_est = temp_su_s(1,:)./temp_su_s(2,:);%estimated u values
    
    %make the base line of the sinogram to zero
    trend = medfilt1(sgm(:,view_idx),25 * det_elt_count/1280);
    line_after_detrend = sgm(:,view_idx)-trend;
    %     plot(line_after_detrend);
    %     ylim([-0.05 0.2]);
    %     xlim([0 1280]);
    
    u_measured = Xu2DPamtrixGetMeasuredu(line_after_detrend, pmatrix_para.SpikeDetectionThreshold);
    
%     if length(u_measured)~=11
%         overlap_idx = Xu2DPmatrixMatchBBsFindOverlapIdx(u_measured, u_est, x_real_image, y_real_image);
%         u_measured = Xu2DPamtrixGetMeasuredu(line_after_detrend, pmatrix_para.SpikeDetectionThreshold,overlap_idx);
%         %plot(line_after_detrend);
%         %ylim([-0.05 0.2]);
%         %xlim([180 1000]);
%     end
    
    [u_measured, u_est_adj, x_real_image_adj,y_real_image_adj] = ...
        Xu2DPmatrixMatchBBswithu(u_measured, u_est, x_real_image, y_real_image);
    %adjust the measured u and x y points (since some points may overlap with each other)
    
    linearity_rec(view_idx)= XuRSquared(u_measured,u_est_adj);
    
    p_matrix_2d_solved = Xu2DPmatrixLeastSquare(x_real_image_adj,y_real_image_adj,...
        u_measured,delta_u);
    
    %AAA  = Xu2DPmatrixGetSDDSIDetcFromPmatrixInOne(p_matrix_2d_solved,1280);
    
    if isfield(pmatrix_para,'BadViewIndexForTest')
        
        if ismember(view_idx,pmatrix_para.BadViewIndexForTest)
            p_matrix_2d_solved = ones(2,3);
        end
        
    end
    
    
    p_matrix_1d = reshape(Xu2DPmatrixTo3D(p_matrix_2d_solved)',[1,12]);
    p_matrix_1d_est = reshape(Xu2DPmatrixTo3D(p_matrix_est)',[1,12]);
    
    pmatrix_collect=[pmatrix_collect;p_matrix_1d];
    pmatrix_collect_est=[pmatrix_collect_est;p_matrix_1d_est];
    
    %u_rec(:,:,view_idx)= [u_measured, u_est_adj];
    
end


%detect bad views
figure();
plot(linearity_rec,'-');
ylim([1-1e-2 1]);

if isfield(pmatrix_para,'bad_view_r2_threshold')
    bad_view_idx = find((linearity_rec)<pmatrix_para.bad_view_r2_threshold);
else
    bad_view_idx = find((linearity_rec)<0.999);
end

if isfield(pmatrix_para,'BadViewIndex')
    bad_view_idx = [bad_view_idx, (pmatrix_para.BadViewIndex)'];
end

disp(['bad views are: #' num2str(bad_view_idx)]);


pmatrix_collect_final = pmatrix_collect;

for idx = 1:12
    pmatrix_collect_final(:,idx) = XuRemoveBadIdx(pmatrix_collect(:,idx),bad_view_idx);
    %pmatrix_collect_final(1:end,idx)=smooth(pmatrix_collect_final(1:end,idx),15,'rloess');
    %pmatrix_collect_final(:,idx)=medfilt1(pmatrix_collect_final(:,idx),15);
end
figure();
plot(pmatrix_collect_final(:,12))


%%

for view_idx =1:views
    
    pmatrix_3d=reshape(pmatrix_collect_final(view_idx,:),[4,3]);
    pmatrix_3d = pmatrix_3d';
    pmatrix_2d = Xu3DPmatrixTo2D(pmatrix_3d);
    
    [beta(view_idx), sdd(view_idx), sid(view_idx),...
        offcenter_dis(view_idx), delta_theta(view_idx)] =...
        Xu2DPmatrixGetSDDSIDetcFromPmatrix(pmatrix_2d,det_elt_count);
    
end
%
beta_diff = XuWrappAngle(diff(beta));
beta_deg = radtodeg([beta(1),beta(1)+cumsum(beta_diff)]);
delta_theta_deg = radtodeg(delta_theta);

if isfield(pmatrix_para,'SmoothSpan')
    
    sdd = smooth(sdd,pmatrix_para.SmoothSpan);
    sid = smooth(sid,pmatrix_para.SmoothSpan);
    
    %offcenter_dis = smooth(offcenter_dis,pmatrix_para.SmoothSpan);
    
    delta_theta_deg=smooth(delta_theta_deg,pmatrix_para.SmoothSpan);
    
    beta_diff = diff(beta_deg);
    beta_diff_smooth = smooth(beta_diff,pmatrix_para.SmoothSpan);
    beta_diff_smooth = [beta_deg(1); beta_diff_smooth];
    beta_deg = cumsum(beta_diff_smooth);
    
    
    pmatrix_collect_final=[];
    for idx = 1:views
        paras = Xu2DPMatrixEstimateParas(deg2rad(beta_deg(idx)),sdd(idx),sid(idx),offcenter_dis(idx),det_elt_count,delta_u,deg2rad(delta_theta_deg(idx)));
        pmatrix_2d = Xu2DPMatrixGetFromSolution(paras,delta_u);
        pmatrix_1d = reshape(Xu2DPmatrixTo3D(pmatrix_2d)',[1,12]);
        pmatrix_collect_final=[pmatrix_collect_final;pmatrix_1d];
    end
end

figure();
plot(sid);
ylabel('sid');

figure();
plot(sdd);
ylabel('sdd');

figure();
plot(offcenter_dis);
ylabel('offcenter dis');


%% Save pmatrix and other parameters
save_folder = ['paras_and_pmatrix/' s_date];
mkdir(save_folder);

pmatrix_collect_final_t = pmatrix_collect_final';
pmatrix_collect_est_t = pmatrix_collect_est';
struc_temp.Value = pmatrix_collect_final_t(:);
XuStructToJsonc([save_folder '/pmatrix_file.jsonc'],struc_temp);
%pmatrix_para.PMatrix = pmatrix_collect_est_t(:);
%XuStructToJsonc('pmatrix_est_file.jsonc',pmatrix_para);

struc_temp.Value = sid;
XuStructToJsonc([save_folder '/sid_file.jsonc'],struc_temp);
disp(['Mean SID is ' num2str(mean(sid))]);

struc_temp.Value = sdd;
XuStructToJsonc([save_folder '/sdd_file.jsonc'],struc_temp);
disp(['Mean SDD is ' num2str(mean(sdd))]);

struc_temp.Value = offcenter_dis;
XuStructToJsonc([save_folder '/offcenter_file.jsonc'],struc_temp);

disp(['Mean Offcenter is ' num2str(mean(offcenter_dis))]);

struc_temp.Value = (delta_theta_deg);
XuStructToJsonc([save_folder '/delta_theta_file.jsonc'],struc_temp);
disp(['Scan Angle is ' num2str(mean(beta_deg(end)-beta_deg(1))/(views-1)*views)]);

struc_temp.Value = (beta_deg);
XuStructToJsonc([save_folder '/scan_angle.jsonc'],struc_temp);

%%
mkdir('temp_config');
fbp_para = XuReadJsonc(config_fbp_name);
fbp_para.OutputFilePrefix = 'measured_p_';
fbp_para.PMatrixFile = [save_folder '/pmatrix_file.jsonc'];
% 
XuStructToJsonc('temp_config\config_mgfbp_w_measured_pmatrix.jsonc',fbp_para);
!mgfbp.exe temp_config\config_mgfbp_w_measured_pmatrix.jsonc

%%
status=1;