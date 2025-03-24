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
% Crea oggetto video
v = VideoWriter('T2_animation.mp4', 'MPEG-4');
v.FrameRate = 2; % 2 frame al secondo (corrisponde a pause(0.5))
open(v);

figure;
colormap gray;

for t = 1:length(TE)
    imagesc(img(:,:,slice_num,t));
    axis off;
    title(['TE = ', num2str(TE(t)), ' ms']);
    drawnow;

    frame = getframe(gcf);      % Cattura il frame
    writeVideo(v, frame);       % Scrive nel video
end

close(v);  % Chiude il file
