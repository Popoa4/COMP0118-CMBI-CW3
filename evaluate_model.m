function score = evaluate_model(T2_map, S0_map, images, TEs, running_time, seg)
    % 1. compute the error of the T2 of WM
    wm_mask = seg.img(:, :, :, 4);
    reference_T2 = 70; % ms
    flat_T2_Map = squeeze(T2_map(:, :, :)); 
    wm_voxels = wm_mask(:, :, :) > 0.5;
    mean_wm_T2 = mean(flat_T2_Map(wm_voxels));
    T2_error_WM = abs(mean_wm_T2 - reference_T2);

    % 2. compute the error of the T2 of GM
    gm_mask = seg.img(:, :, :, 3);
    reference_T2 = 80; % ms
    gm_voxels = gm_mask(:, :, :) > 0.5;
    mean_gm_T2 = mean(flat_T2_Map(gm_voxels));
    T2_error_GM = abs(mean_gm_T2 - reference_T2);

    % 3. compute the error of the T2 of CSF
    csf_mask = seg.img(:, :, :, 2);
    reference_T2 = 2000; % ms
    csf_voxels = csf_mask(:, :, :) > 0.5;
    mean_csf_T2 = mean(flat_T2_Map(csf_voxels));
    T2_error_CSF = abs(mean_csf_T2 - reference_T2);

    T2_error = (T2_error_WM+T2_error_GM+T2_error_CSF)/3;
    
    % 4. compute the residuals between the origin signal and the one
    % simulated from S0
    residuals = calculate_residuals(images, TEs, T2_map, S0_map);
    mean_residual = mean(abs(residuals(:)));
    
    % 5. standardize the time
    % normalized_time = running_time / 60;
    
    % 4. Compute the score with the weights
    score = 0.6 * T2_error + 0.2 * mean_residual + 0.2 * running_time;
    
    return;
end
