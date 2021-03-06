cell = 4493;
tic 
% test data
datarun=load_data('/Volumes/Analysis/2015-10-29-2/data037-data050/data049/data049');
datarun = load_neurons(datarun);
test_stim = interleaved_data_prep(datarun, 2400, 30, 'stimulus_name', '/Volumes/Lab/Users/Nora/new_stim_nora/NSbrownian_code/newrawmovie/gain_control.rawMovie');
test_spikes = interleaved_data_prep(datarun, 2400, 30, 'cell_spec', cell);
cid = get_cell_indices(datarun, cell);
toc
%%
% fit data
datarun_fit=load_data('/Volumes/Analysis/2015-10-29-2/data037-data050/data038/data038');
datarun_fit = load_neurons(datarun_fit);
fitmovie = zeros(40, 80, 2000*120, 'uint8');
idx = 1:120;
for i=1001:3000
    load(['/Volumes/Data/Stimuli/movies/eye-movement/current_movies/NSbrownian/matfiles/movie_chunk_' num2str(i) '.mat'])
    fitmovie(:,:,idx) = permute(imresize(movie, 0.25), [2 1 3]); 
    idx = idx+120;
end
fit_spikes = interleaved_data_prep(datarun_fit, 240000, 1, 'cell_spec', cell);
toc
%%

datarun_class=load_data('/Volumes/Analysis/2015-10-29-2/data037-data050/data048/data048');
datarun_class = load_params(datarun_class);
center_coord = datarun_class.vision.sta_fits{master_idx}.mean;
center(1) = round(center_coord(1)); % x_coord
center(2) = size(fitmovie,2) - round(center_coord(2)); %y_coord
fittedGLM = glm_fit(fit_spikes.testspikes{1}, fitmovie, center);
toc
%%
% fittedGLM = glm_fit_from_WN(cell, '2015-10-29-2/data048-data049/data048/data048', 'RGB-8-2-0.48-11111');

testmovie_down = zeros(40, 80, 2400);
idx_i = 1:2;
for i = 1:40
    idx_i=idx_i+2;
    idx_j = 1:2;
    for j=1:80
       idx_j = idx_j+2;
       testmovie_down(i,j,:) = sum(sum(prepped_data.testmovie(:,idx_j, idx_i),3),2);
    end
end
xval_performance = glm_predict(fittedGLM, testmovie_down, 'testspikes', prepped_data.testspikes);
toc 

%%
figure;
smooth = 200;
recorded = conv(sum(xval_performance.rasters.recorded,1), gausswin(smooth));
glm_sim = conv(sum(xval_performance.rasters.glm_sim,1), gausswin(smooth));
plot(recorded)
hold on; plot(glm_sim)

idx = 1:1200;
figure; hold on
peak_firing = zeros(10);
for i = 1:9
    image_repeat = glm_sim(idx);
    plot(image_repeat);
    idx = idx+2400;
    peak_firing_sim(i) = max(image_repeat); 
end