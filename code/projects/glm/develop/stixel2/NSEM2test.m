
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AKHeitman 2015-04-02

% Creates structure which dictates GLMType
% Loads cells 
% Loads stimuli / basic stimuli processing
% Loads spike trains / basic spike train processing
% Requires the organizedspikes structure with spike times relative
%    to start of each block of stimulus
% No direct GLM Paramater usage
% Feeds into glm_execute which is located in glm_core directory
% glm_execute along with glm_core 
%    which has no additional code dependencies, no loading of matfiles

% INPUTS
% exps: an array of which exps to run (1-4)
% stimtypes: 1 = WN, 2=NSEM
% celltypes: 1 = ON, 2 = OFF parasols
% cell_subset: 'all' 'shortlist' or 'debug'
% glm_settings: optional
% runoptions: optional

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Wrap_bookeeping Calls %
%  NSEM_BaseDirectories
%  GLM_Settings
%  GLM_fitname
%  NSEM_secondaryDirectories
%  loadmoviematfiles
%  StimulusParams

% Main Call %
%   glm_execute  

% Subroutines at bottom of function
%  subR_concat_fitspikes_fromorganizedspikes
%  subR_createraster
%  subR_concat_fitmovie_fromblockedcell
%  subR_visionSTA_to_xymviCoord

