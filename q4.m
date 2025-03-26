% read in the images
r=load_nii('case01-qt2_reg.nii');
r.img(r.img(:)<0)=0;
images = r.img;
brain_mask = load_nii('case01-mask.nii');
TEs=load('case01-TEs.txt');
% Load the segmentation file
seg = load_nii('case01-seg.nii');

[T2_1_map, S0_map, mean_residual, AIC_1comp] = estimate_T2_multipoint_NLLS_AIC(images, TEs);
[T2_1_map, T2_2_map, mean_residual, AIC_2comp] = estimate_T2_multipoint_NLLS_bicomponent_AIC(images, TEs, mask)
disp(['AIC for 1-compartment model: ', num2str(AIC_1comp)]);
disp(['AIC for 2-compartment model: ', num2str(AIC_2comp)]);


if AIC_1comp < AIC_2comp
    disp('The 1-compartment model is preferred.');
else
    disp('The 2-compartment model is preferred.');
end
