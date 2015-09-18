%spaceonly: Blow it up and justcheck the space filter
% Based upon using a fixedSP first 

% hack code!  refitting 2014-02-19



%%   Generic initialization 

clear; close all
% INITIALIZATION AND DIRECTORY IDENTIFICATION / IMPORTANT PARAMS
map_type = 'mapPRJ'; boolean_debug = true;  tolfun = 3; checkconv = false;  
cmodel = '8pix_Model1_1e4_8pix';
%cmodel = '8pix_Identity_8pix';  
filterfit_type = 'rect_clipmean_fixedSP';
%filterfit_type = 'fixedSP';

i_exp = 1; i_fit= 2;
%%
for i_exp = 1:4
    
    clear exp_nm shead_cellID
    if i_exp == 1, exp_nm = '2012-08-09-3' ; head_cellID =   [1471  841 3676 5086 5161 1426 1772 2101 1276]; end
    if i_exp == 2, exp_nm = '2012-09-27-3'; head_cellID =     [1 31 301 1201 1726 91 1909 2360 6858];  end
    if i_exp == 3,  exp_nm = '2013-08-19-6'; head_cellID = [737 1328 1341 2959  2824 3167 3996 5660 6799 5447]; end
    if i_exp == 4, exp_nm = '2013-10-10-0'; head_cellID = [346 1233 3137 7036 5042 5418 32 768 2778 4354 5866];end


%%
for i_fit = 1:2
    if i_fit ==1
        fit_type = 'NSEM';
    end
    if i_fit ==2
        fit_type = 'BW';
    end

oldfittype = sprintf('%s_%s/%s_Fit' , fit_type, map_type, fit_type);
oldfitparams = sprintf('%s_ps20_cpOFF/bin10_blk55_tolfun6/%s', filterfit_type, cmodel);
if strcmp(exp_nm, '2013-10-10-0')
    oldfitparams =  sprintf('%s_ps20_cpOFF/bin10_blk27_tolfun6/%s', filterfit_type, cmodel);
end
if strcmp(fit_type, 'BW')
     oldfitparams = sprintf('%s_ps20_cpOFF/bin10_blk50_tolfun6/%s', filterfit_type, cmodel);
end
    


[StimulusPars DirPars datarun_slv datarun_mas] = Directories_Params_v19_split(exp_nm, fit_type, map_type);


stimulidir = '/netapp/snle/lab/Experiments/Array/Analysis/akheitman/NSEM_Projects/Stimuli';

if strcmp(fit_type, 'NSEM')  
    if strcmp(exp_nm, '2012-08-09-3') || strcmp(exp_nm, '2012-09-27-3') 
        moviename = 'eye-120-3_0-3600';
        scheme = 'schemeA';
    end
    if strcmp(exp_nm, '2013-08-19-6')
        moviename = 'eye-long-v2';
        scheme = 'schemeA';
    end
    if strcmp(exp_nm, '2013-10-10-0')
        moviename = 'FEM900FF_longrast'
        scheme = 'schemeB';
    end

    eval(sprintf('load %s/NSEM_%s/fitmovie_%s_%s', stimulidir,moviename,scheme, cmodel)); 
    fullmovie_struct = NSEMmovie;
    eval(sprintf('load %s/NSEM_%s/inputstats_%s', stimulidir, moviename, cmodel));
    
    
end
%%
%{
if strcmp(fit_type, 'NSEM')
    
    if strcmp(exp_nm, '2013-08-19-6')
        load /netapp/snle/lab/Experiments/Array/Analysis/akheitman/NSEM_Projects/Stimuli/NSEM_eye-long-v2/fitmovie_schemeA_8pix_Identity_8pix.mat
        load /netapp/snle/lab/Experiments/Array/Analysis/akheitman/NSEM_Projects/Stimuli/NSEM_eye-long-v2/inputstats_8pix_Identity_8pix.mat
    end

    if strcmp(exp_nm, '2013-10-10-0')
        load /netapp/snle/lab/Experiments/Array/Analysis/akheitman/NSEM_Projects/Stimuli/NSEM_FEM900FF_longrast/fitmovie_schemeB_8pix_Identity_8pix.mat
        load /netapp/snle/lab/Experiments/Array/Analysis/akheitman/NSEM_Projects/Stimuli/NSEM_FEM900FF_longrast/inputstats_8pix_Identity_8pix.mat
    end
    fullmovie_struct = NSEMmovie;
end
%}


