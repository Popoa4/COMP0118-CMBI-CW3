function [mean_value,CI_lower,CI_upper,n_samples] = calculate_parameter_estimate(map,mask)
% estimate on the parameters
para_values = map(mask);
para_values = para_values(isfinite(para_values) & para_values > 0);
mean_value = mean(para_values);
std_value = std(para_values);
n_samples = length(para_values);

% compute the confidence intervals
SE = std_value / sqrt(n_samples);
t_critical = tinv(0.975, n_samples-1);
CI_lower = mean_value - t_critical * SE;
CI_upper = mean_value + t_critical * SE;
end

