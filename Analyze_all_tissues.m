function Analyze_all_tissues(T2_1_map, T2_2_map, S0_map, seg)
fprintf('\n===== Parameter Estimates with 95%% Confidence Intervals =====\n');
fprintf('Tissue        | Parameter     | Mean    | 95%% CI           | n\n');
fprintf('------------------------------------------------------------------\n');
%% 1. Estimate on white matter
wm_mask = seg.img(:, :, :, 4);
wm_voxels = wm_mask(:, :, :) > 0.6;

% estimate on T2 short
[mean_T2_wm,CI_lower_wm,CI_upper_wm,n_samples_wm] = calculate_parameter_estimate(T2_1_map,wm_voxels);
fprintf('%-14s| %-14s| %-8.3f| %.3f - %-8.3f| %d\n', ...
        'White Matter', 'T2 short (ms)', mean_T2_wm, CI_lower_wm, CI_upper_wm, n_samples_wm);

% estimate on T2 long
[mean_T2_wm,CI_lower_wm,CI_upper_wm,n_samples_wm] = calculate_parameter_estimate(T2_2_map,wm_voxels);
fprintf('%-14s| %-14s| %-8.3f| %.3f - %-8.3f| %d\n', ...
        'White Matter', 'T2 long (ms)', mean_T2_wm, CI_lower_wm, CI_upper_wm, n_samples_wm);

% estimate on S0
[mean_S0_wm,CI_lower_wm,CI_upper_wm,n_samples_wm] = calculate_parameter_estimate(S0_map,wm_voxels);
fprintf('%-14s| %-14s| %-8.3f| %.3f - %-8.3f| %d\n', ...
        'White Matter', 'S0', mean_S0_wm, CI_lower_wm, CI_upper_wm, n_samples_wm);

%% 2. Estimate on grey matter
gm_mask = seg.img(:, :, :, 3);
gm_voxels = gm_mask(:, :, :) > 0.6;

% estimate on T2 short
[mean_T2_gm,CI_lower_gm,CI_upper_gm,n_samples_gm] = calculate_parameter_estimate(T2_1_map,gm_voxels);
fprintf('%-14s| %-14s| %-8.3f| %.3f - %-8.3f| %d\n', ...
        'Grey Matter', 'T2 short (ms)', mean_T2_gm, CI_lower_gm, CI_upper_gm, n_samples_gm);

% estimate on T2 long
[mean_T2_gm,CI_lower_gm,CI_upper_gm,n_samples_gm] = calculate_parameter_estimate(T2_2_map,gm_voxels);
fprintf('%-14s| %-14s| %-8.3f| %.3f - %-8.3f| %d\n', ...
        'Grey Matter', 'T2 long (ms)', mean_T2_gm, CI_lower_gm, CI_upper_gm, n_samples_gm);

% estimate on S0
[mean_S0_gm,CI_lower_gm,CI_upper_gm,n_samples_gm] = calculate_parameter_estimate(S0_map,gm_voxels);
fprintf('%-14s| %-14s| %-8.3f| %.3f - %-8.3f| %d\n', ...
        'Grey Matter', 'S0', mean_S0_gm, CI_lower_gm, CI_upper_gm, n_samples_gm);

%% 3. Estimate on CSF
csf_mask = seg.img(:, :, :, 2);
csf_voxels = csf_mask(:, :, :) > 0.6;

% estimate on T2 short
[mean_T2_csf,CI_lower_csf,CI_upper_csf,n_samples_csf] = calculate_parameter_estimate(T2_1_map,csf_voxels);
fprintf('%-14s| %-14s| %-8.3f| %.3f - %-8.3f| %d\n', ...
        'CSF', 'T2 short (ms)', mean_T2_csf, CI_lower_csf, CI_upper_csf, n_samples_csf);

% estimate on T2 long
[mean_T2_csf,CI_lower_csf,CI_upper_csf,n_samples_csf] = calculate_parameter_estimate(T2_2_map,csf_voxels);
fprintf('%-14s| %-14s| %-8.3f| %.3f - %-8.3f| %d\n', ...
        'CSF', 'T2 long (ms)', mean_T2_csf, CI_lower_csf, CI_upper_csf, n_samples_csf);

% estimate on S0
[mean_S0_csf,CI_lower_csf,CI_upper_csf,n_samples_csf] = calculate_parameter_estimate(S0_map,csf_voxels);
fprintf('%-14s| %-14s| %-8.3f| %.3f - %-8.3f| %d\n', ...
        'CSF', 'S0', mean_S0_csf, CI_lower_csf, CI_upper_csf, n_samples_csf);
end

