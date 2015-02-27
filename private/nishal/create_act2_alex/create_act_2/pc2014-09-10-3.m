% Nishal P. Shah , September 2014

% Have a dataset ready with cells you want to nullify grouped under a
% common name(use Vision software).

startup_bertha

startup_rooster

datafile='nishal/2014-09-10-3/data001/data001';%'nishal/2014-08-20-2/data001/data001';

% type_name_inp = 'userCellList' for a list of cells.

no_images_per_movie=10;
start_image=10;
tag='stim2014-09-10-3';
destination_mat=['/Volumes/Analysis/nishal/',tag];
if(~exist(destination_mat,'dir'))
mkdir(destination_mat);
end

dest_raw='/Volumes/Data/stimuli/movies/null_space/';

movies=cell(20,1);
% 'solver' .. 1 for LSQR, 2 for CRAIG, 3 for Fourier 
%%

cell_params=struct();
cell_params.type_name_inp='On Parasol';%'Off Parasol'
cell_params.cell_list=[]; % if type_name_inp = 'userCellList' 

mov_params=struct();
mov_params.mov_type='nsem';
mov_params.start_image=50;
mov_params.no_images_per_movie=10;
mov_params.mean=0.25*255; % mean on [0-255] scale.
mov_params.deviation_plus=0.73*255;
mov_params.deviation_minus=0.23*255;
mov_params.scaling_loss=0.02; % a number in [0,1], fraction of values that is changed by scaling.

solver=3; 
[mov_orignial,mov_modify_new]=null_space_movie2(datafile,cell_params,mov_params,solver);
movies{1}=mov_orignial;
movies{2}=mov_modify_new;
mov_idx=1;
write_movie_idx(destination_mat,movies{mov_idx},mov_idx);
mov_idx=2;
write_movie_idx(destination_mat,movies{mov_idx},mov_idx);

%%
cell_params=struct();
cell_params.type_name_inp='On Parasol';
cell_params.cell_list=[]; % if type_name_inp = 'userCellList' 

mov_params=struct();
mov_params.mov_type='bw-precomputed';
mov_params.movie_time=120*10;
mov_params.mean=0.25*255;
mov_params.deviation=0.24*256/2;
mov_params.scaling_loss=0.02; % a number in [0,1], fraction of values that is changed by scaling.

solver=3;
[mov_orignial,mov_modify_new]=null_space_movie2(datafile,cell_params,mov_params,solver);
movies{3}=mov_orignial;
movies{4}=mov_modify_new;
mov_idx=3;
write_movie_idx(destination_mat,movies{mov_idx},mov_idx);
mov_idx=4;
write_movie_idx(destination_mat,movies{mov_idx},mov_idx);
%%

cell_params=struct();
cell_params.type_name_inp='Off Parasol';%'Off Parasol'
cell_params.cell_list=[]; % if type_name_inp = 'userCellList' 

mov_params=struct();
mov_params.mov_type='nsem';
mov_params.start_image=50;
mov_params.no_images_per_movie=10;
mov_params.mean=0.25*255; % mean on [0-255] scale.
mov_params.deviation_plus=0.73*255;
mov_params.deviation_minus=0.23*255;
mov_params.scaling_loss=0.001; % a number in [0,1], fraction of values that is changed by scaling.

solver=3; 
[mov_orignial,mov_modify_new]=null_space_movie2(datafile,cell_params,mov_params,solver);
movies{5}=mov_orignial;
movies{6}=mov_modify_new;
mov_idx=5;
write_movie_idx(destination_mat,movies{mov_idx},mov_idx);
mov_idx=6;
write_movie_idx(destination_mat,movies{mov_idx},mov_idx);

%%
cell_params=struct();
cell_params.type_name_inp='Off Parasol';
cell_params.cell_list=[]; % if type_name_inp = 'userCellList' 

mov_params=struct();
mov_params.mov_type='bw-precomputed';
mov_params.movie_time=120*10;
mov_params.mean=0.25*255;
mov_params.deviation=0.24*256/2;
mov_params.scaling_loss=0.02; % a number in [0,1], fraction of values that is changed by scaling.

solver=3;
[mov_orignial,mov_modify_new]=null_space_movie2(datafile,cell_params,mov_params,solver);
movies{7}=mov_orignial;
movies{8}=mov_modify_new;
mov_idx=7;
write_movie_idx(destination_mat,movies{mov_idx},mov_idx);
mov_idx=8;
write_movie_idx(destination_mat,movies{mov_idx},mov_idx);
%%
cell_params=struct();
cell_params.type_name_inp='userCellList';%'Off Parasol'
cell_params.cell_list=[]; % if type_name_inp = 'userCellList' 
% TODO : Add region specific cell list
mov_params=struct();
mov_params.mov_type='nsem';
mov_params.start_image=50;
mov_params.no_images_per_movie=10;
mov_params.mean=0.25*255; % mean on [0-255] scale.
mov_params.deviation_plus=0.73*255;
mov_params.deviation_minus=0.23*255;
mov_params.scaling_loss=0.02; % a number in [0,1], fraction of values that is changed by scaling.

