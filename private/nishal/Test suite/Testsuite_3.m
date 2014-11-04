
%% Final compilation of all code for Test suite
startup_null_analyse_tenessee

%% Get STA 



datafile = '2012-08-09-3/data002';
type_name= cell(1,1);
type_name{1}='On Parasol';

opt=struct('load_all',true);
datarun=load_data(datafile,opt)
datarun=load_sta(datarun)
datarun=load_params(datarun)
datarun=load_ei(datarun,'all','array_type',519);
%get_cell_ids(datarun,type_name) % Vision IDs - used for loading fitted
%STAs!

matlab_cell_ids=get_cell_indices(datarun,type_name);
stas=datarun.stas.stas(matlab_cell_ids);
n_cell=length(stas);

vision_id=1772; 
idx=[1:length(datarun.cell_ids)];
matlab_id=idx(datarun.cell_ids==vision_id);
cell_ei=datarun.ei.eis{matlab_id};
ssta=stas{matlab_cell_ids==matlab_id};

%% Fit STA to data
addpath(genpath('~/Nishal/matlab/code')); 
addpath(genpath('~/Nishal/matlab/private/nishal/fwdfittingfunctions'));
fit_info = fit_sta(ssta)
%datarun = compute_sta_fits(datarun, 'all');

%params=datarun.matlab.sta_fits{matlab_id}.initial_params;
params=fit_info.initial_params;
full_fit = sta_fit_function(params);

figure;
for itime=27%30:-1:1
    itime
    subplot(2,1,1);
    imagesc(squeeze(sum(ssta(:,:,:,itime),3)));
    colormap gray
    axis image
    colorbar
    caxis([min(ssta(:)), max(ssta(:))]);

    
    subplot(2,1,2);
    imagesc(squeeze(sum(full_fit(:,:,:,itime),3)));
    colormap gray
    axis image
    colorbar 
    caxis([min(ssta(:)), max(ssta(:))]);
% 
%     pause;
    
end

% NOTE : TODO : STA is time reversed !! 

%% Get Non-linarity

% NOTE: cell_types{i}.name to be chosen to include the target cell of interest. 
addpath(genpath('../../../code/'));
datarun = get_sta_summaries(datarun, datarun.cell_types{1}.name, ...
    'verbose',0,'keep_stas',0,'keep_rfs',1,'fig_or_axes',[],...
    'marks_params',struct( ...
        'strength','vector length', 'filter', fspecial('gauss',15,0.7), ...
        'thresh',5,'robust_std_method',1));
movie_spec='/Volumes/Analysis/movie-xml/RGB-8-1-0.48-11111.xml' %RGB-8-1-0.48-11111.xml';%RGB-8-1-0.48-11111-80x40
datarun = load_java_movie(datarun, movie_spec);
%datarun = get_snls(datarun, datarun.cell_ids(get_cell_indices(datarun, datarun.cell_types{1}.name)),'frames',-18:0,'stimuli',[],'new',true);
datarun = get_snls(datarun,vision_id,'frames',-18:0,'stimuli',[],'new',true);
% NOTE: TODO : have to Vary significant stixels, STA length (in frames parameter which is set at -18 right now !)and see how shape of non-linearity changes!

cellID=matlab_id;
gen=datarun.stas.snls{cellID}.gen_signal;
spks=datarun.stas.snls{cellID}.spikes;

figure;
subplot(2,2,1);
hist(spks);
subplot(2,2,2);
scatter(gen,spks);
hold on;
x=[-1:0.01:1];
N=@(x) exp(datarun.stas.snls{cellID}.fit_params.a*x +datarun.stas.snls{cellID}.fit_params.b);
plot(x,N(x),'r');

subplot(2,2,4);
hist(gen,100);

% int=[-1:0.01:1];
% use gen and make non-uniform grid
int = quantile(gen,100);

gen_log=[];
p_spk=[];
error_bar=[];
val_ids=(gen<=int(1));
gen_log=[gen_log;mean(gen(val_ids))];
p_spk=[p_spk;mean(spks(val_ids))];
error_bar=[error_bar;sqrt(var(spks(val_ids)))/sqrt(sum(val_ids))];

