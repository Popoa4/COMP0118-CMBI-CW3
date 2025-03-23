function VaryingEchoTime(img, TE, slice_num)
% Function to visualze imaging data and how the images change with varying echo-time
% for a selected slice

% One subplot for each echo-time
figure;
colormap gray;

for t = 1:length(TE)
    subplot(4, ceil(length(TE)/4), t); 
    imagesc(img(:,:,slice_num,t));
    axis off;
    title(['TE = ', num2str(TE(t)), ' ms']);
end

% Video animation
figure;
colormap gray;
for t = 1:length(TE)
    imagesc(img(:,:,slice_num,t));
    axis off;
    title(['TE = ', num2str(TE(t)), ' ms']);
    pause(0.5); % Metti in pausa per 0.5 secondi tra i frame
end