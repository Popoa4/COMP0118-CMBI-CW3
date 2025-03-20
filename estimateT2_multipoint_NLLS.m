function [T2_map, S0_map] = estimateT2_multipoint_NLLS(images, TEs)
    [rows, cols, slices, num_echoes] = size(images);
    
    % Ensure TEs is double precision
    TEs = double(TEs);
    
    % Initialize output maps as double
    T2_map = zeros(rows, cols, slices, 'double');
    S0_map = zeros(rows, cols, slices, 'double');
    
    % Initial parameter guess: [S0, T2]
    initial_guess = double([max(images(:)), 50]);  % Ensure double precision
    
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
                end
            end
        end
    end
    
    T2_map(isinf(T2_map) | isnan(T2_map)) = 0;
    S0_map(isinf(S0_map) | isnan(S0_map)) = 0;
    
    return;
end
