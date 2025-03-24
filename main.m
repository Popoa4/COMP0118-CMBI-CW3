%% Load the data
% read in the images
r=load_nii('case01-qt2_reg.nii');
r.img(r.img(:)<0)=0;
images = r.img;

% size(images)

TEs=load('case01-TEs.txt');
% disp(TEs);

%% Question 1

% Select a slice
slice_num = round(size(images,3)/2); % A central slice

% Visualize how the imaging data change with different echo-times
VaryingEchoTime(images, TEs, slice_num)

% Choose a voxel
x = 50;
y = 50;
z = slice_num;

% Extract the signal for all the TE
signal_voxel = squeeze(images(x, y, z, :)); 

% Plot the time intensity curve for a single voxel
figure;
plot(TEs, signal_voxel, 'x-', 'LineWidth', 0.5);
xlabel('Echo Time (ms)');
ylabel('Signal Intensity');
title('Time-Intensity Curve for one voxel');
grid on;

% Choose a ROI
x_range = 25:45; 
y_range = 50:70; 
z_slice = slice_num; 

% Compute mean intensity for each TE in the ROI
roi_signal = squeeze(mean(mean(images(x_range, y_range, z_slice, :), 1), 2));

% Plot the time intensity curve for the selected ROI
figure;
plot(TEs, roi_signal, 'x-', 'LineWidth', 0.5);
xlabel('Echo Time (ms)');
ylabel('Mean Signal Intensity');
title('Time-Intensity Curve for selected ROI');
grid on;

% Mean of the signals for the brain
mean_signal = squeeze(mean(mean(mean(images,1),2),3)); 

% Plot the time intensity curve for the mean brain signal
figure;
plot(TEs, mean_signal, 'x-', 'LineWidth', 0.5);
xlabel('Echo Time (ms)');
ylabel('Mean Signal Intensity');
title('Average Time-Intensity Curve across the brain');
grid on;

% Load the segmentation file
seg = load_nii('case01-seg.nii');

% Select the white matter mask
wm_mask = seg.img(:, :, :, 4);

% Initialize
roi_signal = zeros(size(TEs)); 

for t = 1:length(TEs)
    current_image = squeeze(images(:, :, z_slice, t)); 
    wm_voxels = wm_mask(:, :, z_slice) > 0.7; % Select only the voxels that have a probability > 0.5
    roi_signal(t) = mean(current_image(wm_voxels)); 
end

% Plot the time intensity curve for the white matter
figure;
plot(TEs, roi_signal, 'x-', 'LineWidth', 0.5);
xlabel('Echo Time (ms)');
ylabel('Mean Signal Intensity');
title('Time-Intensity Curve for WM');
grid on;

%% Question 2
brain_mask = load_nii('case01-mask.nii');
img_masked = images.*brain_mask.img;
% 0. two point
id_img1 = 1;
id_img2 = 10;
tic;
[T2_2point] = estimateT2_twopoints(img_masked(:,:,:,id_img1), img_masked(:,:,:,id_img2), TEs(id_img1), TEs(id_img2));
time_2point = toc;

figure;
imagesc(T2_2point(:,:,round(end/2))); 
title('Two-point'); 
colorbar; 
clim([0 100]);

% 1. Least Square
tic;
[T2_linear, S0_linear] = estimateT2_multipoint_linear(img_masked, TEs);
time_linear = toc;
score_linear = evaluate_model(T2_linear, S0_linear, img_masked, TEs, time_linear, seg);

figure;
subplot(1,2,1);
imagesc(T2_linear(:,:,round(end/2))); 
title('T2 by Linear LS'); 
colorbar; 
clim([0 100]);

subplot(1,2,2);
imagesc(S0_linear(:,:,round(end/2)));
colorbar;
title('S0 Map by Linear LS');
colormap(jet);
% 2. Weighted least square
tic;
[T2_weighted, S0_weighted] = estimateT2_multipoint_weighted(img_masked, TEs);
time_weighted = toc;
score_weighted = evaluate_model(T2_weighted, S0_weighted, img_masked, TEs, time_weighted, seg);

figure;
subplot(1,2,1);
imagesc(T2_weighted(:,:,round(end/2))); 
title('T2 by Weighted LS'); 
colorbar; 
clim([0 100]);

subplot(1,2,2);
imagesc(S0_weighted(:,:,round(end/2)));
colorbar;
title('S0 Map by Weighted LS');
colormap(jet);

% 3. non-negative least-squares
tic;
[T2_NNLS, S0_NNLS] = estimateT2_multipoint_NNLS(img_masked, TEs);
time_NNLS = toc;
score_NNLS = evaluate_model(T2_NNLS, S0_NNLS, img_masked, TEs, time_NNLS, seg);

figure;
subplot(1,2,1);
imagesc(T2_NNLS(:,:,round(end/2))); 
title('T2 by NNLS'); 
colorbar; 
clim([0 100]);

subplot(1,2,2);
imagesc(S0_NNLS(:,:,round(end/2)));
colorbar;
title('S0 Map by NNLS');
colormap(jet);

% 4. non-linear least squares
tic;
[T2_NLLS, S0_NLLS] = estimateT2_multipoint_NLLS(img_masked, TEs);
time_NLLS = toc;
score_NLLS = evaluate_model(T2_NLLS, S0_NLLS, img_masked, TEs, time_NLLS, seg);

figure;
subplot(1,2,1);
imagesc(T2_NLLS(:,:,round(end/2))); 
title('T2 by NLLS'); 
colorbar; 
clim([0 100]);

subplot(1,2,2);
imagesc(S0_NLLS(:,:,round(end/2)));
colorbar;
title('S0 Map by NLLS');
colormap(jet);

% Print the fit time
fprintf('Two-point method: %.2f seconds\n', time_2point);
fprintf('Least Square method: %.2f seconds\n', time_linear);
fprintf('Weighted least square method: %.2f seconds\n', time_weighted);
fprintf('non-negative least-squares method: %.2f seconds\n', time_NNLS);
fprintf('non-linear least squares method: %.2f seconds\n', time_NLLS);

% Print and compare the scores of the models
fprintf('Least Square method score: %.2f\n', score_linear);
fprintf('Weighted least square method score: %.2f\n', score_weighted);
fprintf('non-negative least-squares score: %.2f\n', score_NNLS);
fprintf('non-linear least squares score: %.2f\n', score_NLLS);
