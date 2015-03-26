% done toward end of 2014
%{
Here's what I'd suggest: divide your data into 10 folds.  For each
fold, grab 90% of the data, compute the PSTH in 1ms bins, and smooth
the psth with a Gaussian with some stdev.  Here I'd suggest using a
grid of sigma values and use cross-validation to select which is best.
Maybe sigma = 0.5 ms, 1, 2, 4, 8, 16, 32, 64, should suffice.  Then
compute the log-likelihood of the remaining 10% of the data using the
smoothed PSTH from the 90% training data as the estimate for the
conditional intensity lamda(t).  You should expect the test likelihood
to peak somewhere in the middle of this range of sigmas (depending on
how many repeats you have, and how precise the actual neuron is).  If
there's really 1ms precision in your raster, then the 1ms-smoothed
PSTH  should do the best at predicting the remaining 10%.
%}




%% DICTATE GLMTYPE and Datasets and cells  EDITS DONE HERE! 
clear; close all;  clc

%%

GLMType.debug = false;
GLMType.fit_type = 'WN'; GLMType.map_type = 'mapPRJ'; 

%  LOOP THROUGH DATA SETS
bins_per_frame = 10;
BD = NSEM_BaseDirectories;
exptests = [1 2 3 4];
cellselectiontype = 'debug';
%cellselectiontype = 'debug';
cellselectiontype = 'shortlist';

outputdir = sprintf('%s/newtestcode/raster_precision', BD.GLM_codehome);
if ~exist(outputdir, 'dir'), mkdir(outputdir); end

i_exp = 1; i_cell = 1;
%%

for i_exp = exptests
    %% 
    expnumber = i_exp;
    [exp_nm,cells,expname]  = cell_list( expnumber, cellselectiontype);
    cells
    
    [StimulusPars DirPars datarun_slv datarun_mas] = Directories_Params_v23(exp_nm, GLMType.fit_type, GLMType.map_type);
    SPars  = StimulusPars.slv;
    clear boolean_debug map_type fit_type shead_cellID expname 
    
    %%%%%% Name and Create a Save Directory %%%%%%%%%%%
   
    

    % Load Cell Specific Elements   Spikes and STA
    inputs.exp_nm       = exp_nm; 
    inputs.map_type     = GLMType.map_type; 
    inputs.stim_type    = GLMType.fit_type;
    DirPars.organizedspikesdir = NSEM_secondaryDirectories('organizedspikes_dir', inputs); 
    clear inputs
    
%%
    for i_cell = 1:length(cells)
        clear glm_cellstruct
        cid = cells{i_cell};
        [celltype , cell_savename, ~]  = findcelltype(cid, datarun_mas.cell_types);  
        
        cellinfo.cid           = cid;
        cellinfo.exp_nm        = exp_nm;
        cellinfo.celltype      = celltype;
        cellinfo.cell_savename = cell_savename;
        cellinfo.fit_type      = GLMType.fit_type;
        cellinfo.computedtstim = StimulusPars.slv.computedtstim;
        
        eval(sprintf('load %s/organizedspikes_%s.mat organizedspikes', DirPars.organizedspikesdir, cell_savename));
        
        [optimal_binnumber] = raster_precision(bins_per_frame, SPars, organizedspikes)
            
        
    end
    
end


