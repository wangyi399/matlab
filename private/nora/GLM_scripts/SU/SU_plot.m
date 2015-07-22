%load('/Volumes/Lab/Users/Nora/NSEM_Home/GLMOutput_Raw/rk1_MU_PS_noCP_SU_init_p8IDp8/standardparams/WN_mapPRJ/2012-09-27-3/ONPar_6858.mat')
load('/Volumes/Lab/Users/Nora/NSEM_Home/GLMOutput_Raw/rk1_MU_PS_noCP_SU_p8IDp8/standardparams/NSEM_mapPRJ/2012-08-09-3/ONPar_841.mat')

%% Plot Iterations
a = [1 1 1];
figure; hold on
for i =1:4
    plot(fittedGLM.rawfit.iter{i}.SU, 'Color', 1-a*i/5)
end
title('Subunit Filter')
xlabel('Pixel Index')


figure; hold on
for i =1:4
    plot(fittedGLM.rawfit.iter{i}.nonSU(fittedGLM.rawfit.paramind.time1), 'Color', 1-a*i/5)
end
title('Temporal Part of Stimulus Filter')
xlabel('Frame Index')

figure; hold on
for i =1:4
    plot(fittedGLM.rawfit.iter{i}.nonSU(fittedGLM.rawfit.paramind.space1), 'Color', 1-a*i/5)
end
title('Pooling Weights')
xlabel('Location Index')

%% plot final filters
figure; plotfilters(fittedGLM)

%% plot non_SU filters
FGSU = fittedGLM;
%load('/Volumes/Lab/Users/Nora/NSEM_Home/GLMOutput_Raw/rk1_MU_PS_noCP_p8IDp8/standardparams/WN_mapPRJ/2012-09-27-3/ONPar_6858.mat')
load('/Volumes/Lab/Users/Nora/NSEM_Home/GLMOutput_Raw/rk1_MU_PS_noCP_p8IDp8/standardparams/NSEM_mapPRJ/2012-08-09-3/ONPar_841.mat')


%% 
figure;
plot(-FGSU.linearfilters.Stimulus.time_rk1)
hold on
plot(fittedGLM.linearfilters.Stimulus.time_rk1)
legend('SU model', 'GLM')
title('Temporal Part of Stimulus Filter')

figure;
plot(-FGSU.linearfilters.Stimulus.space_rk1(:))
hold on
plot(fittedGLM.linearfilters.Stimulus.space_rk1(:))
legend('SU model', 'GLM')
title('Spatial Part of Stimulus Filter')

figure;
plot(FGSU.linearfilters.PostSpike.Filter)
hold on
plot(fittedGLM.linearfilters.PostSpike.Filter)
legend('SU model', 'GLM')
title('Post Spike Filter')


%%
figure;
subplot(1,2,1)
imagesc(-FGSU.linearfilters.Stimulus.space_rk1)
colormap gray
axis image
axis off
caxis([-0.3 0.6])
title('SU model')
subplot(1,2,2)
imagesc(fittedGLM.linearfilters.Stimulus.space_rk1)
colormap gray
axis image
axis off
title('GLM')
caxis([-0.3 0.6])

%%




