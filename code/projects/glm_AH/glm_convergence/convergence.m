%% 
% AKHEITMAN 2015-02-05 
% Collect all the Convergent information into a single mat file for easier use
% matfile is called "Raw_Conv.mat"

% This gets turned into TrainConv.mat by conv_obj_fulltrain.mat

clear; close all; clc
BD = NSEM_BaseDirectories;
runoverexisting  = true;


shortlist = true;
i_exp = 1; i_celltype = 1;
troubleshoot.doit    = true;
basefolder   = sprintf('%s/GLM_Convergence_Analysis/fixedSP_rk1_linear_MU_PS_noCP_timekernelCONEMODEL', BD.NSEM_home)
base_savedir = sprintf('%s/Analysis_Plots', basefolder);
if ~exist(base_savedir,'dir'), mkdir(base_savedir); end
pct_change = [5:10:95];pct_change = [pct_change, 100];
changes_cell{1}.type = 'cone_model';
changes_cell{1}.name = 'rieke_linear';
GLMType = GLM_settings('default',changes_cell);
Raw_Conv_Data = allcells;
celltypes = 1:2;
exps = 1:4;
i_exp = 1; i_cell = 1; i_celltype = 1;
%%

% CYCLE THROUGH CELLS 
for i_exp = exps
    %%
    exp_nm  = allcells{i_exp}.exp_nm;
    expname = allcells{i_exp}.expname;
    Raw_Conv_Data{i_exp}.GLMType = GLMType;
    Raw_Conv_Data{i_exp}.WN_fit_seconds   = NaN(1,length(pct_change));
    Raw_Conv_Data{i_exp}.NSEM_fit_seconds = NaN(1,length(pct_change));
    
    for i_pct = 1:length(pct_change)
        pct = pct_change(i_pct);
        [StimulusPars] = Directories_Params_v23_Conv_hack(exp_nm,'WN',pct/100);
        slv_WN = StimulusPars.slv;
        Raw_Conv_Data{i_exp}.WN_fit_seconds(i_pct) = (length(slv_WN.FitBlocks) * length(slv_WN.fitframes)) / 120;
        [StimulusPars] = Directories_Params_v23_Conv_hack(exp_nm,'NSEM',pct/100);
        slv_NSEM = StimulusPars.slv;
        Raw_Conv_Data{i_exp}.NSEM_fit_seconds(i_pct) = (length(slv_NSEM.FitBlocks) * length(slv_NSEM.fitframes)) / 120;
        clear StimulusPars slv_WN slv_NSEM
    end
	Raw_Conv_Data{i_exp}.WN_fit_minutes   = Raw_Conv_Data{i_exp}.WN_fit_seconds/60;
	Raw_Conv_Data{i_exp}.NSEM_fit_minutes = Raw_Conv_Data{i_exp}.NSEM_fit_seconds/60;
    %%
    for i_celltype = celltypes
        
        %%
        if i_celltype == 1; cellgroup = allcells{i_exp}.ONP;  celltype = 'ONPar'; end
        if i_celltype == 2; cellgroup = allcells{i_exp}.OFFP; celltype = 'OFFPar'; end
        if exist('shortlist','var') && shortlist
            [~,cellgroup0,~]  = cell_list(i_exp, 'shortlist'); cellgroup0 = cell2mat(cellgroup0); cellgroup = intersect(cellgroup0,cellgroup); 
            if i_celltype == 1, Raw_Conv_Data{i_exp}.ONP  = cellgroup; end
            if i_celltype == 2, Raw_Conv_Data{i_exp}.OFFP = cellgroup; end
        end
        CONV_WN   = cell(length(cellgroup),1);
        CONV_NSEM = cell(length(cellgroup),1); 
        
        %%
        for i_cell = 1:length(cellgroup)
            %%
            cid = cellgroup(i_cell); 
            cell_savename = sprintf('%s_%d', celltype,cid);
            display(sprintf('Working on %s: %s', exp_nm, cell_savename))
            WN.cid = cid; WN.cell_savename = cell_savename; WN.exp_nm = exp_nm;
            NSEM.cid = cid; NSEM.cell_savename = cell_savename; NSEM.exp_nm = exp_nm;
            WN.xval_bps              = zeros(1, length(pct_change));
            WN.objective_val         = zeros(1, length(pct_change)); 
            NSEM.xval_bps            = zeros(1, length(pct_change));
            NSEM.objective_val       = zeros(1, length(pct_change));
            WN.fit_p                 = cell(length(pct_change),1 );
            NSEM.fit_p               = cell(length(pct_change),1 );
            % Roughly One Second Per Cell   LOAD WN AND NSEM VALS %
            for i_pct = 1:length(pct_change)
                pct = pct_change(i_pct);
                WN_dir   = sprintf('ChangeParams_Fit_Convergence_%dPct/WN_mapPRJ/%s', pct, exp_nm);
                NSEM_dir    = sprintf('ChangeParams_Fit_Convergence_%dPct/NSEM_mapPRJ/%s', pct, exp_nm);
                for i_fit = 1:2
                    if i_fit == 1, eval(sprintf('load %s/%s/%s.mat', basefolder, WN_dir, cell_savename));   Z = WN; end
                    if i_fit == 2, eval(sprintf('load %s/%s/%s.mat', basefolder, NSEM_dir, cell_savename)); Z =NSEM; end
                    Z.xval_bps(i_pct)       = fittedGLM.xvalperformance.logprob_glm_bpspike;
                    Z.objective_val(i_pct)  = fittedGLM.rawfit.objective_val;
                    Z.fit_p{i_pct}          = fittedGLM.rawfit.opt_params;
                    if i_fit == 1, WN   = Z; end
                    if i_fit == 2, NSEM = Z; end
                end
            end 
            
            CONV_WN{i_cell}   = WN;
            CONV_NSEM{i_cell} = NSEM; 
        end
        if i_celltype == 1
            Raw_Conv_Data{i_exp}.CONV_WN_ONP    = CONV_WN;
            Raw_Conv_Data{i_exp}.CONV_NSEM_ONP  = CONV_NSEM;
        end
        if i_celltype == 2
            Raw_Conv_Data{i_exp}.CONV_WN_OFFP   = CONV_WN;
            Raw_Conv_Data{i_exp}.CONV_NSEM_OFFP = CONV_NSEM;
        end
    end
