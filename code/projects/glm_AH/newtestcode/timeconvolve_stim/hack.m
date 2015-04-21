% hacked code to convolve stimulus with the DimFlash response

clear; clc; BD = NSEM_BaseDirectories;
% 
cmodel = 'DimFlash_092413Fc12';
source = sprintf('%s/newtestcode/timeconvolve_stim/%s.mat',BD.GLM_codehome, cmodel);
eval(sprintf('load %s', source))
%eval(sprintf('load %s/newtestcode/timeconvolve_stim/%s.mat', BD.GLM_codehome, cmodel));
%load /Users/akheitman/Matlab_code/glm_AH_24/newtestcode/timeconvolve_stim/DimFlash_092413Fc12.mat;
y1 = DimFlash.dimflashfit;
x1 = 0:1:400;
x2 = 0:8:392;
y2 = y1(x2+1);
y2 = y2 - y2(1);
Flash_Frame_Rate = (y2)/ norm(y2);
%}
% y2 is now in frames
%%% 
%
clf;  subplot(9,1,1:4);
plot(x2/1000, Flash_Frame_Rate,'linewidth',2); hold on; set(gca,'fontsize',12)
xlabel('seconds');
set(gca,'xtick',[.1 .2 .3 .4]); 
ylabel('unitless')

%}

%
title('Time Kernels')
cmodel = 'linear_timekernel';
cmodelname = 'linear_cone_model_Rieke'
source = sprintf('%s/%s', BD.NSEM_home, cmodelname);
eval(sprintf('load %s/linearcones.mat', source))
Flash_Frame_Rate = lincone_framerate;
%Flash_Frame_Rate = Flash_Frame_Rate - Flash_Frame_Rate(1);
Flash_Frame_Rate = Flash_Frame_Rate/ norm(Flash_Frame_Rate);
plot(x2/1000, Flash_Frame_Rate(1:50),'linewidth',2,'color','r');
legend({'Flash Response from Cone Model','New Linear Estimate from Rieke Lab'});



type ='BW'

subplot(9,1,6:9);
if strcmp(type, 'BW')
    load /Users/akheitman/NSEM_Home/Stimuli/BW-8-1-0.48-11111_RNG_16807/testmovie_8pix_Model1_1e4_8pix.mat
    fullcone = testmovie;
    load /Users/akheitman/NSEM_Home/Stimuli/BW-8-1-0.48-11111_RNG_16807/testmovie_linear_timekernel_shift0.mat 
    slowlinear = testmovie;
    load /Users/akheitman/NSEM_Home/Stimuli/BW-8-1-0.48-11111_RNG_16807/testmovie_DimFlash_092413Fc12_shift0.mat
    fastlinear = testmovie;
elseif strcmp(type,'NSEM')
    load /Users/akheitman/NSEM_Home/Stimuli/NSEM_eye/testmovie_8pix_Model1_1e4_8pix.mat
    fullcone = testmovie;
    load /Users/akheitman/NSEM_Home/Stimuli/BW-8-1-0.48-11111_RNG_16807/testmovie_linear_timekernel_shift0.mat 
    slowlinear = testmovie;
    load /Users/akheitman/NSEM_Home/Stimuli/BW-8-1-0.48-11111_RNG_16807/testmovie_DimFlash_092413Fc12_shift0.mat
    fastlinear = testmovie;
end

x = 40; y = 20;
LW = 2;
t_ind = 200:330;
t_sec = (8/1000)*(t_ind-t_ind(1));

plot(t_sec,squeeze(fullcone.matrix(x,y,t_ind)), 'color','k','linewidth',LW); hold on; set(gca,'fontsize',12)
plot(t_sec,squeeze(fastlinear.matrix(x,y,t_ind)), 'color','b','linewidth',LW);
plot(t_sec,squeeze(slowlinear.matrix(x,y,t_ind)), 'color','r','linewidth',LW);
legend({'Full Cone Model','Flash Response from Cone Model','New Linear Estimate from Rieke Lab'});
xlabel('seconds'); xlim([0 1]);
set(gca,'xtick',[.2 .4 .6 .8 1]); ylabel('unitless');
if strcmp(type, 'BW')
    title('Convolved White Noise Stimulus')
end

orient landscape
eval(sprintf('print -dpdf comparing_linearfilters.pdf'))

%}
%%

shift = 1; debug = false;

% BW version 

