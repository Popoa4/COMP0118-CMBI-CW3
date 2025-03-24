function score = evaluate_model(T2_map, S0_map, images, TEs, running_time, seg)
    % 1. compute the residuals between the origin signal and the one
    % simulated from S0
    residuals = calculate_residuals(images, TEs, T2_map, S0_map);
    mean_residual = mean(abs(residuals(:)));
    
    % 2. standardize the time
    % normalized_time = running_time / 60;
    
    % 3. Compute the score with the weights
    % disp(T2_error_WM);
    disp(mean_residual);
    score = 0.5 * mean_residual + 0.5 * running_time;
    
    return;
end
