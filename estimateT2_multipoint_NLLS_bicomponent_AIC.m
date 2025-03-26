function [T2_1_map, T2_2_map, S0_map, V1_map, mean_residual, AIC] = estimateT2_multipoint_NLLS_bicomponent_AIC(images, TEs, mask)
    [rows, cols, slices, num_echoes] = size(images);

    residuals = zeros(size(images));

    TEs = double(TEs);
    
    T2_1_map = zeros(rows, cols, slices, 'double');
    T2_2_map = zeros(rows, cols, slices, 'double');
    S0_map   = zeros(rows, cols, slices, 'double');
    V1_map   = zeros(rows, cols, slices, 'double');

    total_residuals = 0;  % Sum of squared residuals (L)

    parfor i = 1:rows
        for j = 1:cols
            for k = 1:slices
                signal = double(squeeze(images(i, j, k, :)));

                if all(signal > 0)
                    if(mask(i, j, k) > 0)

                        % Starting point: [S0, v1, T2_1, T2_2]
                        p0 = [max(signal), 0.5, 20, 70];
                        lb = [0, 0, 10, 70];
                        ub = [inf, 1, 50, 2500];

                        % Non-linear model: S(TE) = S0 * [v1 * exp(-TE/T2_1) + (1 - v1) * exp(-TE/T2_2)]
                        objective_fun = @(p, TE) p(1) * (p(2) * exp(-TE / p(3)) + (1 - p(2)) * exp(-TE / p(4)));

                        % Fit with non-linear least squares
                        options = optimset('Display', 'off');
                 
                        try
                            params = lsqcurvefit(objective_fun, p0, TEs(:), signal(:), lb, ub, options);

                            S0_map(i, j, k)   = params(1);
                            V1_map(i, j, k)   = params(2);
                            T2_1_map(i, j, k) = params(3);
                            T2_2_map(i, j, k) = params(4);
                            
                            % Calculate residuals
                            predicted = S0_map(i, j, k) * (V1_map(i, j, k) * exp(-TEs / T2_1_map(i, j, k)) + (1 - V1_map(i, j, k)) * exp(-TEs / T2_2_map(i, j, k)));
                            residuals(i, j, k, :) = (signal - predicted).^2;
                            total_residuals = total_residuals + sum(residuals(i, j, k, :)); % Sum of squared residuals
                        catch
                            continue
                        end
                    end
                end
            end
        end
    end

    % Calculate AIC for the two-compartment model
    k_2comp = 4;  
    n_voxels = numel(S0_map);  
    AIC_2comp = 2 * k_2comp + (2 * total_residuals);  % AIC formula

    % Clean up NaNs and Infs
    T2_1_map(isinf(T2_1_map) | isnan(T2_1_map)) = 0;
    T2_2_map(isinf(T2_2_map) | isnan(T2_2_map)) = 0;
    S0_map(isinf(S0_map) | isnan(S0_map)) = 0;
    V1_map(isinf(V1_map) | isnan(V1_map)) = 0;

    mean_residual = mean(abs(residuals(:)));
    
    AIC = AIC_2comp;  % Return AIC for the two-compartment model

    return;
end
