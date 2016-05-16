% NB 2014-10-9
% get data into a reasonable shape to share

% Data Type
clear; close all;  clc
GLMType.cone_model = '8pix_Identity_8pix'; GLMType.cone_sname='p8IDp8';%
GLMType.map_type = 'mapPRJ';
i_exp = 1; i_cell = 1;
i_exp = 1;
cellselectiontype = 'all';
GLMType.fit_type = 'WN';

% load basic info
expnumber = i_exp;
[exp_nm,cells,expname]  = cell_list( expnumber, cellselectiontype);
cells
[StimulusPars DirPars datarun_slv datarun_mas] = Directories_Params_v23(exp_nm, GLMType.fit_type, GLMType.map_type);
clear boolean_debug map_type fit_type shead_cellID expname
inputs.exp_nm    = exp_nm;
inputs.map_type  = GLMType.map_type;
inputs.stim_type = GLMType.fit_type;

% load movie
clear Main_SolPars Other_SolParss
[blockedmoviecell, inputstats, origmatfile] = loadmoviematfile(exp_nm , GLMType.fit_type, GLMType.cone_model,'fitmovie');
[testmovie] = loadmoviematfile(exp_nm , GLMType.fit_type, GLMType.cone_model,'testmovie');
clear origmatfile

for i=1:length(blockedmoviecell)
    WNStimData.FitMovie{i}=blockedmoviecell{i}.matrix;
end
WNStimData.TestMovie=testmovie{1}.matrix;
clear blockedmoviecell blockstartframe fitblocks fitframesperblock framenums
%}

%% Load STA and spikes
inputs.exp_nm       = exp_nm;
inputs.map_type     = GLMType.map_type;
DirPars.WN_STAdir   = NSEM_secondaryDirectories('WN_STA', inputs);
inputs.stim_type    = GLMType.fit_type;

DirPars.organizedspikesdir = NSEM_secondaryDirectories('organizedspikes_dir', inputs);
clear inputs

for i_cell = 1:length(cells)
    cid = cells{i_cell};
    [~ , cell_savename, ~]  = findcelltype(cid, datarun_mas.cell_types);
    
    master_idx         = find(datarun_mas.cell_ids == cid);
    stafit_centercoord = ( datarun_mas.vision.sta_fits{master_idx}.mean );
    stafit_sd          = ( datarun_mas.vision.sta_fits{master_idx}.sd   );
    slvdim.height      = StimulusPars.slv.height; slvdim.width = StimulusPars.slv.width;
    [center_coord,sd]  = visionSTA_to_xymviCoord(stafit_centercoord, stafit_sd, StimulusPars.master, slvdim);
    clear master_idx stafit_centercoord slvdim sd
    
    eval(sprintf('load %s/organizedspikes_%s.mat organizedspikes', DirPars.organizedspikesdir, cell_savename));
    eval(sprintf('load %s/STAandROI_%s.mat STAandROI', DirPars.WN_STAdir, cell_savename));
    
    eval(['WNCellData.' cell_savename '.Spikes=organizedspikes.block.t_sp_withinblock;'])
    eval(['WNCellData.' cell_savename '.STA=STAandROI.STA;'])
    
end

% Save data structures
save('WNStimData.mat','WNStimData');
save('WNCellData.mat','WNCellData');
clear; close all;  clc
