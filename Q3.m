% read in the images
r=load_nii('case01-qt2_reg.nii');
r.img(r.img(:)<0)=0;
images = r.img;
brain_mask = load_nii('case01-mask.nii');
TEs=load('case01-TEs.txt');
% Load the segmentation file
seg = load_nii('case01-seg.nii');

%% 1. model1: NLLS
[T2_1_map, T2_2_map, S0_map, V1_map, mean_residual] = estimateT2_multipoint_NLLS_bicomponent(images, TEs, brain_mask.img);
fprintf('\n===== Fit with NLLS =====\n');
Analyze_all_tissues(T2_1_map, T2_2_map, S0_map, V1_map, seg);

%% 2. model2: NLLS(fixedT2)
[T2_1_map, T2_2_map, S0_map, V1_map, mean_residual] = estimateT2_fixedT2s(images, TEs, brain_mask.img);
fprintf('\n===== Fit with NLLS(fixedT2) =====\n');
Analyze_all_tissues(T2_1_map, T2_2_map, S0_map, V1_map, seg);

%% 3. model3: Weighted LS(fixedT2)
[T2_1_map, T2_2_map, S0_map, V1_map, mean_residual] = estimateT2_fixedT2s_WLS(images, TEs, brain_mask.img);
fprintf('\n===== Fit with Weighted LS(fixedT2) =====\n');
Analyze_all_tissues(T2_1_map, T2_2_map, S0_map, V1_map, seg);