for i_movie = 1:3
    if i_movie == 1, movie = 'NSEM_eye-120-3_0-3600';   scheme = 'schemeA';   type = 'NSEM'; end
    if i_movie == 2, movie = 'NSEM_eye-long-v2';        scheme = 'schemeA';   type = 'NSEM'; end
    if i_movie == 3, movie = 'NSEM_FEM900FF_longrast';  scheme = 'schemeB';   type = 'NSEM'; end
    display(sprintf('#### Working on %s ####', movie));

loadsave_dir = sprintf('%s/%s', BD.NSEM_stimuli, movie);
if strcmp(type,'BW')
    eval(sprintf('load %s/fitmovie_8pix_Identity_8pix.mat', loadsave_dir));
    eval(sprintf('load %s/testmovie_8pix_Identity_8pix.mat', loadsave_dir));
    eval(sprintf('load %s/inputstats_8pix_Identity_8pix.mat', loadsave_dir));
elseif strcmp(type, 'NSEM')
    eval(sprintf('load %s/fitmovie_%s_8pix_Identity_8pix.mat', loadsave_dir,scheme));
    eval(sprintf('load %s/testmovie_%s_8pix_Identity_8pix.mat', loadsave_dir,scheme));
    eval(sprintf('load %s/inputstats_8pix_Identity_8pix.mat', loadsave_dir));
end
%%
inputstats0 = inputstats; clear inputstats;
inputstats.stimulus  = inputstats0.stimulus;
inputstats.cmodel    = cmodel;
inputstats.shift     = shift;
inputstats.shiftnote = 'frame shift in how we implement cone model.. small technical detail';
inputstats.dim       = inputstats0.dim;
inputstats.range     = 255;



testmovie0 = testmovie;

if strcmp(type, 'BW')
    orig_movie = BWmovie; clear BWmovie
elseif strcmp(type, 'NSEM')
    orig_movie = NSEMmovie; clear NSEMmovie    
end
plotdir = sprintf('%s/TimeConvolve_%s_Verification/',loadsave_dir,cmodel); if ~exist(plotdir, 'dir'), mkdir(plotdir); end
new = orig_movie;
new = rmfield(new, 'fitmovie');
new.fitmovie.ind_to_block = orig_movie.fitmovie.ind_to_block;

blocks = length(orig_movie.fitmovie.movie_byblock);
if debug 
    blocks = 1;
end
minvals = zeros(1,blocks+1); % incorporate for the testmovie
maxvals = zeros(1,blocks+1); % incorporate for the testmovie
new.fitmovie.movie_byblock = cell(1,blocks);  

% Grab max and min values across the board
for i_blk = 1:blocks
	display(sprintf('Working on Block %d out of %d', i_blk, blocks));
	mat1 = double(orig_movie.fitmovie.movie_byblock{i_blk}.matrix);
	[dim1,dim2,frames] = size(mat1);
	mat1 = reshape(mat1,[dim1*dim2, frames]);
    mat2 = mat1;
	for i_vec = 1:dim1*dim2
        convolved     = conv(mat1(i_vec,:), Flash_Frame_Rate);
        mat2(i_vec,:) = convolved((1+shift):(frames+shift));
    end
	final_mat = reshape(mat2, [dim1,dim2,frames]);
	new.fitmovie.movie_byblock{i_blk}.unnormed = final_mat;
	new.fitmovie.movie_byblock{i_blk}.minval   = min(final_mat(:));
	new.fitmovie.movie_byblock{i_blk}.maxval   = max(final_mat(:));   
	minvals(i_blk) = min(final_mat(:));
	maxvals(i_blk) = max(final_mat(:));
end

% do same to the testmovie
mat1      = double(testmovie.matrix);
[dim1,dim2,frames] = size(mat1);
mat1         = reshape(mat1,[dim1*dim2, frames]);
mat2 = mat1;
for i_vec = 1:dim1*dim2
        convolved     = conv(mat1(i_vec,:), Flash_Frame_Rate);
        mat2(i_vec,:) = convolved((1+shift):(frames+shift));
end
testmat_unnormed = reshape(mat2, [dim1,dim2,frames]);

minvals(end) = min(testmat_unnormed(:));
maxvals(end) = max(testmat_unnormed(:));



