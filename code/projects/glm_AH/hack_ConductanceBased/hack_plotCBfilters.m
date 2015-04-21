%%% PURPOSE %%%
% Load up saved fittedGLM
% Run appropriate xval performance test and plotting
% Good general template for future metric changes


% Born out of hesitance to hard code Conductance-Based into glmwrap25
% Specifically looking to address Conductance-Based Models

% AKHEITMAN 2014-12-17



clear; close all;  clc
exps = [2 3 4]; 
%exps = 1
stimtypes = [1];
celltypes = [1 2];
i_exp = 1; i_stimtype = 1; i_celltype = 1;



%changes_cell{1}.type = 'filter_mode';
%changes_cell{1}.name = 'rk1';

changes_cell{1}.type = 'filter_mode';
changes_cell{1}.name = 'rk2-ConductanceBased';
changes_cell{2}.type = 'postfilter_nonlinearity';
changes_cell{2}.name = 'ConductanceBased_HardRect';
%function glmwrap(exps,stimtypes,celltypes,changes_cell)
%% DICTATE GLMTYPE and Datasets and cells  EDITS DONE HERE! 

BD = NSEM_BaseDirectories;
runoverexisting  = true;
shortlist = true;


if exist('changes_cell', 'var')
    GLMType = GLM_settings('default',changes_cell);
else
    GLMType = GLM_settings('default');
end
GLMType.debug    = false;
GLMType.fitname  = GLM_fitname(GLMType); 



GLMType.func_sname = 'glmwrap_25';
GLMType.fullmfilename =mfilename('fullpath'); 
eval(sprintf('load %s/allcells.mat', BD.Cell_Selection)); 
i_exp = 1; i_cell = 1;
troubleshoot.doit    = true;


%%
for i_exp = exps
    for i_stimtype = stimtypes 
        for i_celltype = celltypes
            %% Cells / Directories / Parameters
            
            % DEFINE GLMTYPE 
            if i_stimtype == 1, stimtype = 'WN';   end
            if i_stimtype == 2, stimtype = 'NSEM'; end
            GLMType.fit_type = stimtype;
             
            
            % LOAD CELLS AND EXP DEPENDENT VARIABLES
            if i_celltype == 1; cellgroup = allcells{i_exp}.ONP;  celltype = 'ONPar'; end
            if i_celltype == 2; cellgroup = allcells{i_exp}.OFFP; celltype = 'OFFPar'; end
            exp_nm  = allcells{i_exp}.exp_nm;
            expname = allcells{i_exp}.expname;
            [StimulusPars Dirs datarun_slv datarun_mas] = Directories_Params_v23(exp_nm, GLMType.fit_type, GLMType.map_type);
            if GLMType.debug
                StimulusPars.slv.FitBlocks = StimulusPars.slv.FitBlocks(1:2);
            end
 

    
            % DIRECTORIES  
            secondDir.exp_nm    = exp_nm; 
            secondDir.map_type  = GLMType.map_type; 
            secondDir.stim_type = GLMType.fit_type;
            secondDir.fitname   = GLMType.fitname;
            Dirs.fittedGLM_savedir  = NSEM_secondaryDirectories('savedir_GLMfit', secondDir);
            Dirs.WN_STAdir          = NSEM_secondaryDirectories('WN_STA', secondDir); 
            Dirs.organizedspikesdir = NSEM_secondaryDirectories('organizedspikes_dir', secondDir); 
            if ~exist(Dirs.fittedGLM_savedir), mkdir(Dirs.fittedGLM_savedir); end         
            display(sprintf('Full Model Fit Parameters are:  %s', GLMType.fitname));  
            display(sprintf('Save Directory :  %s', Dirs.fittedGLM_savedir));
            
            %% Stimulus

            % LOAD BLOCKED STIMULUS IN UINT8 FORM 
            %[blockedmoviecell, inputstats, origmatfile] = loadmoviematfile(exp_nm , GLMType.fit_type, GLMType.cone_model,'fitmovie');
            [testmovie, inputstats] = loadmoviematfile(exp_nm , GLMType.fit_type, GLMType.cone_model,'testmovie');
            %GLMType.fitmoviefile = origmatfile;
            %concat_fitmovie      = concat_fitmovie_fromblockedcell(blockedmoviecell , StimulusPars.slv);
            %clear origmatfile
            
            % Hack!! get rid of it 2014-12-15%
            if shortlist,  [~,cellgroup,~]  = cell_list(i_exp, 'shortlist'); cellgroup = cell2mat(cellgroup); end
            
            %% Fit GLM for each cell
            for i_cell = 1:length(cellgroup)
                clear glm_cellinfo fittedGLM cell_savename
                cid = cellgroup(i_cell); cell_savename = sprintf('%s_%d', celltype,cid);
                
                
                
                % Hack!! get rid of it 2014-12-15%
                if shortlist,  [celltype , cell_savename, ~]  = findcelltype(cid, datarun_mas.cell_types);  end
                
                eval(sprintf('load %s/organizedspikes_%s.mat organizedspikes', Dirs.organizedspikesdir, cell_savename));
                spikesconcat.home = concat_fitspikes_fromorganizedspikes(organizedspikes.block, StimulusPars.slv);
                
                
                
                
                if exist(sprintf('%s/%s.mat', Dirs.fittedGLM_savedir,cell_savename))
                    
                    eval(sprintf('load %s/%s.mat fittedGLM', Dirs.fittedGLM_savedir, cell_savename));
                    if ~isfield(fittedGLM, 'xvalperformance')
                        %xvalperformance = eval_xvalperformance_NEW(fittedGLM, StimulusPars.slv, organizedspikes,testmovie,inputstats);
                        [xvalperformance] = hack_CB_eval_xvalperformance(fittedGLM, StimulusPars.slv, organizedspikes,testmovie,inputstats);
                        fittedGLM.xvalperformance = xvalperformance;
                        eval(sprintf('save %s/%s.mat fittedGLM', Dirs.fittedGLM_savedir, cell_savename));
                        printname = sprintf('%s/DiagPlots_%s', Dirs.fittedGLM_savedir,fittedGLM.cellinfo.cell_savename);
                        hack_printglmfit_CB(fittedGLM,printname)
                    end
                  
                end
            end
        end
    end
end