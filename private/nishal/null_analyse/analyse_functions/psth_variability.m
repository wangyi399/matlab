function [timeLogData,psthData] = psth_variability(spkCondColl,nConditions,condMovies,cond_str,InterestingCell_vis_id,imov,ref_cell_number,interestingConditions)

% RE FORMAT spkCondColl
nTrials=length(spkCondColl(1).spksColl);
movie_time=size(condMovies{1},1);
spkCondCollformat(4).spksColl=[];
for icond=1:nConditions
    spksColl=zeros(movie_time,nTrials);
    
    for itrial=1:nTrials
    for ispk=1:length(spkCondColl(icond).spksColl{itrial})
       frameNo= floor(double(spkCondColl(icond).spksColl{itrial}(ispk))*120/20000)+1;
       spksColl(frameNo,itrial)=1;
    end
    end
    spkCondCollformat(icond).spksColl=logical(spksColl)';
end


%%
% PSTH 



psthBinSize=10;
psthSmoothen=5;
for icond=1:nConditions
[timeLogData{icond},psthData{icond}]=  psth_calc(( spkCondCollformat(icond).spksColl),psthBinSize,'nonoverlap');
psthData{icond}=conv(psthData{icond},(1/psthSmoothen)*ones(psthSmoothen,1),'same');

%[timeLogModel{icond},psthModel{icond}]=  psth_calc(( spkCondCollModel(icond).spksColl),psthBinSize,'nonoverlap');
%psthModel{icond}=conv(psthModel{icond},(1/psthSmoothen)*ones(psthSmoothen,1),'same');

end

% figure;
% for icond=1:4
%     subplot(4,1,icond);
%     plot(timeLogData{icond},psthData{icond},'b');
%     hold on
%     plot(timeLogModel{icond},psthModel{icond},'r');
%     ylim([0,1.2*max(psthData{1})])
%     title(sprintf('PSTH var: Data %f: LNP Model: %f',var(psthData{icond}),var(psthModel{icond})));
%     legend('Data','LNP Model');
%    
% end

%%
% PSTH plots
col='rbrkrm';
figure('Color','w');

subplot(2,1,1);
for icond=1:nConditions

xPoints = spkCondColl(icond).xPoints;
yPoints = spkCondColl(icond).yPoints;
nTrials1=max(yPoints(:));
plot(xPoints/20000, yPoints+(nConditions-icond)*nTrials1,col(icond));
hold on
ylim([0,nConditions*nTrials]);
xlim([0,12]);
title(sprintf('%s: data004 vis ID: %d, Avg Spk rates (%0.02f,%0.02f,%0.02f,%0.02f) spks/sec',cond_str{icond},InterestingCell_vis_id(ref_cell_number),spkCondColl(interestingConditions(1)).avgSpkRate,spkCondColl(interestingConditions(2)).avgSpkRate,spkCondColl(interestingConditions(3)).avgSpkRate,spkCondColl(interestingConditions(4)).avgSpkRate));
end

subplot(2,1,2);
for icond=1:nConditions
    plot(timeLogData{icond}/120,psthData{icond},col(icond));
    hold on
    ylim([0,1.2*max(psthData{1})])
end
xlabel('Time in Seconds');
title(sprintf('PSTHs Cell %d',InterestingCell_vis_id(ref_cell_number)));
%legend(cond_str{1},cond_str{2},cond_str{3},cond_str{4},cond_str{5},cond_str{6},'Location','best');

end