%% Load the GLM fit
load('/Volumes/Analysis/nora/nishal_glmfits/30min/7742.mat');

%% Load the datarun to compare to
datarun=load_data('2014-11-05-2/data010_from_data009_nps');
datarun=load_neurons(datarun);

%% Load the movie to make predictions for
testmovie_filename='/Volumes/Data/2014-11-05-2/visual/18.rawMovie';
testmovie=get_rawmovie(testmovie_filename,5760);
testmovie=permute(testmovie,[2 3 1]);

%% Evaluate
x=nishal_test(fittedGLM, datarun, testmovie, 30);
plotraster(x,fittedGLM,1,0,1)