new.fitmovie.globalmin = min(minvals);
new.fitmovie.globalmax = max(maxvals);
globalmin = min(minvals);
globalmax = max(maxvals);
globalspan = globalmax - globalmin;
new.fitmovie.globalspan = globalspan;

%%

hist_8bit = zeros(blocks,256);
meanval   = zeros(blocks,1);

tcmovie = orig_movie;
tcmovie = rmfield(tcmovie, 'fitmovie');
tcmovie.fitmovie.ind_to_block = orig_movie.fitmovie.ind_to_block;
tcmovie.fitmovie.movie_byblock = cell(1,blocks); 
    
for i_blk = 1:blocks
	mat1 = new.fitmovie.movie_byblock{i_blk}.unnormed;
    mat2 = round(255* ( (mat1 - globalmin) / globalspan ));
    final_mat = uint8(mat2);
    
    hist_8bit(i_blk,:) = hist(mat2(:),256);
    meanval(i_blk) = mean(mat2(:));
    
    clf; plot(squeeze(final_mat(15,20,1:1000))); hold on; plot(squeeze(orig_movie.fitmovie.movie_byblock{i_blk}.matrix(15,20,1:1000)),'r');
	xlabel('frames'); ylabel('8bit intensity')
    orient landscape
	eval(sprintf('print -dpdf %s/fitmovie_blk%d.pdf', plotdir,i_blk))
	tcmovie.fitmovie.movie_byblock{i_blk}.matrix = final_mat;
end
tcmovie.note = 'convolved with time filter';
tcmovie.convolve_vector = Flash_Frame_Rate;
tcmovie.convolve_source = sprintf('RiekeLab DimFlash Response: %s', source);
tcmovie.cmodel = inputstats.cmodel;

mat1 = testmat_unnormed;
mat2 = round(255* ( (mat1 - globalmin) / globalspan ));
final_mat = uint8(mat2);
clf; plot(squeeze(final_mat(15,20,1:1000))); hold on; plot(squeeze(mat1(15,20,1:1000)),'r');
xlabel('frames'); ylabel('8bit intensity')
orient landscape
eval(sprintf('print -dpdf %s/Atestmovie.pdf', plotdir))

testmovie.matrix = final_mat;
testmovie.note = 'convolved with time filter';
testmovie.convolve_vector = Flash_Frame_Rate;
testmovie.convolve_source = sprintf('RiekeLab DimFlash Response: %s', source);

if strcmp(type, 'BW'),  testmovie.stimulus        = tcmovie.moviename; end
if strcmp(type, 'NSEM'), testmovie.stimulus       = tcmovie.note0;  end
testmovie.cmodel           = inputstats.cmodel;


inputstats.hist_8bit     = mean(hist_8bit,1);
inputstats.mu_avgIperpix = mean(meanval); 

    %%

% save fit movie
if strcmp(type, 'BW')
    BWmovie = tcmovie;
    if ~debug
        eval(sprintf('save %s/fitmovie_%s_shift%d.mat BWmovie',loadsave_dir,cmodel,shift));
        eval(sprintf('save %s/testmovie_%s_shift%d.mat testmovie',loadsave_dir,cmodel,shift));
    elseif debug
        eval(sprintf('save %s/DEBUGfitmovie_%s_shift%d.mat BWmovie',loadsave_dir,cmodel,shift));
        eval(sprintf('save %s/DEBUGtestmovie_%s_shift%d.mat testmovie',loadsave_dir,cmodel,shift));
    end
elseif strcmp(type,'NSEM')
    NSEMmovie = tcmovie;
    if ~debug
        eval(sprintf('save %s/fitmovie_%s_%s_shift%d.mat NSEMmovie',loadsave_dir,scheme,cmodel,shift));
        eval(sprintf('save %s/testmovie_%s_%s_shift%d.mat testmovie',loadsave_dir,scheme,cmodel,shift));
    elseif debug
        eval(sprintf('save %s/DEBUGfitmovie_%s_%s_shift%d.mat NSEMmovie', loadsave_dir, scheme, cmodel,shift));
        eval(sprintf('save %s/DEBUGtestmovie_%s_%s_shift%d.mat testmovie'  , loadsave_dir, scheme, cmodel, shift));
    end
end



if ~debug
        
        eval(sprintf('save %s/inputstats_%s_shift%d.mat inputstats',loadsave_dir,cmodel,shift));
elseif debug
        
        eval(sprintf('save %s/DEBUGinputstats_%s_shift%d.mat inputstats',loadsave_dir,cmodel,shift));
