% read in the images
r=load_nii('case01-qt2_reg.nii');
r.img(r.img(:)<0)=0;
images = r.img;
% size(images)

TEs=load('case01-TEs.txt')
% disp(TEs);
id_img1 = 1;
id_img2 = 10;
[T2_2point] = estimateT2_twopoints(images(:,:,:,id_img1), images(:,:,:,id_img2), TEs(id_img1), TEs(id_img2));
 
[T2_linear, S0_linear] = estimateT2_multipoint_linear(images, TEs);

figure;
subplot(1,2,1);
imagesc(T2_2point(:,:,round(end/2))); 
title('Two-point'); 
colorbar; 
clim([0 100]);

subplot(1,2,2);
imagesc(T2_linear(:,:,round(end/2))); 
title('Linear LS'); 
colorbar; 
clim([0 100]);
