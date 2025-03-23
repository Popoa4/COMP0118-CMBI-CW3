function [T2_map, S0_map] = estimateT2_multipoint_NNLS(images, TEs)
    [rows, cols, slices, num_echoes] = size(images);
    
    T2_map = zeros(rows, cols, slices, 'double'); % Ensure double precision
    S0_map = zeros(rows, cols, slices, 'double'); % Ensure double precision
    
    % Fit for every voxel
    for i = 1:rows
        for j = 1:cols
            for k = 1:slices
                signal = squeeze(images(i, j, k, :));
                
                if all(signal > 0) 
                    log_signal = log(double(signal));  % Convert to double before log
                    
                    X = double([ones(num_echoes, 1), -TEs(:)]);  
                  
                    b = lsqnonneg(X, log_signal);
                    
                    S0_map(i, j, k) = exp(b(1));  % S0 = exp(intercept)
                    T2_map(i, j, k) = 1 / max(b(2), eps);  % T2 = 1 / slope 
                end
            end
        end
    end
    
    % Handle invalid values
    T2_map(isinf(T2_map) | isnan(T2_map)) = 0;
    S0_map(isinf(S0_map) | isnan(S0_map)) = 0;
    
    return;
end
