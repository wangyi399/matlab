% Generate responses to null movie


% Calculate filter output for each sub-unit for each frame and calculate
% number of spikes for each frame-bin (binned response) .. So that would be
% used for STA calculation ? 

% Response to null movie
movie_new_len=size(mov_new2,3);
mov2=zeros(Filtdim1 ,Filtdim2,movie_new_len+Filtlen-1);
mov2(:,:,Filtlen:movie_new_len+Filtlen-1)=mov_new2; % Append zeros before the movie
SubUnit_Response_test_movie_script
binnedResponseNull=binnedResponses;
psth_null=psth_resp;
time_log_null=timeLog;

% Response to original movie
movie_new_len=size(mov_orig2,3);
mov2=zeros(Filtdim1 ,Filtdim2,movie_new_len+Filtlen-1);
mov2(:,:,Filtlen:movie_new_len+Filtlen-1)=mov_orig2; % Append zeros before the movie
SubUnit_Response_test_movie_script
binnedResponseOrig=binnedResponses;
psth_orig=psth_resp;
time_log_orig = timeLog;

[x1,y1]=plotSpikeRaster(binnedResponseNull'>0,'PlotType','vertline');
[x2,y2]=plotSpikeRaster(binnedResponseOrig'>0,'PlotType','vertline');

figure;
subplot(2,1,1);
plot(x1,y1,'k');
hold on
plot(x2,y2+max(y2),'r');
xlim([0 max(time_log_orig)]);
ylim([0,2*max(y2)]);

subplot(2,1,2);
plot(time_log_null,psth_null,'k');
hold on
plot(time_log_orig,psth_orig,'r');
xlim([0,max(time_log_null)]);
legend('Null','Original');

% 
% figure;
% scatter(psth_orig',psth_null');
% title('Scatter between Original PSTH and null PSTH');

% figure;
% scatter(binnedResponseOrig,binnedResponseNull);
% title('Scatter between Original and Null response');

% Re-STA
binnedResponses=binnedResponseOrig;
reSTC_SubUnit
reSTAOrig=reSTA;
reSTCOrig=reSTC;

binnedResponses=binnedResponseNull;
reSTC_SubUnit
reSTANull=reSTA;
reSTCNull=reSTC;

% 
[V,D]=eigs(reSTCNull,reSTCOrig,10,'lm');
figure;
plot(diag(abs(D)),'*');
title('Eigen Values');

uSq=cell(size(V,2),1);
isel=1;
uSq{isel}=reshape(V(:,isel),[Filtdim1,Filtdim2,Filtlen]).*repmat(mask,[1,1,Filtlen]);
figure; 
for itime=1:30
imagesc(squeeze(uSq{isel}(:,:,itime)));
 colormap gray
 caxis([min(uSq{isel}(:)),max(uSq{isel}(:))])
 hold on
pause(1)
end
