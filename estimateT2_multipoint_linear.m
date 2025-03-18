% take in multi points and estimate the T2 and S0
function [T2_map, S0_map] = estimateT2_multipoint_linear(images, TEs)
    [rows, cols, slices, num_echoes] = size(images);
    
    T2_map = zeros(rows, cols, slices);
    S0_map = zeros(rows, cols, slices);
    
    % fit for every voxel
    for i = 1:rows
        for j = 1:cols
            for k = 1:slices
                signal = squeeze(images(i, j, k, :));
                
                if all(signal > 0)
                    % Logarithmic linearization
                    log_signal = log(signal);
                    
                    % linear fit: log(S) = log(S0) - TE/T2
                    % disp(size(ones(num_echoes, 1)));
                    % disp(size(TEs(:)));
                    X = [ones(num_echoes, 1), -TEs(:)];
                    b = X \ log_signal;
                    
                    S0_map(i, j, k) = exp(b(1));
                    T2_map(i, j, k) = 1/b(2);
                end
            end
        end
    end
    
    % set the value of negative/ NaN/ Inf as 0
    T2_map(isinf(T2_map) | isnan(T2_map) | T2_map < 0) = 0;
    S0_map(isinf(S0_map) | isnan(S0_map) | S0_map < 0) = 0;
    
    return;
end