end
end



% save testmovie

%%% NSEM Version
%{
movie = 'NSEM_FEM900FF_longrast'; scheme = 'schemeB';

BD = NSEM_BaseDirectories;
loadsave_dir = sprintf('%s/%s', BD.NSEM_stimuli, movie);
eval(sprintf('load %s/fitmovie_%s_8pix_Identity_8pix.mat', loadsave_dir,scheme));

    
NSEMmovie0 = NSEMmovie;
   plotdir = sprintf('%s/TimeConvolve_%s_Verification/',loadsave_dir,source); if ~exist(plotdir, 'dir'), mkdir(plotdir); end
    new = NSEMmovie;
    new = rmfield(new, 'fitmovie');
    new.fitmovie.ind_to_block = NSEMmovie.fitmovie.ind_to_block;
    blocks = length(NSEMmovie.fitmovie.movie_byblock);
    minvals = zeros(1,blocks);
    maxvals = zeros(1,blocks);
    new.fitmovie.movie_byblock = cell(1,blocks);  
    for i_blk = 1:blocks
        i_blk
        mat1 = double(NSEMmovie.fitmovie.movie_byblock{i_blk}.matrix);
        [dim1,dim2,frames] = size(mat1);
        mat1 = reshape(mat1,[dim1*dim2, frames]);

        mat2 = mat1;
        for i_vec = 1:dim1*dim2
            convolved     = conv(mat1(i_vec,:), Flash_Frame_Rate);
            mat2(i_vec,:) = convolved((1+shift):(frames+shift));
        end
        final_mat = reshape(mat2, [dim1,dim2,frames]);
        new.fitmovie.movie_byblock{i_blk}.unnormed = final_mat;
        new.fitmovie.movie_byblock{i_blk}.minval   = min(final_mat(:));
        new.fitmovie.movie_byblock{i_blk}.maxval   = max(final_mat(:));   
        minvals(i_blk) = min(final_mat(:));
        maxvals(i_blk) = max(final_mat(:));
    end

    %%
    new.fitmovie.globalmin = min(minvals);
    new.fitmovie.globalmax = max(maxvals);
    globalmin = min(minvals);
    globalmax = max(maxvals);
    globalspan = globalmax - globalmin;


    tcNSEMmovie = NSEMmovie;
    tcNSEMmovie = rmfield(tcNSEMmovie, 'fitmovie');
    tcNSEMmovie.fitmovie.ind_to_block = NSEMmovie.fitmovie.ind_to_block;
    tcNSEMmovie.fitmovie.movie_byblock = cell(1,blocks); 
    
    for i_blk = 1:blocks
        mat1 = new.fitmovie.movie_byblock{i_blk}.unnormed;
        
        mat2 = round(255* ( (mat1 - globalmin) / globalspan ));
        final_mat = uint8(mat2);
        
        clf; plot(squeeze(final_mat(15,20,1:1000))); hold on; plot(squeeze(NSEMmovie0.fitmovie.movie_byblock{i_blk}.matrix(15,20,1:1000)),'r');
        xlabel('frames'); ylabel('8bit intensity')
        orient landscape
        eval(sprintf('print -dpdf %s/fitmovie_blk%d.pdf', plotdir,i_blk))
        tcNSEMmovie.fitmovie.movie_byblock{i_blk}.matrix = final_mat;
    end
    tcNSEMmovie.note = 'convolved with time filter';
    tcNSEMmovie.convolve_vector = Flash_Frame_Rate;
    tcNSEMmovie.convolve_source = sprintf('RiekeLab DimFlash Response: %s', source);
    
    NSEMmovie = tcNSEMmovie;
    eval(sprintf('save %s/fitmovie_%s_TimeConvolve_DimFlash_shift%d.mat NSEMmovie',loadsave_dir,scheme,shift));
    
    


%%
eval(sprintf('load %s/testmovie_%s_8pix_Identity_8pix.mat', loadsave_dir,scheme));
testmovie0 = testmovie;
mat1 = double(testmovie0.matrix);
[dim1,dim2,frames] = size(mat1);
mat1 = reshape(mat1,[dim1*dim2, frames]);

mat2 = mat1;
for i_vec = 1:dim1*dim2
    convolved     = conv(mat1(i_vec,:), Flash_Frame_Rate);
    mat2(i_vec,:) = convolved((1+shift):(frames+shift));
end
mat2 = round(255* ( (mat2 - globalmin) / globalspan ));
mat2 = reshape(mat2, [dim1,dim2,frames]);

final_mat = uint8(mat2);
clf; plot(squeeze(final_mat(15,20,1:1000))); hold on; plot(squeeze(testmovie.matrix(15,20,1:1000)),'r');
xlabel('frames'); ylabel('8bit intensity')
orient landscape
eval(sprintf('print -dpdf %s/atestmovie.pdf', plotdir))

testmovie.matrix = final_mat;
testmovie.note = 'convolved with time filter';
testmovie.convolve_vector = Flash_Frame_Rate;
testmovie.convolve_source = sprintf('RiekeLab DimFlash Response: %s', source);
eval(sprintf('save %s/testmovie_%s_TimeConvolve_DimFlash_shift%d.mat testmovie',loadsave_dir,scheme,shift));

%% 
meanvalues = zeros(1,blocks);
stdvalues = zeros(1,blocks);
hist_8bit = zeros(256,blocks);
for i_blk   = 1:blocks
    i_blk
    mat     = double(NSEMmovie.fitmovie.movie_byblock{i_blk}.matrix(1:20,1:20,:));
    meanvalues(i_blk)  =  mean(mat(:));
    stdvalues(i_blk)   =  std(mat(:));
    hist_8bit(:,i_blk) = hist(mat(:),256);
end

eval(sprintf('load %s/inputstats_8pix_Identity_8pix.mat', loadsave_dir));
inputstats0 = inputstats;
July 15th 2014.
Interview with Mr Michael Elconin.  MBA, former state legislature in Wisconsin, CEO and founder of Cognionics, involved in technology throughout San Diego, involved in Sotera (didn?t know that before)
30 minutes Phone Conversation
General Notes:
Nice interview.  He was very cooperative.  He believes the sensors are already good enough, but getting the clinical trials in for FDA approval to demonstrate sensor reliability will be a challenge.  Converging onto the correct 
%%% The language (like .xml) will need to be standardized.  Not just choosing the radio but also the language which the radio transmits was his whole CS analogy.  This will be a big challlenge.  Standard structure is good, but can also stifle innovation.  API for each hospital  %%%  ???
Believes interest level in hospitals are high.  But also believes bigger gains will be seen in outpatient care.

Timeline: 5-10 years for common mass adoption
-Wearable wireless devices that monitor vitals will increase the efficiency of patient treatment. 7
-Wearable wireless devices that monitor vitals will decrease healthcare costs long-term (specifically in-patient hospital monitoring)    5




Mentioned
(Y/N)
Notes:
Benefits
--
--
Patient Comfort

N






Patient Outcomes

Y






Efficiency of care


Y






Reduction of costs

Y









Barriers to adoption
--
--
Cost

N








Connectedness


Y




- wifi interference
IT Compatibility





Y
- choosing the correct language for these devices to use
- needs to converge to a couple standards
Security (of networks)






N


Regulation (of devices)







Y
Need alot of clinical trials!
demonstrate sensor reliability to FDA
demonstrate the entire system works as a whole
Other
--
--
Power





y
need to find ways for long duration powering of these devices












plot(squeeze(testmovie0.matrix(20,20,100:320)))
hold on;
plot(squeeze(testmovie.matrix(20,20,100:320)),'r')
close all
plot(squeeze(testmovie0.matrix(20,20,100:320)))
hold on;
plot(squeeze(testmovie.matrix(20,20,100:320)),'r')
plot(squeeze(testmovie.matrix(20,20,100:320)),'k')











Standards   .xml, beyond that standards gets pretty loose
allow other packages  put into .xml format
no standarde for xml language that goes on top of that
every device has its own particular needs ... each language

Sotera is transmitting package of vital signs .. want data to get straigh into hospital information systems... data with same structure .. don't accomodate change very well.. can stifle innovation ... they do not have standard that they can write too.
API for each hospital 




inputstats.cmodel = 'TimeConvolve_DimFlash';
inputstats.mu_avgIperpix = mean(meanvalues);
inputstats.std_avgIperpix = mean(stdvalues);
inputstats.hist_8bit = mean(hist_8bit,2);

eval(sprintf('save %s/inputstats_TimeConvolve_DimFlash.mat inputstats',loadsave_dir));    
    
    
    
%}




    