solver=3; 
[mov_orignial,mov_modify_new]=null_space_movie2(datafile,cell_params,mov_params,solver);
movies{9}=mov_orignial;
movies{10}=mov_modify_new;
mov_idx=9;
write_movie_idx(destination_mat,movies{mov_idx},mov_idx);
mov_idx=10;
write_movie_idx(destination_mat,movies{mov_idx},mov_idx);

%%
cell_params=struct();
cell_params.type_name_inp='userCellList';%'Off Parasol'
cell_params.cell_list=[]; % if type_name_inp = 'userCellList' 
% TODO : Add region specific cell list

mov_params=struct();
mov_params.mov_type='bw-precomputed';
mov_params.movie_time=120*10;
mov_params.mean=0.25*255;
mov_params.deviation=0.24*256/2;
mov_params.scaling_loss=0.02; % a number in [0,1], fraction of values that is changed by scaling.

solver=3;
[mov_orignial,mov_modify_new]=null_space_movie2(datafile,cell_params,mov_params,solver);
movies{11}=mov_orignial;
movies{12}=mov_modify_new;
mov_idx=11;
write_movie_idx(destination_mat,movies{mov_idx},mov_idx);
mov_idx=12;
write_movie_idx(destination_mat,movies{mov_idx},mov_idx);
%%
cell_params=struct();
cell_params.type_name_inp='userCellList';%'Off Parasol'
cell_params.cell_list=[]; % if type_name_inp = 'userCellList' 
% TODO : Add region specific cell list

mov_params=struct();
mov_params.mov_type='bw-precomputed';
mov_params.movie_time=120*60*15;
mov_params.mean=0.25*255;
mov_params.deviation=0.24*256/2;
mov_params.scaling_loss=0.02; % a number in [0,1], fraction of values that is changed by scaling.

solver=3;
[mov_orignial,mov_modify_new]=null_space_movie2(datafile,cell_params,mov_params,solver);
movies{20}=mov_orignial;
movies{13}=mov_modify_new;
mov_idx=20;
write_movie_idx(destination_mat,movies{mov_idx},mov_idx);
mov_idx=13;
write_movie_idx(destination_mat,movies{mov_idx},mov_idx);

%% %%
datafile='nishal/2014-09-10-2/data004_2/data004_2';%'nishal/2014-08-20-2/data001/data001';
cell_params=struct();
cell_params.type_name_inp='Parasol';%'Off Parasol'
cell_params.cell_list=[]; % if type_name_inp = 'userCellList' 

mov_params=struct();
mov_params.mov_type='nsem';
mov_params.start_image=50;
mov_params.no_images_per_movie=10;
mov_params.mean=0.25*255; % mean on [0-255] scale.
mov_params.deviation_plus=0.73*255;
mov_params.deviation_minus=0.23*255;
mov_params.scaling_loss=0.02; % a number in [0,1], fraction of values that is changed by scaling.

solver=3; 
[mov_orignial,mov_modify_new]=null_space_movie2(datafile,cell_params,mov_params,solver);
movies{14}=mov_orignial;
movies{15}=mov_modify_new;
mov_idx=14;
write_movie_idx(destination_mat,movies{mov_idx},mov_idx);
mov_idx=15;
write_movie_idx(destination_mat,movies{mov_idx},mov_idx);

%%

datafile='nishal/2014-09-10-2/data004_2/data004_2';%'nishal/2014-08-20-2/data001/data001';

cell_params=struct();
cell_params.type_name_inp='Parasol';
cell_params.cell_list=[]; % if type_name_inp = 'userCellList' 

mov_params=struct();
mov_params.mov_type='bw-precomputed';
mov_params.movie_time=120*10;
mov_params.mean=0.25*255;
mov_params.deviation=0.24*256/2;
mov_params.scaling_loss=0.02; % a number in [0,1], fraction of values that is changed by scaling.

solver=3;
[mov_orignial,mov_modify_new]=null_space_movie2(datafile,cell_params,mov_params,solver);
movies{16}=mov_orignial;
movies{17}=mov_modify_new;
mov_idx=16;
write_movie_idx(destination_mat,movies{mov_idx},mov_idx);
mov_idx=17;
write_movie_idx(destination_mat,movies{mov_idx},mov_idx);

%% Correct means etc left ? 
% for mov_idx=1:13
% write_movie_idx(destination_mat,movies{mov_idx},mov_idx);
% end

mov_total=zeros(63,32,1440*n_movies);
icnt=1;
for imov=[1,2,3,4,5,6,7,8,9,10,11,12,14,15,16,17]
% Write all movies together ? 
 mov_total(:,:,icnt:icnt+size(movies{imov},3)-1)=movies{imov};
 icnt=icnt+size(movies{imov},3);
end

