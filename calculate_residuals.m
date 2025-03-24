function residuals = calculate_residuals(images, TEs, T2_map, S0_map)
    [rows, cols, slices, num_echoes] = size(images);
    
    residuals = zeros(size(images));
    TEs = TEs(:);
    
    % compute the residuals of each voxel
    for t = 1:num_echoes
        predicted = S0_map .* exp(-TEs(t) ./ T2_map);
        actual = images(:,:,:,t);
        residuals(:,:,:,t) = (actual - predicted).^2;
    end
    
    % cope with the useless value
    invalid_mask = (T2_map <= 0) | (S0_map <= 0) | isnan(T2_map) | isnan(S0_map);
    for t = 1:num_echoes
        temp = residuals(:,:,:,t);
        temp(invalid_mask) = 0;
        residuals(:,:,:,t) = temp;
    end
    
    return;
end