if strcmp(fit_type, 'BW') && strcmp(cmodel ,'8pix_Identity_8pix')
    load /netapp/snle/lab/Experiments/Array/Analysis/akheitman/NSEM_Projects/Stimuli/BW-8-1-0.48-11111_RNG_16807/BWmovie.mat
    fullmovie_struct = BWmovie;
    inputstats.mu_avgIperpix = .5
end

if strcmp(fit_type, 'BW') && strcmp(cmodel ,'8pix_Model1_1e4_8pix')
    load /netapp/snle/lab/Experiments/Array/Analysis/akheitman/NSEM_Projects/Stimuli/BW-8-1-0.48-11111_RNG_16807/fitmovie_8pix_Model1_1e4_8pix.mat
	fullmovie_struct = BWmovie; clear BWmovie
	fullmovie_struct.params.fit_frames = 3600;
	fullmovie_struct.fitmovie.ind_to_block = 2:2:120;
    inputstats.mu_avgIperpix = .5
    fullmovie_struct
end
    


%%

if boolean_debug && isfield(StimulusPars, 'BW')
    StimulusPars.BW.FitBlocks = StimulusPars.BW.FitBlocks(1:2);
end
if boolean_debug && isfield(StimulusPars, 'NSEM')
    StimulusPars.NSEM.FitBlocks = StimulusPars.NSEM.FitBlocks(1:2);
end
if strcmp(fit_type, 'NSEM')
    Slv_StimPars = StimulusPars.NSEM;
end
if strcmp(fit_type, 'BW')
    Slv_StimPars = StimulusPars.BW;
end




datarun{1} = datarun_mas;
datarun{2} = datarun_slv;



  
concat_fullfitMovie = uint8(zeros(fullmovie_struct.params.width, fullmovie_struct.params.height, ...
    length(Slv_StimPars.FitBlocks) * fullmovie_struct.params.fit_frames));
for i_blk = 1:length(Slv_StimPars.FitBlocks)
    blkind = find(fullmovie_struct.fitmovie.ind_to_block == Slv_StimPars.FitBlocks(i_blk));
    framenums = ((i_blk-1)*fullmovie_struct.params.fit_frames + 1 ) :  (i_blk*fullmovie_struct.params.fit_frames);        
    concat_fullfitMovie(:,:,framenums) = fullmovie_struct.fitmovie.movie_byblock{blkind}.matrix;
end
clear fullmovie_struct;


%%
cid = head_cellID(1);  

for cid = head_cellID
    clear celltype
    if ~isempty(find(datarun_mas.cell_types{1}.cell_ids == cid))
        celltype = 'ONPar';
    end
    if ~isempty(find(datarun_mas.cell_types{2}.cell_ids == cid))
        celltype = 'OFFPar';
    end
    
    sname = sprintf('%s_%d', celltype, cid)
    
    
    if ~isempty( find(datarun_slv.cell_ids == cid) )
    
    
    
if ~boolean_debug
    GLMdir = '/netapp/snle/lab/Experiments/Array/Analysis/akheitman/NSEM_Projects/GLM';
    
    
    
    
    load(sprintf('%s/%s/%s/%s/%s.mat' , GLMdir, exp_nm,oldfittype, oldfitparams , sname));
   % load /netapp/snle/lab/Experiments/Array/Analysis/akheitman/NSEM_Projects/GLM/2012-08-09-3/NSEM_mapPRJ/NSEM_Fit/fixedSP_ps20_cpOFF/bin10_blk55_tolfun6/8pix_Identity_8pix/OFFPar_5086.mat 
elseif boolean_debug
    load /netapp/snle/lab/Experiments/Array/Analysis/akheitman/NSEM_Projects/GLM/2012-08-09-3/NSEM_mapPRJ/NSEM_Fit/fixedSP_ps20_cpOFF/debug_bin10_blk2_tolfun6/8pix_Identity_8pix/OFFPar_5086.mat