for idx=1:length(int)-1
val_ids=(gen>int(idx)&gen<=int(idx+1));
gen_log=[gen_log;mean(gen(val_ids))];
p_spk=[p_spk;mean(spks(val_ids))];
error_bar=[error_bar;sqrt(var(spks(val_ids)))/sqrt(sum(val_ids))];

end
idx=idx+1;
val_ids=(gen>int(idx));
gen_log=[gen_log;mean(gen(val_ids))];
p_spk=[p_spk;mean(spks(val_ids))];
error_bar=[error_bar;sqrt(var(spks(val_ids)))/sqrt(sum(val_ids))];

subplot(2,2,3);
errorbar(gen_log,p_spk,error_bar,'*');
hold on
x=[-1:0.01:1];
plot(x,N(x),'r');

%%
% Have complete model, now generate stimulus
mdf_file=movie_spec;%'/Volumes/Analysis/deprecated/movie-xml2/RGB-8-1-0.48-11111.xml';
triggers=datarun.triggers;
frames=30*60*120; % 10 minutes
[mov,height,width,duration,refresh] = get_movie(mdf_file, triggers,frames);
mov=(mov-0.5);
mov2=zeros(size(mov,2),size(mov,1),size(mov,3),size(mov,4));

for itime=1:frames
for icol=1:3
    mov2(:,:,icol,itime) = mov(:,:,icol,itime)';
end
end

mov=mov2;
%% Generate response to stimulus 
ssta=ssta;
full_fit=full_fit;
s_use=full_fit(:,:,:,end:-1:1);
%s_use(:,:,:,15:end)=0; % DOUBT .. TODO ? Ask EJ
movie_time=size(mov,4);

gen_signals=zeros(movie_time,3);
for col=1:3;
    col
    st_temp=zeros(size(s_use,2),size(s_use,1),1,size(s_use,4)); % DOUBT .. Could be a reason for things to fail!!!!!
    for itime=1:30
        st_temp(:,:,:,itime)=s_use(:,:,col,itime)'; % DOUBT .. Could be a reason for things to fail!!!!!
    end
    s_use_new=st_temp;

Filtlen = size(s_use_new,4);
Filtdim1=size(s_use_new,1);
Filtdim2=size(s_use_new,2);

movie_new_len=movie_time;
mov2=zeros(Filtdim1 ,Filtdim2,movie_new_len+Filtlen-1);
mov2(:,:,Filtlen:movie_new_len+Filtlen-1)=squeeze(mov(:,:,col,:)); % Append zeros before the movie
sz=max(size(mov2,3)-size(s_use_new,4) + 1, 0);

gen_signals(:,col) = reshape(convn(mov2,squeeze(s_use_new(end:-1:1,end:-1:1,1,:)),'valid'),[sz,1]);
end
    %
gen=sum(gen_signals,2);
    
% gen is linear output
% N(gen) is after passing through non-linearity
pSpk = N(gen);

spksGen = poissrnd(pSpk);

    
    
%% Calculate STA 
binnedResponses = spksGen;

% My own STA code 
STA=zeros(Filtdim1,Filtdim2,3,Filtlen);

for iframe=30:movie_time
    iframe
STA=STA+mov(:,:,:,iframe:-1:iframe-Filtlen+1)*binnedResponses(iframe);
end
STA=STA/sum(binnedResponses);
STA=STA*max(full_fit(:))/max(STA(:)); % Normalize STA!! to have same max as fitted one..

