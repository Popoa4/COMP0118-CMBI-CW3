function [T2_1_map, T2_2_map, S0_map, V1_map, mean_residual] = estimateT2_fixedT2s(images, TEs, mask)
[rows, cols, slices, num_echoes] = size(images);

residuals = zeros(size(images));

% Fixed T2 values (short and long components)
T2_1_fixed = 60;
T2_2_fixed = 2000;

% Ensure TEs is double precision
TEs = double(TEs);

% Initialize output maps
T2_1_map = T2_1_fixed * ones(rows, cols, slices, 'double');
T2_2_map = T2_2_fixed * ones(rows, cols, slices, 'double');
S0_map   = zeros(rows, cols, slices, 'double');
V1_map   = zeros(rows, cols, slices, 'double');

parfor i = 1:rows
    for j = 1:cols
        for k = 1:slices
            signal = double(squeeze(images(i, j, k, :)));

            if all(signal > 0)
                if(mask(i, j, k) > 0)

                    % Parameters to estimate: [S0, v1]
                    p0 = [max(signal), 0.5];
                    lb = [0, 0];
                    ub = [inf, 1];

                    % Fixed T2 bicomponent model
                    model_fun = @(p, TE) p(1) * (p(2) * exp(-TE / T2_1_fixed) + (1 - p(2)) * exp(-TE / T2_2_fixed));

                    options = optimset('Display', 'off');
                    try
                        params = lsqcurvefit(model_fun, p0, TEs(:), signal(:), lb, ub, options);

                        S0_map(i, j, k) = params(1);
                        V1_map(i, j, k) = params(2);
                    catch
                        continue
                    end
                end
            end
        end
    end
end

% Clean up NaNs and Infs
S0_map(isinf(S0_map) | isnan(S0_map)) = 0;
V1_map(isinf(V1_map) | isnan(V1_map)) = 0;

% Compute predicted signal and residuals
for t = 1:num_echoes
    predicted = S0_map .* (V1_map .* exp(-TEs(t) ./ T2_1_fixed) + (1 - V1_map) .* exp(-TEs(t) ./ T2_2_fixed));
    actual = images(:,:,:,t);
    residuals(:,:,:,t) = (actual - predicted).^2;
end

% Invalidate residuals for voxels with non-meaningful fits
invalid_mask = (S0_map <= 0) | isnan(S0_map);
for t = 1:num_echoes
    temp = residuals(:,:,:,t);
    temp(invalid_mask) = 0;
    residuals(:,:,:,t) = temp;
end

mean_residual = mean(abs(residuals(:)));
return;
end