end
origGLMPars  = Basepars.GLMPars;
origBasepars = Basepars;
GLMPars      = origGLMPars;
klen         = length(Basepars.ROI.xdim);

gopts = optimset(...
   'derivativecheck','off',...
   'diagnostics','off',...  % 
   'display','iter',...  %'iter-detailed',... 
   'funvalcheck','off',... % don't turn this on for 'raw' condition (edoi).
   'GradObj','on',...
   'largescale','on',...
   'Hessian','on',...
   'MaxIter',GLMPars.maxiter,... % you may want to change this
   'TolFun', 10^(-tolfun),...
   'TolX',10^(-(GLMPars.tolx)));

GLMPars.k_filtermode = 'onlySP';
if boolean_debug
    GLMPars.K_slen = GLMPars.fixedSPlength;
end
%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(GLMPars.fit_type,   'BW'), Slv_StimPars = StimulusPars.BW;  Slv_StimPars.tstim = Slv_StimPars.default_tstim;  fitdir =   'BW_Fit'; end
if strcmp(GLMPars.fit_type, 'NSEM'), Slv_StimPars = StimulusPars.NSEM; fitdir = 'NSEM_Fit'; end

close all
index                    = find(head_cellID == cid);


%%
%%%%%%%%%
numParams = klen^2;
p0 = Basepars.spfilter;  % after we have convergence\

if checkconv
    p0 = .1-.2*rand(size(Basepars.spfilter));
end

    

%%%%% LOAD UP THE ROI
novelROIstim_Concat = double(concat_fullfitMovie(Basepars.ROI.xdim,Basepars.ROI.ydim,:));
if strcmp(GLMPars.fit_type, 'NSEM') 
        novelROIstim_Concat = novelROIstim_Concat / 255 ; 
end
if strcmp(GLMPars.fit_type, 'BW') && strcmp(GLMPars.cone_model, '8pix_Model1_1e4_8pix')
        novelROIstim_Concat = novelROIstim_Concat / 255 ; 
end
novelROIstim_Concat = novelROIstim_Concat - inputstats.mu_avgIperpix;


 if isfield(GLMPars, 'rect') && GLMPars.rect
            if strcmp(GLMPars.rect_type , 'rect_clipmean')
                if strcmp(celltype, 'OFFPar')
                    clipind = find(novelROIstim_Concat > 0);
                elseif strcmp(celltype, 'ONPar')
                    clipind = find(novelROIstim_Concat < 0 );
                end
                
                novelROIstim_Concat(clipind) = 0;
            end
 end
 celltype
 minimumstim = min(novelROIstim_Concat(:))
 maximumstim = max(novelROIstim_Concat(:))


novelROIstim_Concat = reshape(novelROIstim_Concat , [klen^2, size(novelROIstim_Concat,3)]);
nspace = klen^2; stimFrames = size(novelROIstim_Concat,2);


p_opt = Basepars.p_opt;
parInd = Basepars.paramind;
PS = Basepars.ps_basis * p_opt(parInd.PS); 
timefilter = p_opt(parInd.L);


Trainpars.psbasisGrad = grad_basisAH([Trainpars.negSpikes_Home; Trainpars.logicalspike_microbin_Home],Basepars.ps_basis,0);
Trainpars.pslcif      = (p_opt(parInd.PS) )' * Trainpars.psbasisGrad{1,1}  ;


