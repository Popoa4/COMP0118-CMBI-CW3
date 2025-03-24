function [T2_1_map, T2_2_map, S0_map, V1_map, mean_residual] = estimateT2_multipoint_NLLS_bicomponent(images, TEs, mask)
[rows, cols, slices, num_echoes] = size(images);

residuals = zeros(size(images));

% Ensure TEs is double precision
TEs = double(TEs);

% Initialize output maps as double
T2_1_map = zeros(rows, cols, slices, 'double');
T2_2_map = zeros(rows, cols, slices, 'double');
S0_map   = zeros(rows, cols, slices, 'double');
V1_map   = zeros(rows, cols, slices, 'double');

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
                    catch
                        continue
                    end
                end
            end
        end
    end
end

% Clean up NaNs and Infs
T2_1_map(isinf(T2_1_map) | isnan(T2_1_map)) = 0;
T2_2_map(isinf(T2_2_map) | isnan(T2_2_map)) = 0;
S0_map(isinf(S0_map) | isnan(S0_map)) = 0;
V1_map(isinf(V1_map) | isnan(V1_map)) = 0;

for t = 1:num_echoes
    predicted = S0_map .* (V1_map.*exp(-TEs(t) ./ T2_1_map) +(1 - V1_map).*exp(-TEs(t) ./ T2_2_map)) ;
    actual = images(:,:,:,t);
    residuals(:,:,:,t) = (actual - predicted).^2;
end

% cope with the useless value
invalid_mask = (T2_1_map <= 0) | (T2_2_map <= 0) | (S0_map <= 0) | isnan(T2_1_map) | isnan(T2_2_map)| isnan(S0_map);
for t = 1:num_echoes
    temp = residuals(:,:,:,t);
    temp(invalid_mask) = 0;
    residuals(:,:,:,t) = temp;
end

mean_residual = mean(abs(residuals(:)));
return;
end