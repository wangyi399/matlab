load('/Volumes/Analysis/nishal/CBPcells.mat');

startup_analyse_tenessee

%%
% dataset='2013-10-10-0';
% 
% %analysis_datafile = sprintf('%s/data005-from-data000/data005-from-data000',dataset);
%analysis_datafile = sprintf('%s/data000/data000',dataset);
% imov=5;
% bin_datafile=sprintf('/Volumes/Data/%s/data00%d',dataset,imov);
% 
% vision_id=346;
% 
% no_cells=5;
% noise=0.25;
% 
% run_ss
% 
% clear all
%%


dataset='2013-10-10-0';

analysis_datafile = sprintf('%s/data001-from-data000/data001-from-data000',dataset);
%analysis_datafile = sprintf('%s/data000/data000',dataset);
imov=1;
bin_datafile=sprintf('/Volumes/Data/%s/data00%d',dataset,imov);

vision_id=346;

no_cells=5;
noise=0.25;

run_ss

clear all
%%
% dataset='2013-10-10-0';
% 
% %analysis_datafile = sprintf('%s/data005-from-data000/data005-from-data000',dataset);
% analysis_datafile = sprintf('%s/data000/data000',dataset);
% imov=5;
% bin_datafile=sprintf('/Volumes/Data/%s/data00%d',dataset,imov);
% 
% vision_id=32;
% 
% no_cells=5;
% noise=0.25;
% 
% run_ss
% 
% clear all
%%
dataset='2013-10-10-0';

analysis_datafile = sprintf('%s/data001-from-data000/data001-from-data000',dataset);
%analysis_datafile = sprintf('%s/data000/data000',dataset);
imov=1;
bin_datafile=sprintf('/Volumes/Data/%s/data00%d',dataset,imov);

vision_id=32;

no_cells=5;
noise=0.25;

run_ss

clear all