% Sample Call and Output to verify that it works
%{
exps = 3;
stimtypes = [1]; % white noise only  (2 is natural scens)
celltypes = [1]; % only ON Parasol
cell_subset = 'debug';
glm_settings{1}.type = 'debug';
glm_settings{1}.name = 'true';
runoptions.replace_existing = true;
glm_wrap(exps,stimtypes,celltypes,cell_subset,glm_settings,runoptions)

%%% Should have the following minimization sequence  
### running: WN expC ONPar_2824: debug_fixedSP_rk1_linear_MU_PS_noCP_p8IDp8/standardparams ###

                                Norm of      First-order 
 Iteration        f(x)          step          optimality   CG-iterations
     0            1297.56                         2e+04                
     1            1297.56             10                    4
     2           -42251.5            2.5       2.56e+03           0
     3           -45320.3        4.13912       5.15e+03           7

Local minimum possible.
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NSEM2test(exps,stimtypes,celltypes,cell_subset,glm_settings, runoptions)

% Load core directories and all eligible cells
BD = NSEM_BaseDirectories;
eval(sprintf('load %s/allcells.mat', BD.Cell_Selection));

% Define structure which uniquely defines GLM to be used 
if exist('glm_settings', 'var')
    GLMType = GLM_settings('default',glm_settings);
else
    GLMType = GLM_settings('default');
end
GLMType.fitname    = GLM_fitname(GLMType); 
GLMType.func_sname = 'glmwrap';
GLMType.fullmfilename =mfilename('fullpath'); 
display(sprintf('Full Model Fit Parameters are:  %s', GLMType.fitname));

% Run options, order cells for fitting
if exist('runoptions','var')
    if isfield(runoptions,'replace_existing')
        replace_existing  = true;
    end
    if isfield(runoptions,'reverseorder')
        reverseorder  = true;
    end
end



for i_exp = exps    
    for i_stimtype = stimtypes
        % Load master datarun, bookkeep
        exp_nm  = allcells{i_exp}.exp_nm;
        expname = allcells{i_exp}.expname;
        eval(sprintf('load %s/%s/datarun_master.mat', BD.BlockedSpikes,exp_nm));
        if i_stimtype == 1, stimtype = 'WN';   end
        if i_stimtype == 2, stimtype = 'NSEM'; end
        GLMType.fit_type = stimtype;
   
        % Load and process stimulus
        [StimulusPars, exp_info] = StimulusParams(exp_nm, stimtype, GLMType.map_type);
        inputstats.stimulus = 'eye-120-3_0-3600';
        inputstats.cmodel = '8pix_Identity_8pix';
        % inputstats.dim = [29,29]; % doesn't matter
        inputstats.mu_avgIperpix = 58.7236;
        % inputstats.std_avgIperpix = 0.5229; % also appears to not matter
        inputstats.range = 255;
        %[blockedmoviecell, inputstats, origmatfile] = loadmoviematfile(exp_nm , stimtype, GLMType.cone_model,'fitmovie');
        %[testmovie0]          = loadmoviematfile(exp_nm , stimtype, GLMType.cone_model,'testmovie');
        %testmovie             = testmovie0{1}.matrix(:,:,StimulusPars.slv.testframes);
        %GLMType.fitmoviefile  = origmatfile;
        if GLMType.debug
            StimulusPars.slv.FitBlocks = StimulusPars.slv.FitBlocks(1:10);
        end
        %fitmovie_concat       = subR_concat_fitmovie_fromblockedcell(blockedmoviecell , StimulusPars.slv); 
         
        % Directories  
        secondDir.exp_nm    = exp_nm; 
        secondDir.map_type  = GLMType.map_type; 
        secondDir.stim_type = stimtype;
        secondDir.fitname   = GLMType.fitname;
        Dirs.fittedGLM_savedir  = NSEM_secondaryDirectories('savedir_GLMfit', secondDir);
        Dirs.WN_STAdir          = NSEM_secondaryDirectories('WN_STA', secondDir); 
        Dirs.organizedspikesdir = NSEM_secondaryDirectories('organizedspikes_dir', secondDir); 

        if ~exist(Dirs.fittedGLM_savedir), mkdir(Dirs.fittedGLM_savedir); end                  
        display(sprintf('Save Directory :  %s', Dirs.fittedGLM_savedir));
                
        for i_celltype = celltypes            
            % Choose which subset of cells to run
            if i_celltype == 1; cellgroup = allcells{i_exp}.ONP;  celltype = 'ONPar'; end
            if i_celltype == 2; cellgroup = allcells{i_exp}.OFFP; celltype = 'OFFPar'; end
            if strcmp(cell_subset,'all')
                candidate_cells = [allcells{i_exp}.ONP allcells{i_exp}.OFFP]
            elseif strcmp(cell_subset,'shortlist') || strcmp(cell_subset, 'debug')
                [~,candidate_cells,~]  = cell_list(i_exp, cell_subset);
                candidate_cells = cell2mat(candidate_cells) ;
            elseif strcmp(cell_subset,'glmconv_4pct')
                eval(sprintf('load %s/allcells_glmconv.mat', BD.Cell_Selection));
                conv_column = 2;
                conv_index_ON = find(allcells_glmconv{i_exp}.ONP_CONV(:,conv_column));
                conv_index_OFF = find(allcells_glmconv{i_exp}.OFFP_CONV(:,conv_column));
                candidate_cells = [allcells{i_exp}.ONP(conv_index_ON) allcells{i_exp}.OFFP(conv_index_OFF)];
            end
            % NBCoupling 2015-04-20
            if GLMType.CouplingFilters
                cells_to_pair = repmat(cellgroup,2,1);
                for i_pair = 1:length(cellgroup)
                    cells_to_pair(2,i_pair) = find(datarun_master.cell_ids == cellgroup(i_pair));
                end
            end
            cellgroup = intersect(candidate_cells, cellgroup);
            
            if exist('reverseorder','var') && reverseorder, cellgroup = fliplr(cellgroup); end
            
            for i_cell = 1:length(cellgroup)
                cid = cellgroup(i_cell);
                cell_savename = sprintf('%s_%d', celltype,cid);
                if ~exist(sprintf('%s/%s.mat', Dirs.fittedGLM_savedir,cell_savename)) || (exist('replace_existing','var') && replace_existing)
                    % Create cell information structure
                    glm_cellinfo.cid            = cid;
                    glm_cellinfo.exp_nm         = exp_nm;
                    glm_cellinfo.celltype       = celltype;
                    glm_cellinfo.cell_savename  = cell_savename;
                    glm_cellinfo.fitname        = GLMType.fitname;
                    glm_cellinfo.d_save         = Dirs.fittedGLM_savedir;
                    glm_cellinfo.computedtstim  = StimulusPars.slv.computedtstim;
                    
                    % Correct to 2-stixel
                    StimulusPars.slv.height = 4*StimulusPars.slv.height;
                    StimulusPars.slv.width = 4*StimulusPars.slv.width;
                    
                    % Add WN-STA and slave coordinates to glm_cellinfo
                    eval(sprintf('load %s/STAandROI_%s.mat STAandROI', Dirs.WN_STAdir, cell_savename));
                    master_idx         = find(datarun_master.cell_ids == cid);
                    stafit_centercoord = ( datarun_master.vision.sta_fits{master_idx}.mean );
                    stafit_sd          = ( datarun_master.vision.sta_fits{master_idx}.sd   );
                    slvdim.height      = StimulusPars.slv.height;
                    slvdim.width       = StimulusPars.slv.width;
                    [center_coord,sd]  = subR_visionSTA_to_xymviCoord(stafit_centercoord, stafit_sd, StimulusPars.master, slvdim);
                    glm_cellinfo.WN_STA = STAandROI.STA;

                    % NBCoupling 06-10-2014
                    if GLMType.CouplingFilters==true
                        % eval(sprintf('load %s/neighbor_cells.mat', BD.Cell_Selection));
                        glm_cellinfo.pairs=subR_pick_neighbor_cells(stafit_centercoord, cells_to_pair, datarun_master.vision.sta_fits);
                    else
                        glm_cellinfo.pairs=0;
                    end
                    % end NBCoupling
                    
                    % Load Blocked-Spikes from preprocessing
                    eval(sprintf('load %s/organizedspikes_%s.mat organizedspikes', Dirs.organizedspikesdir, cell_savename));
                    
                    % Process spikes for glm_execute with proper subroutines
                    fitspikes_concat.home  = subR_concat_fitspikes_fromorganizedspikes(organizedspikes.block, StimulusPars.slv);
                    testspikes_raster.home = subR_createraster(organizedspikes.block, StimulusPars.slv);
                    
                    disp('loading the fitmovie')
                    GLMPars = GLMParams;
                    % Load relevant movie section
                    tic;
                    [fitmovie_concat testmovie] = subR_concat_fitmovie(center_coord, StimulusPars.slv, GLMPars.stimfilter.ROI_length);
                    toc
                    glm_cellinfo.slave_centercoord.x_coord = ceil(GLMPars.stimfilter.ROI_length/2);
                    glm_cellinfo.slave_centercoord.y_coord = ceil(GLMPars.stimfilter.ROI_length/2);
                    clear GLMPars
                    
                    %
                    if GLMType.STA_init || strcmp(GLMType.stimfilter_mode, 'fixedSP_rk1_linear')
                        disp('Calculating NSEM STA')
                        glm_cellinfo.WN_STA = STA_Test(fitspikes_concat.home, fitmovie_concat, false, StimulusPars.slv.computedtstim);
                    end
                    
                    % NBCoupling 2014-04-20
                    if GLMType.CouplingFilters
                        n_couplings=length(glm_cellinfo.pairs); % number of cells to couple to
                        % loading the neighboring spikes to neighborspikes.home
                        for i_pair=1:n_couplings
                            glm_cellinfo.pair_savename{i_pair}  = sprintf('%s_%d', celltype,glm_cellinfo.pairs(i_pair));
                            eval(sprintf('load %s/organizedspikes_%s.mat organizedspikes', Dirs.organizedspikesdir,  glm_cellinfo.pair_savename{i_pair}));
                            neighborspikes.home{i_pair} = subR_concat_fitspikes_fromorganizedspikes(organizedspikes.block, StimulusPars.slv);
                            neighborspikes.test{i_pair} = subR_createraster(organizedspikes.block, StimulusPars.slv);
                            % neighbor_organizedspikes{j}=organizedspikes;
                        end
                    else
                        neighborspikes.home = 0;
                        neighborspikes.test = 0;
                    end
                    % end NBCoupling
                    
                    
                    
                    % Call appropriate glm_execute
                    display(sprintf('### running: %s %s %s: %s ###', stimtype, expname, cell_savename,GLMType.fitname))
                    tStart = tic;
                    if isfield(GLMType, 'DoubleOpt') && GLMType.DoubleOpt
                        [fittedGLM, manual_search] = glm_execute_DoubleOpt_Manual(GLMType, ...
                            fitspikes_concat,fitmovie_concat,testspikes_raster,testmovie,inputstats,glm_cellinfo);
                    else
                        [fittedGLM] = glm_execute(GLMType,fitspikes_concat,fitmovie_concat,...
                            testspikes_raster,testmovie,inputstats,glm_cellinfo,neighborspikes); % NBCoupling 2015-04-20
                    end
                    duration = toc(tStart);
                    display(sprintf('### runtime of %1.1e minutes ###', duration/60)); clear tStart duration tic
                end
            end
        end
    end
end

end


function spikesconcat      = subR_concat_fitspikes_fromorganizedspikes(blockedspikes, FitPars)
% AKHeitman 2014-04-14
% Concatenate Spikes from different blocks to a single spike train
% blocekdspikes: needs
%   .t_sp_withinblock
%
% FitPars needs
%   .fittest_skipseconds
%   .tstim
%   .fitframes
%   .FitBlocks


t_start   = FitPars.fittest_skipseconds;
tstim     = FitPars.computedtstim;
fitframes = FitPars.fitframes;
FitBlocks = FitPars.FitBlocks;


T_SP = []; blk_count = 0;
dur = tstim * length(fitframes);
for k = FitBlocks
	blk_count = blk_count + 1;
	t_sp_full = blockedspikes.t_sp_withinblock{k} ; % unit of time: sec, 0 for the onset of the block
	t_sp      = t_sp_full(find(t_sp_full >  t_start));
	t_sp = t_sp - t_start;
	t_spcontext = t_sp + ( blk_count -1 )*dur;
	T_SP = [T_SP ; t_spcontext];
end
spikesconcat = T_SP;
end

function raster_spiketimes = subR_createraster(blockedspikes, TestPars)
% AKHeitman 2014-04-14
% Make a raster which takes into account GLM processing
% blocekdspikes: needs
%   .t_sp_withinblock
%
% TestPars needs
%   .fittest_skipseconds
%   .TestBlocks

rasterblocks = TestPars.TestBlocks;
t_start      = TestPars.fittest_skipseconds;

raster_spiketimes = cell(length(rasterblocks),1);

for i_blk = 1 : length(rasterblocks)
	blknum = rasterblocks(i_blk);
	sptimes = blockedspikes.t_sp_withinblock{blknum} - t_start;
	sptimes = sptimes(find(sptimes > 0 ) );
    % HACK NEEDED FOR 2013-10-10-0 and other long runs
    if isfield(TestPars, 'test_skipENDseconds')
        sptimes = sptimes(find(sptimes < (TestPars.test_skipENDseconds - TestPars.fittest_skipseconds - .1)));
    end
    
    raster_spiketimes{i_blk} = sptimes;
end 

end

function concat_fitmovie   = subR_concat_fitmovie_fromblockedcell(blockedmoviecell , FitPars)
% AKHeitman 2014-04-14
% Concatenate the fit movie (different blocks)
% FitPars needs
%   .width
%   .height
%   .FitBlocks
%   .novelblocks
%   .fitframes

height       = FitPars.height;
width        = FitPars.width;
fitblocks    = FitPars.FitBlocks;
fitframes    = FitPars.fitframes;
novelblocks  = FitPars.NovelBlocks;

fitframesperblock = length(fitframes) ;
totalframes       = length(fitblocks) * ( fitframesperblock) ;
concat_fullfitMovie = uint8(zeros(width, height, totalframes)) ;
for i_blk = fitblocks
        blkind = find(fitblocks == i_blk);
        framenums = ( (blkind -1)*fitframesperblock + 1 ) :  (blkind *fitframesperblock);  
        n_blkind = find(novelblocks == i_blk);
        concat_fullfitMovie(:,:,framenums) = blockedmoviecell{n_blkind}.matrix (:,:, fitframes);    
end

concat_fitmovie = concat_fullfitMovie;

end

function [center,sd]       = subR_visionSTA_to_xymviCoord(stafit_centercoord, stafit_sd, masterdim, slvdim)
% AKHeitman  2013-12-08
% Grab x, y coordinates of STA center of the master
% Convert to coordinates of the enslaved dataset 
x_coord   = round( stafit_centercoord(1)* (slvdim.width  /masterdim.width)  );
y_coord   = slvdim.height - round( stafit_centercoord(2)* (slvdim.height /masterdim.height) );

center.x_coord = x_coord;
center.y_coord = y_coord;

sd.xdir = round( stafit_sd(1)* (slvdim.width   / masterdim.width)  );
sd.ydir = round( stafit_sd(2)* (slvdim.height  / masterdim.height)  );

end

%NBCoupling 2015-04-20
function paired_cells=subR_pick_neighbor_cells(mean, cell_ids, sta_fits)
    
     GLMPars = GLMParams;
     NumCells = length(cell_ids);
     distance=zeros(NumCells,1);
     
     % Calculate distance between RFs
     for i_pair=1:NumCells
         distance(i_pair)=norm(sta_fits{cell_ids(2,i_pair),1}.mean-mean);
         if distance(i_pair)==0
             distance(i_pair)=NaN;
         end
     end
     
     % Choose the closest cells
     [~,indices]=sort(distance);
     paired_cells=cell_ids(1,indices(1:GLMPars.spikefilters.cp.n_couplings));

end

function [concat_movie, testmovie] = subR_concat_fitmovie(center, StimPars, ROI_length)
%% Load up part of the fitmovie
stimsize.height = StimPars.height;
stimsize.width = StimPars.width;
% temp = center;
% center.y_coord = temp.x_coord;
% center.x_coord = temp.y_coord;
ROI = ROI_coord(ROI_length, center, stimsize);
frames_per_block = length(StimPars.fitframes);
blocks = length(StimPars.FitBlocks);

% Load the movie
concat_movie = zeros(ROI_length, ROI_length, frames_per_block*blocks);
idx = 1:frames_per_block;
for i=1:blocks
    block = StimPars.FitBlocks(i);
    load(['/Volumes/Lab/Users/Nora/NSEM_Movies/eye-120-3_0-3600/movieblock' num2str(block/2) '.mat'])
    concat_movie(:,:,idx) = permute(movie.matrix(StimPars.fitframes, ROI.xvals, ROI.yvals),[2 3 1]);
    idx = idx+frames_per_block;
end
clear movie
load(['/Volumes/Lab/Users/Nora/NSEM_Movies/eye-120-3_0-3600/testmovie.mat'])
testmovie = permute(movie.matrix(StimPars.testframes, ROI.xvals, ROI.yvals),[2 3 1]);
end