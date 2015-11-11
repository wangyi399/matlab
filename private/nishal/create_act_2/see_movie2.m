figure;

for itime=1:100:100
    subplot(2,2,1);
    imagesc(mov_orig(:,:,itime));
    axis image
    colorbar
    colormap(gray)
   % title(sprintf('Time: %d',itime));
    
    subplot(2,2,2);
    imagesc(mov_modify_new(:,:,itime));
    axis image
    colorbar
  %  title(sprintf('Time: %d',itime));
    colormap(gray)
        
    subplot(2,2,3);
    imagesc(mov_orig(:,:,itime)-mov_modify_new(:,:,itime));
    axis image
    colorbar
  %  title(sprintf('Time: %d',itime));
    colormap(gray)
    
    pause(1/240)

end

%%


 % Discretize ???? 
dum_mov=mov_modify_new;
dum_mov = double(uint8((dum_mov)));
dum_mov=(dum_mov-mov_params.mean);
mov_modify_new2=dum_mov*(0.5/127.5);

dum_mov=mov_orig;
dum_mov = double(uint8((dum_mov)));

dum_mov=(dum_mov-mov_params.mean);
mov_orig2=dum_mov*(0.5/127.5);


cell_resp_orig=Ax(stas_clipped,mov_orig2,movie_time,n_cell);
cell_resp_null=Ax(stas_clipped,mov_modify_new2,movie_time,n_cell);


figure
subplot(3,1,1);
plot(cell_resp_orig);
ylim([min(cell_resp_orig(:)),max(cell_resp_orig(:))]);
title('Original movie');



subplot(3,1,2);
plot(cell_resp_null);
ylim([min(cell_resp_orig(:)),max(cell_resp_orig(:))]);
title('Null movie response (bigger scale)');

subplot(3,1,3);
plot(cell_resp_null);
title('Null movie response (normal scale)');

%%
clear var
figure;
subplot(2,1,1);
hist(sqrt(var(cell_resp_orig)),10)
xlim([0,max(sqrt(var(cell_resp_orig)))]);
title('S.D. of Origional response');

subplot(2,1,2);
hist(sqrt(var(cell_resp_null)),100)
xlim([0,max(sqrt(var(cell_resp_orig)))]);
title('S.D. of null response ');

%% pixel histogram

clear hist
figure;
subplot(2,1,1);
hist(mov_orig(:),100);
xlim([0,255]);
title('Pixel histogram: Original movie');

subplot(2,1,2);
hist(mov_modify_new(:),100);
xlim([0,255]);
title('Pixel histogram: Modified movie');
