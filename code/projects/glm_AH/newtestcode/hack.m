clear; i_run = 1; GLMType.debug = true;
for i_run = 1
if i_run == 1
GLMType.fit_type = 'WN'; GLMType.map_type = 'mapPRJ'; 
%GLMType.cone_model = 'linear_timekernel_shift0';  GLMType.cone_sname ='timekernel';
%GLMType.cone_model = '8pix_Identity_8pix'; GLMType.cone_sname='p8IDp8';
%GLMType.cone_model = '8pix_Model1_1e4_8pix'; GLMType.cone_sname = 'p8Mod1Max1e4p8';
%GLMType.cone_model = 'linear_timekernel_shift1';  GLMType.cone_sname ='timekernel';
GLMType.cone_model = 'DimFlash_092413Fc12_shift0'; GLMType.cone_sname = 'timekernelCONEMODEL';
end

if i_run == 2
GLMType.fit_type = 'NSEM'; GLMType.map_type = 'mapPRJ'; 
%GLMType.cone_model = 'linear_timekernel_shift0';  GLMType.cone_sname ='timekernel';
%GLMType.cone_model = '8pix_Model1_1e4_8pix'; GLMType.cone_sname = 'p8Mod1Max1e4p8';
%GLMType.cone_model = '8pix_Identity_8pix'; GLMType.cone_sname='p8IDp8';
GLMType.cone_model = 'DimFlash_092413Fc12_shift0'; GLMType.cone_sname = 'timekernelCONEMODEL';
end

%GLMType.cone_model = 'TimeConvolve_DimFlash_shift2'; GLMType.cone_sname = 'timesmoothed';
%GLMType.k_filtermode = 'OnOff_hardrect_fixedSP_STA'; GLMType.fixedSPlength = 13;  GLMType.fixedSP_nullpoint = 'mean'; 
GLMType.nullpoint = 'mean'; 

%GLMType.stimfilter_mode = 'rk1';

%GLMType.stimfilter_mode = 'rk1';
GLMType.stimfilter_mode = 'fixedSP_rk1_linear';
GLMType.input_pt_nonlinearity      = true;
%GLMType.input_pt_nonlinearity_type = 'piece_linear_aboutmean';
GLMType.input_pt_nonlinearity_type = 'polynomial_order3_part5';
%GLMType.input_pt_nonlinearity_type = 'raisepower_meanafter';
%GLMType.input_pt_nonlinearity_type =  'oddfunc_powerraise_aboutmean';
%GLMType.input_pt_nonlinearity_type =  'log';
%GLMType.input_pt_nonlinearity_type =  'exp';
%GLMType.input_pt_nonlinearity_type = 'polynomial_androot_order2_search2';  % order plus minus 2
%GLMType.input_pt_nonlinearity_type = 'polynomial_androot_order2_search3';

%GLMType.postfilter_nonlinearity      =  true;
%GLMType.postfilter_nonlinearity_type = 'ConductanceBased_HardRect';
%GLMType.postfilter_nonlinearity_type =  'oddfunc_powerraise_aboutmean';
%GLMType.postfilter_nonlinearity_type =  'piece_linear_aboutmean';
%GLMType.postfilter_nonlinearity_type = 'raisepower_meanafter';
%Type = 'Stim_Nonlinearity'; modification = 'raisepower_meanafter'
GLMType.CONVEX = true; % with relation to the filters .. are parameters used linearly in the GLM. 
GLMType.DoubleOpt = true;
GLMType.DoubleOpt_Manual = true;
%GLMType.stimfilter_mode = 'rk1';
GLMType.specialchange = false;
%GLMType.specialchange_name = 'Conductance_Based';
%}

GLMType.TonicDrive = true;
GLMType.StimFilter = true;
GLMType.PostSpikeFilter = true;
GLMType.CouplingFilters = false;
GLMType.fixed_spatialfilter = true;
GLMType.func_sname = 'glmwrap_24';
GLMType.fullmfilename =mfilename('fullpath'); 
i_exp = 1; i_cell = 1;

GLMType.fitname  = GLM_fitname(GLMType);   
troubleshoot.doit    = true;
troubleshoot.plotdir = '/Users/akheitman/Matlab_code/troubleshooting_plots'
troubleshoot.name    = 'singleopt';

%  LOOP THROUGH DATA SETS

BD = NSEM_BaseDirectories;

%cellselectiontype = 'debug';
%cellselectiontype = 'debug';
cellselectiontype = 'shortlist';
troubleshoot.plotdir = BD.GLM_troubleshootplots 
exptests = [1 2 3 4];
%%
for i_exp = exptests
    %% 
    expnumber = i_exp;
    [exp_nm,cells,expname]  = cell_list( expnumber, cellselectiontype);
    cells
    
    [StimulusPars DirPars datarun_slv datarun_mas] = Directories_Params_v23(exp_nm, GLMType.fit_type, GLMType.map_type);
    %% Only in Alligator Hack %%
    
    
    % expletter = expname(4);
    % datarunname = sprintf('datarun%s_%s', expletter, GLMType.fit_type)
    % eval(sprintf('load /Users/akheitman/NSEM_Home/temp_dataruns/%s.mat', datarunname));
    % clear expletter datarunname
    
    
    %%%%  Shorten Block count if using Debug
    if GLMType.debug
        StimulusPars.slv.FitBlocks = StimulusPars.slv.FitBlocks(1:2);
    end
    clear boolean_debug map_type fit_type shead_cellID expname 
    
    %%%%%% Name and Create a Save Directory %%%%%%%%%%%
        
    inputs.exp_nm    = exp_nm; 
    inputs.map_type  = GLMType.map_type; 
    inputs.stim_type = GLMType.fit_type;
    inputs.fitname   = GLMType.fitname;
  
    d_save = NSEM_secondaryDirectories('savedir_GLMfit', inputs);  clear inputs; 
    display(sprintf('Full Model Fit Parameters are:  %s', GLMType.fitname));  
    display(sprintf('Save Directory :  %s', d_save));
    if ~exist(d_save), mkdir(d_save); end
    GLMType.d_save = d_save; 
    

    
%%
    for i_cell = 1:length(cells)
        clear glm_cellstruct
        cid = cells{i_cell};
        [celltype , cell_savename, ~]  = findcelltype(cid, datarun_mas.cell_types);  
        
        eval(sprintf('load %s/%s.mat', d_save, cell_savename));
        eval(sprintf('load %s/ParamLandscape/%s.mat', d_save, cell_savename));
        param_printname = sprintf('%s/ParamLandscape/ParamLandscape_%s', d_save,fittedGLM.cellinfo.cell_savename);
        printparamvar(fittedGLM,manual_search,param_printname)
    end
                
                
                
            
            
            

end
        


end
