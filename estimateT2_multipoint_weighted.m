function [T2_map, S0_map] = estimateT2_multipoint_weighted(images, TEs)
    [rows, cols, slices, num_echoes] = size(images);
    
    T2_map = zeros(rows, cols, slices);
    S0_map = zeros(rows, cols, slices);
    
    for i = 1:rows
        for j = 1:cols
            for k = 1:slices
                signal = squeeze(images(i, j, k, :)); 
                
                if all(signal > 0)  
                    log_signal = log(signal);  
                    
                    X = [ones(num_echoes, 1), -TEs(:)];
                    
                    % Compute weights (higher weight for stronger signal)
                    W = diag(signal.^2);  

                    % Compute Weighted Least Squares solution
                    b = (X' * W * X) \ (X' * W * log_signal);
                    
                    % Extract S0 and T2 from regression coefficients
                    S0_map(i, j, k) = exp(b(1)); 
                    T2_map(i, j, k) = 1 / b(2);   
                end
            end
        end
    end
    
    T2_map(isinf(T2_map) | isnan(T2_map) | T2_map < 0) = 0;
    S0_map(isinf(S0_map) | isnan(S0_map) | S0_map < 0) = 0;
    
    return;
end