% these 3 ingredients and p0 should give us everything we need! %
nonspatial_lcif          = Trainpars.pslcif + p_opt(1);
dt                       = Basepars.dt;
timefilterconvolvedmovie = fastconvAH(novelROIstim_Concat,timefilter',nspace,stimFrames);

pstar = double(p0);
X = timefilterconvolvedmovie;
spiketrain = double(Trainpars.logicalspike_microbin_Home);
[pstar fstar eflag output] = fminunc(@(p) ll_func_SPonly_AH(p,nonspatial_lcif,X,spiketrain,dt),pstar,gopts);
[f_opt g_opt H_opt lcifs] = ll_func_SPonly_AH(pstar,nonspatial_lcif,X,spiketrain, dt);



norm_spatialfilter   = norm(pstar);
shape_spatialfilter  = pstar / norm(pstar);

savedir = sprintf('%s/updateSP_tolfun%d', Basepars.d_save,tolfun);
if ~exist(savedir), mkdir(savedir); end

filename = sprintf('optimspfilter_%s_%s', fit_type, Basepars.fn_save )
if checkconv
    filename = sprintf('xeckconv_optimspfilter_%s_%s', fit_type, Basepars.fn_save);
end


if isfield(GLMPars, 'rect') && GLMPars.rect
     filename = sprintf('%s_%s', GLMPars.rect_type, filename);
end











newvals.norm_spatialfiler   = norm_spatialfilter;
newvals.shape_spatialfilter = shape_spatialfilter;
newvals.oldfilter  = Basepars.spfilter;
newvals.f_opt = f_opt;
newvals.g_opt = g_opt;
newvals.H_opt = H_opt;
%%%%%%%%%%%

klen = sqrt(length(newvals.shape_spatialfilter))
filter0 = reshape(Basepars.spfilter, [klen,klen]);
filter1 = reshape(newvals.shape_spatialfilter, [klen, klen]);




[datapoints0 , f_nonoise0] = prep_2dGaussfit(filter0);
[datapoints1 , f_nonoise1] = prep_2dGaussfit(filter1);

figure; subplot(1,2,1); imagesc(filter0); subplot(1,2,2); imagesc(f_nonoise0); colorbar
figure; subplot(1,2,1); imagesc(filter1); subplot(1,2,2); imagesc(f_nonoise1); colorbar

gfit0 = gmdistribution.fit(datapoints0,1);
gfit1 = gmdistribution.fit(datapoints1,1);
[Q0,D0] = eig(gfit0.Sigma);
[Q1,D1] = eig(gfit1.Sigma);

newvals.fc.sigmaarea0 =  prod(diag(D0));
newvals.fc.sigmaarea1 =  prod(diag(D1));
newvals.fc.mu0    = gfit0.mu;
newvals.fc.sigma0 = gfit0.Sigma;
newvals.fc.mu1    = gfit1.mu;
newvals.fc.sigma1 = gfit1.Sigma;

newvals.fc.fullfit0 = gfit0;
newvals.fc.fullfit1 = gfit1;


newvals.fc.f_nonoise0 = f_nonoise0;
newvals.fc.f_nonoise1 = f_nonoise1;

newvals.fcnote  ='filter comparisons'

Basepars.spfilter_refitted.norm = norm_spatialfilter;
Basepars.spfilter_refitted.shape = shape_spatialfilter;
eval(sprintf('save %s/newspfilter_%s newvals Basepars', savedir, Basepars.fn_save) )








%newvals.lcifs = lcifs;





%%
opt_param = Basepars.opt_param;
info.cid = Basepars.headid;
info.exp_nm = Basepars.exp_nm;
info.fittype = Basepars.fit_type;
info.ctype = Basepars.celltype;
info.conemodel = Basepars.conemodel;
  

Z = Basepars.paramind;
p_opt = opt_param.p;
ps_basis = Basepars.ps_basis;
dt = Basepars.dt;
tstim =Basepars.tstim;
cid = Basepars.headid;
opt_param = Basepars.opt_param;
%clear Trainpars cid eflag output
%%
%%% Summary for non STA %%%
clf;
if strcmp(Basepars.k_filtermode, 'fixedSP')
    MU = p_opt(Z.MU);
    K  = (Basepars.spfilter)*(p_opt(Z.L)');
    PS = ps_basis * p_opt(Z.PS);
    clf
    subplot(3,2,1)
    set(gca, 'fontsize', 10)
    c = 0;
    c = c+1;
    text(0, 1-0.1*c,sprintf('%s Fit by %s',info.exp_nm, info.fittype))
    c = c+1;
    text(0, 1-0.1*c,sprintf('Cone Model: %s',info.conemodel))
    c = c+1;
    text(0, 1-0.1*c,sprintf('%s  Cell ID: %4d', info.ctype,info.cid))
    c = c+1;
    text(0, 1-0.1*c,sprintf('Tonic drive with gray stim: %d hz',round(exp(MU)))  )
    c = c+1;
	text(0, 1-0.1*c,sprintf('Original Optimum fmin: %1.3e',opt_param.f))
    c = c+1;
	text(0, 1-0.1*c,sprintf('New opt fmin: %1.3e',newvals.f_opt))
    c = c+1;
    text(0, 1-0.1*c,sprintf('SPfilter refit Functional Tolerance %d',tolfun))
    if isfield(Basepars.GLMPars, 'rect') && Basepars.GLMPars.rect
        c = c+1;
        text(0, 1-0.1*c,sprintf('Stim is Rectified with %s',Basepars.GLMPars.rect_type));
    end
    
    
	axis off


    
    subplot(3,2,2)
    set(gca, 'fontsize', 12)
    c = 0;
    c = c+1;
    text(0, 1-0.1*c,sprintf('Comparison of Spatial Filters',info.exp_nm, info.fittype))
    c = c+1;
    text(0, 1-0.1*c,sprintf('Gauss Std ratio refit/STA %1.3e', (newvals.fc.sigmaarea1/ newvals.fc.sigmaarea0)) )
    c = c+1;
    text(0, 1-0.1*c,sprintf('Shift in Gauss Center [%d, %d]', round(newvals.fc.mu0(1) - newvals.fc.mu1(1)) ,  round(newvals.fc.mu0(2) - newvals.fc.mu1(2))  ) )
    c = c + 1;
    text(0, 1-0.1*c,sprintf('Norm of Opt Filter  %1.3e', newvals.norm_spatialfiler  ) )
    
    
    
    axis off
    
        
    spfilter = (Basepars.spfilter);
    newspfilter = newvals.shape_spatialfilter;
    climmax = max( max(spfilter), max(newspfilter) );
    climmin = min( min(spfilter), min(newspfilter) );
    col_ax = [climmin, climmax];
    klen = sqrt(length(spfilter));
    
    subplot(3,2,3)  % label in 50 msec intervals
    imagesc(reshape(spfilter,[klen,klen]) , col_ax);
    colorbar
    title('BW STA')
    
    subplot(3,2,4)  % label in 50 msec intervals
    imagesc(reshape(newspfilter,[klen,klen]), col_ax);
    colorbar
    title('normed optimized filter')
    LW = 2;
    
%{
    
    gfitBWSTA = gfit0;
    gfitopt   = gfit1;  
    
    subplot(5,2,5)
    h1 = ezcontour(@(r,c)pdf(gfitBWSTA,[r c]),[1 klen],[1 klen]); %colorbar
    subplot(5,2,6)
    h2 = ezcontour(@(r,c)pdf(gfitopt,[r c]),[1 klen],[1 klen]); %colorbar
    
    
    subplot(5,2,7)  % label in 50 msec intervals
    imagesc(newvals.fc.f_nonoise0); %colorbar
   % colorbar
    title('BW STA pregf')
    
    subplot(5,2,8)  % label in 50 msec intervals
    imagesc(newvals.fc.f_nonoise1); %colorbar
    %colorbar
    title('normed optimized filter pregf')
    LW = 2;
    
  %}  
    
    subplot(3,2,5)
    set(gca, 'fontsize', 12)
    timebins = length(PS);
    t_ps = 1000*(0:dt:(timebins-1)*dt);
	plot(t_ps,exp(PS),'linewidth',LW)
	hold on
	plot([0,t_ps(end)],[1,1],'k--') % black reference line 
    ylabel('Gain')
    xlabel('Time [msec]')
    title('Post-Spike Filter')
    xlim([0,t_ps(end)])
    hold off

    
    subplot(3,2,6)
    set(gca, 'fontsize', 12)
    timebins = length(Z.L);
    t_tf = 1000*(0:dt:(timebins-1)*dt);
    
    plot(t_tf,p_opt(Z.L),'linewidth',LW)
	hold on
	plot([0,t_tf(end)],[0,0],'k--') % black reference line 
    xlabel('Time [msec]')
    xlim([0,t_tf(end)])
	title(sprintf('Time cours .. temporal filter'));
    %}
        

    %
%%%%%%%%%%%


        orient tall
        eval(sprintf('print -dpdf %s/%s',savedir, filename))
end




end



end
end
end