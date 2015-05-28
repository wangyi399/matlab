%% LOAD DATA

load('/Volumes/Analysis/nora/NSEM/GLM_Output/rk1_MU_PS_noCP_CBP_p8IDp8/standardparams/WN_mapPRJ/2012-08-09-3/ONPar_1772.mat')
fittedGLM_CBP=fittedGLM;
load('/Volumes/Analysis/nora/NSEM/GLM_Output/rk1_MU_PS_noCP_p8IDp8/standardparams/WN_mapPRJ/2012-08-09-3/ONPar_1772.mat');
%}

%{
load('/Volumes/Analysis/nora/NSEM/GLM_Output/rk1_MU_PS_noCP_CBP_p8IDp8/standardparams/WN_mapPRJ/2012-08-09-3/OFFPar_1471.mat')
fittedGLM_CBP=fittedGLM;
load('/Volumes/Analysis/nora/NSEM/GLM_Output/rk1_MU_PS_noCP_p8IDp8/standardparams/WN_mapPRJ/2012-08-09-3/OFFPar_1471.mat');
%}

%% RASTERS

figure; 

dt = fittedGLM.t_bin;
bins     = 120 * 4 * fittedGLM.bins_per_frame;
time     = dt*[1:bins];

subplot(5,1,1);
title('Cluster Rasters')
rec_rast = fittedGLM.xvalperformance.rasters.recorded(:,1:bins);
sim_rast = fittedGLM.xvalperformance.rasters.glm_sim(:,1:bins); 

trials   = size(rec_rast,1);
runawaytrial=ones(trials,1);
ylim([1 trials*2])

hold on
for i_trial = 1:trials
    sim1 = time(find(sim_rast(i_trial,:)));
    rec1 = time(find(rec_rast(i_trial,:)));
    plot(rec1, i_trial, 'k.')
    if length(sim1) < 4*length(rec1) 
        plot(sim1, i_trial + trials, 'r.')
    else
        runawaytrial(i_trial)=0;
    end
end

subplot(5,1,2);
title('CBP Rasters')
rec_rast = fittedGLM_CBP.xvalperformance.rasters.recorded(:,1:bins);
sim_rast = fittedGLM_CBP.xvalperformance.rasters.glm_sim(:,1:bins); 
ylim([1 trials*2])
hold on
for i_trial = 1:trials
    sim1 = time(find(sim_rast(i_trial,:)));
    rec1 = time(find(rec_rast(i_trial,:)));
    plot(rec1, i_trial, 'k.')
    if length(sim1) < 4*length(rec1) 
        plot(sim1, i_trial + trials, 'b.')
    else
        runawaytrial(i_trial)=0;
    end
end

runtrials=find(runawaytrial);
N=length(runtrials);

convolve=100;
PSTH_rec=zeros(length(runtrials),bins);
PSTH_sim=zeros(length(runtrials),bins);
PSTH_rec_CBP=zeros(length(runtrials),bins);
PSTH_sim_CBP=zeros(length(runtrials),bins);

for i=1:length(runtrials)
    i_trial=runtrials(i);
    PSTH_rec(i,:)=conv(fittedGLM.xvalperformance.rasters.recorded(i_trial,1:bins),ones(convolve,1),'same');
    PSTH_sim(i,:)=conv(fittedGLM.xvalperformance.rasters.glm_sim(i_trial,1:bins),ones(convolve,1),'same');
    PSTH_rec_CBP(i,:)=conv(fittedGLM_CBP.xvalperformance.rasters.recorded(i_trial,1:bins),ones(convolve,1),'same');
    PSTH_sim_CBP(i,:)=conv(fittedGLM_CBP.xvalperformance.rasters.glm_sim(i_trial,1:bins),ones(convolve,1),'same');
end

subplot(5,1,3:5)
title('PSTH')
hold on
a=fill([time flip(time)],[mean(PSTH_rec)+std(PSTH_rec)/sqrt(N) flip(mean(PSTH_rec)-std(PSTH_rec)/sqrt(N))],[1 0 0],'FaceAlpha',0.2,'EdgeColor','none');
fill([time flip(time)],[mean(PSTH_sim)+std(PSTH_sim)/sqrt(N) flip(mean(PSTH_sim)-std(PSTH_sim)/sqrt(N))],[1 0 0],'FaceAlpha',0.5,'EdgeColor','none');
b=fill([time flip(time)],[mean(PSTH_rec_CBP)+std(PSTH_rec_CBP)/sqrt(N) flip(mean(PSTH_rec_CBP)-std(PSTH_rec_CBP)/sqrt(N))],[0 0 1],'FaceAlpha',0.2,'EdgeColor','none');
fill([time flip(time)],[mean(PSTH_sim_CBP)+std(PSTH_sim_CBP)/sqrt(N) flip(mean(PSTH_sim_CBP)-std(PSTH_sim_CBP)/sqrt(N))],[0 0 1],'FaceAlpha',0.5,'EdgeColor','none');
c=plot(time,mean(PSTH_rec),'k--');
d=plot(time,mean(PSTH_sim),'k','LineWidth',2);
plot(time,mean(PSTH_rec),'--','Color',[1 0 0]);
plot(time,mean(PSTH_sim),'LineWidth',2,'Color',[1 0 0]);
plot(time,mean(PSTH_rec_CBP),'--','Color',[0 0 1]);
plot(time,mean(PSTH_sim_CBP),'LineWidth',2,'Color',[0 0 1]);
legend([a b c d],'Cluster spikes','CBP spikes','Recorded','Simulated')
xlim([time(1) time(end)])
hold off 

disp(fittedGLM.xvalperformance.glm_normedbits)
disp(fittedGLM_CBP.xvalperformance.glm_normedbits)