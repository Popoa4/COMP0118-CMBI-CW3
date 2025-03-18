% function to process images of any two TE values ​​and generate T2 estimates for each voxel
function T2_map = estimateT2_twopoints(image1, image2, TE1, TE2)
    % Ensure that the input images have the same size
    if ~isequal(size(image1), size(image2))
        error('Input images must have the same dimensions');
    end
    
    T2_map = zeros(size(image1));
    
    % Calculate T2 value: T2 = (TE2-TE1)/ln(S1/S2)
    valid_indices = (image1 > 0) & (image2 > 0) & (image1 > image2);
    T2_map(valid_indices) = (TE2 - TE1) ./ log(image1(valid_indices) ./ image2(valid_indices));
    
    % set the value of negative/ NaN/ Inf as 0
    T2_map(isinf(T2_map) | isnan(T2_map) | T2_map < 0) = 0;
    return;
end