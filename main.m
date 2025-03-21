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
plot(TEs, signal_voxel, '-', 'LineWidth', 2);
xlabel('Echo Time (ms)');
ylabel('Signal Intensity');
title('T2 Decay in a Single Voxel');
grid on;

% Choose a ROI
x_range = 40:60; 
y_range = 40:60; 
z_slice = slice_num; 

% Compute mean intensity for each TE in the ROI
roi_signal = squeeze(mean(mean(images(x_range, y_range, z_slice, :), 1), 2));

% Plot the time intensity curve for the selected ROI
figure;
plot(TEs, roi_signal, '-', 'LineWidth', 2, 'Color', 'k');
xlabel('Echo Time (ms)');
ylabel('Mean Signal Intensity');
title('T2 Decay Curve for Selected ROI');
grid on;

% Mean of the signals for the brain
mean_signal = squeeze(mean(mean(mean(images,1),2),3)); 

% Plot the time intensity curve for the mean brain signal
figure;
plot(TEs, mean_signal, '-', 'LineWidth', 2);
xlabel('Echo Time (ms)');
ylabel('Mean Signal Intensity');
title('Average T2 Decay Across the Whole Brain');
grid on;

% Load the segmentation file
seg = load_nii('case01-seg.nii');

% Select the white matter mask
wm_mask = seg.img(:, :, :, 4);

% Initialize
roi_signal = zeros(size(TEs)); 

for t = 1:length(TEs)
    current_image = squeeze(images(:, :, z_slice, t)); 
    wm_voxels = wm_mask(:, :, z_slice) > 0.5; % Select only the voxels that have a probability > 0.5
    roi_signal(t) = mean(current_image(wm_voxels)); 
end

% Plot the time intensity curve for the white matter
figure;
plot(TEs, roi_signal, '-', 'LineWidth', 2, 'Color', 'k');
xlabel('Echo Time (ms)');
ylabel('Mean Signal Intensity');
title('T2 Decay Curve for White Matter');
grid on;

%% Question 2

id_img1 = 1;
id_img2 = 5;
[T2_2point] = estimateT2_twopoints(images(:,:,:,id_img1), images(:,:,:,id_img2), TEs(id_img1), TEs(id_img2));
 
[T2_linear, S0_linear] = estimateT2_multipoint_linear(images, TEs);

figure;
subplot(1,2,1);
imagesc(T2_2point(:,:,round(end/2))); 
title('Two-point'); 
colorbar; 
clim([0 100]);

subplot(1,2,2);
imagesc(T2_linear(:,:,round(end/2))); 
title('Linear LS'); 
colorbar; 
clim([0 100]);