end


if exist('shortlist','var') && shortlist
    eval(sprintf('save %s/Raw_Conv_shortlist.mat Raw_Conv_Data GLMType', base_savedir))
else
    eval(sprintf('save %s/Raw_Conv.mat Raw_Conv_Data GLMType', base_savedir))
end

%{
figure;
panels = 5
for i_fit = 1:2
    if i_fit == 1, Z = conv.WN; fit = 'WN';  string_color = 'b';   end
    if i_fit == 2, Z = conv.NSEM; fit = 'NSEM'; string_color = 'r'; end
    
    for i_panel = 1:panels
        switch i_panel
            case 1
                measure = 'XVAL BPS'; xvals = Z.fit_minutes; yvals = Z.xval_bps;
            case 2
                measure = 'ObjVal'; xvals = Z.fit_minutes; yvals = Z.objective_val;
            case 3
                measure = 'ObjVal/fittime'; xvals = Z.fit_minutes; yvals = Z.objective_val./Z.fit_minutes;
            case 4
                measure = 'Increment ObjVal'; xvals = Z.fit_minutes(2:end); yvals = diff(Z.objective_val);
            case 5
                measure = 'Deriv ObjVal'; 
                xvals = Z.fit_minutes(2:end-1);
                center_point = Z.objective_val(2:end-1);
                before_point = Z.objective_val(1:end-2); after_point = Z.objective_val(3:end);
                backward_deriv = (center_point-before_point)./ diff(Z.fit_minutes(1:end-1));
                forward_deriv = (after_point-center_point)./ diff(Z.fit_minutes(2:end));
                yvals = .5 * backward_deriv + .5*forward_deriv;
        end
        
       subplot(2,panels, (i_panel+(i_fit-1)*panels) ); hold on; 
       set(gca,'fontsize',8); title(sprintf('%s: %s', fit,measure));
       plot(xvals,yvals,string_color);
       plot(xvals,yvals,'k.'); hold off
    end
end
%}        
        

%%
        
        
    
    
    
    