STA=squeeze(sum(STA,3));

 figure
 for itime=1:Filtlen
     subplot(2,1,1);
 imagesc(squeeze((STA(:,:,itime)))');colormap gray
 caxis([min(STA(:)),max(STA(:))]);
 colorbar
 
 subplot(2,1,2);
 imagesc(squeeze(sum(s_use_new(:,:,:,itime),3))')
 colormap gray
 caxis([min(STA(:)),max(STA(:))]);
 colorbar
 pause(1/120)
 end
 
 
%% Calculate null stimulus -in BW
sta_null=1; 
Filtdim1=size(STA,1);
Filtdim2=size(STA,2);

% Select movie for null stim 
movieLen=120*10;
mov_gen2=zeros(Filtdim1,Filtdim2,movieLen);
movie_idx=2;

generate_null_script

 
%% Generate response to null stimulus
stas=cell(1,1);
stas{1}=zeros(Filtdim1,Filtdim2,1,Filtlen);

for itime=1:Filtlen
stas{1}(:,:,1,itime) = squeeze(STA(:,:,itime));
end
movieL=size(mov_modify_new,3);
nTrials=50;

movieTest = mov_orig;     %mov_orig,mov_modify_new
Response_test_movie_script
spksOrig= spksTrialsmall;

movieTest = mov_modify_new;%mov_orig,mov_modify_new
Response_test_movie_script
spksModi=spksTrialsmall;

figure;
subplot(2,1,1)
plotSpikeRaster(logical(spksOrig'),'PlotType','vertline');
title('Original Movie spike Raster');

subplot(2,1,2)
plotSpikeRaster(logical(spksModi'),'PlotType','vertline');
title('Null space movie spike Raster');
subplot(2,1,2)

%% Generate null stimulus - NSEM
sta_null=1; 
Filtdim1=size(STA,1);
Filtdim2=size(STA,2);

% Select movie for null stim 
movieLen=120*10;
mov_gen2=zeros(Filtdim1,Filtdim2,movieLen);
movie_idx=5;

generate_null_script



%% Generate response to null stimulus
stas=cell(1,1);
stas{1}=zeros(Filtdim1,Filtdim2,1,Filtlen);

for itime=1:Filtlen
stas{1}(:,:,1,itime) = squeeze(STA(:,:,itime));
%stas{1}(:,:,1,itime) = squeeze((full_fit(:,:,1,itime)))';
end
movieL=size(mov_modify_new,3);
nTrials=50;

movieTest = mov_orig;     %mov_orig,mov_modify_new
Response_test_movie_script
spksOrig= spksTrialsmall;

movieTest = mov_modify_new;%mov_orig,mov_modify_new
Response_test_movie_script
spksModi=spksTrialsmall;

figure;
subplot(2,1,1)
plotSpikeRaster(logical(spksOrig'),'PlotType','vertline');
title('Original Movie spike Raster');

subplot(2,1,2)
plotSpikeRaster(logical(spksModi'),'PlotType','vertline');
title('Null space movie spike Raster');
subplot(2,1,2)
 

%% Trim STA

% calculate the distances of these points from the center of Gauss

% calculate rotation matrix: couterclockwise rotation with respect to angle
rotation_angle=fit_info.center_rotation_angle;
rotation_matrix = [cos(rotation_angle), -1*sin(rotation_angle); sin(rotation_angle), cos(rotation_angle)];

% define covariance matrix given the sd_scale and rotation matrix

covariance_matrix = rotation_matrix * [1/fit_info.center_sd_x^2 0; 0 1/fit_info.center_sd_y^2] * rotation_matrix';

% calculate the value of the Gaussian at each point in output_matrix
clippedSTA=zeros(size(STA));
norm_dist=zeros(fit_info.x_dim,fit_info.y_dim);

for wd = 1:fit_info.x_dim
    for ht = 1:fit_info.y_dim
        pt = [fit_info.center_point_x - wd; fit_info.center_point_y - ht];
       
        norm_dist(wd,ht)= sqrt(pt' *inv( covariance_matrix) * pt);
        if(norm_dist(wd,ht)<6)
         
            clippedSTA(wd,ht,:)=squeeze(STA(wd,ht,:));
        end
    end
end
figure;
plot(squeeze(sum(sum(clippedSTA(:,:,:),1),2)));

xlabel('STA frame');
title('Clipped STA summation of pixel values in each frame (Temporal profile)');

cutoff_after=input('Cutoff STA after what number? '); %14;
clippedSTA(:,:,cutoff_after:end)=0;
figure
 for itime=1:Filtlen
     subplot(3,1,1);
 imagesc(squeeze((STA(:,:,itime)))');colormap gray
 caxis([min(STA(:)),max(STA(:))]);
 colorbar
 axis image
      subplot(3,1,2);
 imagesc(squeeze((clippedSTA(:,:,itime)))');colormap gray
 caxis([min(STA(:)),max(STA(:))]);
 colorbar
 axis image
 
 subplot(3,1,3);
 imagesc(squeeze(sum(full_fit(:,:,:,Filtlen-itime),3))')
 colormap gray
 caxis([min(STA(:)),max(STA(:))]);
 colorbar
 axis image
 
 pause
 
 end
 
%% clipped STA but cheap computationally
% 
% xGrid=zeros(size(STA,1),size(STA,2));
% yGrid=xGrid;
% for ix=1:size(STA,1)
%     for iy=size(STA,2)
%     xGrid(ix,iy)=ix;
%     yGrid(ix,iy)=iy;
%     end
% end
% 
% xCOM = sum(sum(xGrid.*STA(:,:,5))/sum(sum(STA(:,:,5))))
% yCOM = sum(sum(yGrid.*STA(:,:,5))/sum(sum(STA(:,:,5))))

dummySTA=zeros(size(STA,1),size(STA,2),3,size(STA,3));
for itime=1:size(STA,3)
dummySTA(:,:,1,itime)=STA(:,:,itime);
dummySTA(:,:,2,itime)=STA(:,:,itime);
dummySTA(:,:,3,itime)=STA(:,:,itime);
end

[sig_stixels, params, rf_strength_out] = significant_stixels(dummySTA,'select','thresh','thresh',2);
figure;
imagesc(sig_stixels)

% Find continous region
max_val=max(rf_strength_out(sig_stixels));
[row,col]=find(rf_strength_out.*double(sig_stixels)==max_val)
list=[row,col];

[row,col]=find(sig_stixels==1);
sig_list=[row,col];


tostop=0;
while tostop==0
tostop=1;
for istix=1:size(sig_list,1)
    if ~(sum((sig_list(istix,1)==list(:,1)) .* (sig_list(istix,2)==list(:,2)))==1)
        for ilist_elem=1:size(list,1)
            if(abs(sig_list(istix,1)-list(ilist_elem,1)) + abs(sig_list(istix,2)-list(ilist_elem,2))<=2)
            list=[list;sig_list(istix,1),sig_list(istix,2)];
            tostop=0;
            display('Element added')
            a=sig_list(istix,:)
            b=list(ilist_elem,:)
            break
            end
        end
    end
end
end

mask_rf=zeros(size(sig_stixels));
for ielem=1:size(list,1)
mask_rf(list(ielem,1),list(ielem,2))=1;
end
figure;
imagesc(mask_rf)
%mask_rf=imdilate(logical(full(sig_stixels)),[1,1,1,1,1;1,1,1,1,1;1,1,1,1,1]);

fastClipSTA=zeros(size(STA));
for itime=1:size(STA,3)
fastClipSTA(:,:,itime)=mask_rf.*STA(:,:,itime);
end


figure;
plot(squeeze(sum(sum(fastClipSTA(:,:,:),1),2)));
xlabel('STA frame');
title('Clipped STA summation of pixel values in each frame (Temporal profile)');

cutoff_after=input('Cutoff STA after what number? '); %14;
fastClipSTA(:,:,cutoff_after:end)=0;

figure
 for itime=1:Filtlen
     itime
     subplot(3,1,1);
 imagesc(squeeze((STA(:,:,itime)))');colormap gray
 caxis([min(STA(:)),max(STA(:))]);
 colorbar
 axis image
      subplot(3,1,2);
 imagesc(squeeze((fastClipSTA(:,:,itime)))');colormap gray
 caxis([min(STA(:)),max(STA(:))]);
 colorbar
 axis image
 
 subplot(3,1,3);
 imagesc(squeeze(sum(full_fit(:,:,:,Filtlen-itime),3))')
 colormap gray
 caxis([min(STA(:)),max(STA(:))]);
 colorbar
 axis image
 
 pause
 
 end
%%
movie_idx=2 % 2 for BW , 5 for NSEM
sta_null=4 % 1 for STA calculated in simulation, 2 for original fitted STA , 3 (not done yet) for original STA in data
sta_test=4 % 1 for STA calculated in simulation, 2 for original fitted STA , 3 (not done yet) for original STA in data
null_compute_test