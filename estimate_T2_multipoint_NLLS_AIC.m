function [T2_map, S0_map, mean_residual, AIC] = estimateT2_multipoint_NLLS_AIC(images, TEs)
    [rows, cols, slices, num_echoes] = size(images);
    
    TEs = double(TEs);
    T2_map = zeros(rows, cols, slices, 'double');
    S0_map = zeros(rows, cols, slices, 'double');
    
    % Initial parameter guess: [S0, T2]
    initial_guess = double([max(images(:)), 50]); 
    
    % Initialize variable for SSR calculation
    total_residuals = 0;  % Sum of squared residuals (L)
    
    for i = 1:rows
        for j = 1:cols
            for k = 1:slices
                signal = squeeze(images(i, j, k, :));
                
                if all(signal > 0)  
                    signal = double(signal);
                    
                    % Define the objective function
                    objective_fun = @(b) sum((signal(:) - (b(1) * exp(-TEs(:) / b(2)))).^2);
                    
                    % Solve non-linear least squares using fminsearch
                    options = optimset('Display', 'off');
                    params = fminsearch(objective_fun, initial_guess, options);
                    
                    S0_map(i, j, k) = max(params(1), 0);  
                    T2_map(i, j, k) = max(params(2), 0);
                    
                    % Calculate residuals
                    predicted = S0_map(i, j, k) * exp(-TEs / T2_map(i, j, k));
                    residuals = (signal - predicted).^2;
                    total_residuals = total_residuals + sum(residuals); % Sum of squared residuals
                end
            end
        end
    end
    
    % Calculate AIC for the one-compartment model
    k_1comp = 2;  
    n_voxels = numel(S0_map);  
    AIC_1comp = 2 * k_1comp + (2 * total_residuals);  % AIC formula

    % Clean up NaNs and Infs
    T2_map(isinf(T2_map) | isnan(T2_map)) = 0;
    S0_map(isinf(S0_map) | isnan(S0_map)) = 0;
    
    mean_residual = mean(abs(residuals(:)));

    AIC = AIC_1comp;  % Return AIC for the one-compartment model

    return;
end
