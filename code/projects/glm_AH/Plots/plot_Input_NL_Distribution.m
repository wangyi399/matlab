% AKHeitman 2014-02-05
%%% SAMPLE CALLING SEQUENCES %%%
%{
%changes_cell{1}.type = 'cone_model';
%changes_cell{1}.name = 'rieke_fullcone';
%changes_cell{1}.type = 'filter_mode';
%changes_cell{1}.name = 'fixedSP-ConductanceBased';
%changes_cell{1}.type = 'cone_model';
%changes_cell{1}.name = 'rieke_linear';
%changes_cell{2}.type = 'input_pt_nonlinearity';
%changes_cell{2}.name = 'piecelinear_fourpiece_eightlevels';
%changes_cell{2}.type = 'input_pt_nonlinearity';
%changes_cell{2}.name = 'piece_linear_aboutmean';

clear; clc;
changes_cell{1}.type = 'cone_model';
changes_cell{1}.name = 'rieke_linear';
changes_cell{2}.type = 'input_pt_nonlinearity';
changes_cell{2}.name = 'piecelinear_fourpiece_eightlevels';
load_exps = [1,2,3,4];
avg_exps = [1,2,3];
plotversion = 'v0';
plot_Input_NL_Distribution(changes_cell,plotversion,load_exps,avg_exps)
%}

function plot_Input_NL_Distribution(changes_cell,plotversion,load_exps,avg_exps)
base_figuredir  = '/Users/akheitman/NSEM_Home/PrototypePlots/plot_inputNL';
figuredir       = sprintf('%s/plot_Input_NL_Distribution_PLOTVERSION_%s',base_figuredir,plotversion);
if ~exist(figuredir, 'dir'), mkdir(figuredir); end




BD = NSEM_BaseDirectories;
eval(sprintf('load %s/allcells.mat', BD.Cell_Selection));  % allcells structire

baseoutput_dir = '/Users/akheitman/NSEM_Home/PrototypePlots/Performance_Comparisons/WNWN_vs_NSEMNSEM';
datainput_dir  = '/Users/akheitman/NSEM_Home/PrototypePlots/input_data';

if ~exist(baseoutput_dir), mkdir(baseoutput_dir); end
cellselectiontype = 'shortlist';

if exist('changes_cell', 'var')
    GLMType = GLM_settings('default',changes_cell);
else
	GLMType = GLM_settings('default');
end
GLMType.fitname    = GLM_fitname(GLMType) 
GLMType.func_sname = 'glmwrap';
GLMType.fullmfilename =mfilename('fullpath'); 

NL_Params.GLMfitname = GLMType.fitname;
NL_Params.NL_type = changes_cell{2}.name;

%% LOAD NL PARAMETERS
for i_exp = load_exps
    % LOAD CELLS  (OLD WAY)
	expnumber = i_exp;
	if strcmp(cellselectiontype, 'shortlist')
        [exp_nm,cells,expname]  = cell_list(expnumber,'shortlist'); cells = cell2mat(cells);
    end

    %%%%%% Identify Directories %%%%%%%%%%%
	inputs.exp_nm    = exp_nm; 
	inputs.map_type  = 'mapPRJ'; 
	inputs.stim_type = 'WN';
	inputs.fitname   = GLMType.fitname;
	d_load_WN = NSEM_secondaryDirectories('loaddir_GLMfit', inputs);  clear inputs; 

    inputs.exp_nm    = exp_nm; 
	inputs.map_type  = 'mapPRJ'; 
	inputs.stim_type = 'NSEM';
	inputs.fitname   = GLMType.fitname;
	d_load_NSEM = NSEM_secondaryDirectories('loaddir_GLMfit', inputs);  clear inputs; 
    
    NL_Params.byexp{i_exp}.params_WN    = cell(length(cells),1);
    NL_Params.byexp{i_exp}.params_NSEM  = cell(length(cells),1);
    NL_Params.byexp{i_exp}.cells        = cells;
    NL_Params.byexp{i_exp}.ONP          = NaN(size(cells));
    NL_Params.byexp{i_exp}.OFFP         = NaN(size(cells));
    
    for i_cell = 1:length(cells)
        cid = cells(i_cell);
        isitON = ~isempty(find(allcells{i_exp}.ONP== cid));
        isitOFF = ~isempty(find(allcells{i_exp}.OFFP == cid));
        if isitON && ~isitOFF
            cell_savename  = sprintf('ONPar_%d',cid);
            NL_Params.byexp{i_exp}.ONP(i_cell)  = 1;
            NL_Params.byexp{i_exp}.OFFP(i_cell) = 0;
        elseif isitOFF && ~isitON
            cell_savename  = sprintf('OFFPar_%d',cid);
            NL_Params.byexp{i_exp}.ONP(i_cell)  = 0;
            NL_Params.byexp{i_exp}.OFFP(i_cell) = 1;
        end
        
        eval(sprintf('load %s/%s.mat', d_load_WN,cell_savename));
        NL_Params.byexp{i_exp}.params_WN{i_cell,1} = fittedGLM.pt_nonlinearity_param;
        eval(sprintf('load %s/%s.mat', d_load_NSEM,cell_savename));
        NL_Params.byexp{i_exp}.params_NSEM{i_cell,1} = fittedGLM.pt_nonlinearity_param;
    end
end
%% Organize Parameters Plot for Individual Experiments       
close all
explist = [1,2,3,4];
for i_exp = load_exps
    cellcount = length(NL_Params.byexp{i_exp}.cells);
    if strcmp(NL_Params.NL_type,'piecelinear_fourpiece_eightlevels')
        index_count = 0;
        params_list{i_exp}.WN   = NaN(cellcount,5);
        params_list{i_exp}.NSEM = NaN(cellcount,5);

        for i_cell = 1:length(NL_Params.byexp{i_exp}.cells)
            slope_WN = NL_Params.byexp{i_exp}.params_WN{i_cell};
            params_list{i_exp}.WN(i_cell,2) = .25*slope_WN(1);
            params_list{i_exp}.WN(i_cell,3) = .25*(slope_WN(1)+slope_WN(2));
            params_list{i_exp}.WN(i_cell,4) = .25*(slope_WN(1)+slope_WN(2)+slope_WN(3));
            
            slope_NSEM = NL_Params.byexp{i_exp}.params_NSEM{i_cell};
            params_list{i_exp}.NSEM(i_cell,2) = .25*slope_NSEM(1);
            params_list{i_exp}.NSEM(i_cell,3) = .25*(slope_NSEM(1)+slope_NSEM(2));
            params_list{i_exp}.NSEM(i_cell,4) = .25*(slope_NSEM(1)+slope_NSEM(2)+slope_NSEM(3));

            params_list{i_exp}.WN(i_cell,1) = 0;
            params_list{i_exp}.WN(i_cell,5) = 1;
            params_list{i_exp}.NSEM(i_cell,1) = 0;
            params_list{i_exp}.NSEM(i_cell,5) = 1;
        end
        params_list{i_exp}.WN_ONP  = params_list{i_exp}.WN(find(NL_Params.byexp{i_exp}.ONP),:);
        params_list{i_exp}.WN_OFFP = params_list{i_exp}.WN(find(NL_Params.byexp{i_exp}.OFFP),:);
        params_list{i_exp}.NSEM_ONP  = params_list{i_exp}.NSEM(find(NL_Params.byexp{i_exp}.ONP),:);
        params_list{i_exp}.NSEM_OFFP = params_list{i_exp}.NSEM(find(NL_Params.byexp{i_exp}.OFFP),:);

        name_title  = (sprintf('"General"-NL: NSEM: Exp%d: Blue-ONP: Red-OFFP', i_exp));
        name_figure = sprintf('fittedNL_NSEM_exp%d',i_exp);
        mean_NSEM_ONP = [mean(params_list{i_exp}.NSEM_ONP,1)];
        std_NSEM_ONP  = [std(params_list{i_exp}.NSEM_ONP,1)];
        mean_NSEM_OFFP = [mean(params_list{i_exp}.NSEM_OFFP,1)];
        std_NSEM_OFFP  = [std(params_list{i_exp}.NSEM_OFFP,1)];
        if strcmp(plotversion, 'v0')
            plotNL_v0(mean_NSEM_ONP,std_NSEM_ONP,mean_NSEM_OFFP, std_NSEM_OFFP, name_title,name_figure,figuredir);
        end
        
        name_title = (sprintf('"General"-NL: WN: Exp%d: Blue-ONP: Red-OFFP', i_exp));
        name_figure = sprintf('fittedNL_WN_exp%d',i_exp);
        mean_WN_ONP = [mean(params_list{i_exp}.WN_ONP,1)];
        std_WN_ONP  = [std(params_list{i_exp}.WN_ONP,1)];
        mean_WN_OFFP = [mean(params_list{i_exp}.WN_OFFP,1)];
        std_WN_OFFP  = [std(params_list{i_exp}.WN_OFFP,1)];
        if strcmp(plotversion, 'v0')
            plotNL_v0(mean_WN_ONP,std_WN_ONP,mean_WN_OFFP, std_WN_OFFP, name_title,name_figure,figuredir);
        end
    end
end
%% Plot Averages
% Plot Across exp_list
allexp_NSEM_ONP = [];
allexp_NSEM_OFFP = [];
allexp_WN_ONP = [];
allexp_WN_OFFP = [];
LW = 12; LW2 = 1.5;
for i_exp = avg_exps
    allexp_NSEM_ONP = [allexp_NSEM_ONP; params_list{i_exp}.NSEM_ONP ];
    allexp_NSEM_OFFP = [allexp_NSEM_OFFP; params_list{i_exp}.NSEM_OFFP ];
    allexp_WN_ONP = [allexp_WN_ONP; params_list{i_exp}.WN_ONP ];
    allexp_WN_OFFP = [allexp_WN_OFFP; params_list{i_exp}.WN_OFFP ];
end
for i_exp = 4
    allexp_WN_ONP = [allexp_WN_ONP; params_list{i_exp}.WN_ONP ];
    allexp_WN_OFFP = [allexp_WN_OFFP; params_list{i_exp}.WN_OFFP ];
end

name_title     = sprintf('"General"-NL: NSEM: CrossPrep: Blue-ONP: Red-OFFP');
name_figure    = sprintf('fittedNL_NSEM_CrossPrep');
mean_NSEM_ONP  = [mean(allexp_NSEM_ONP,1)];
std_NSEM_ONP   = [std(allexp_NSEM_ONP,1)];
mean_NSEM_OFFP = [mean(allexp_NSEM_OFFP,1)];
std_NSEM_OFFP  = [std(allexp_NSEM_OFFP,1)];
if strcmp(plotversion, 'v0')
    plotNL_v0(mean_NSEM_ONP,std_NSEM_ONP,mean_NSEM_OFFP, std_NSEM_OFFP, name_title,name_figure,figuredir);
end

name_title     = sprintf('"General"-NL: WN: CrossPrep: Blue-ONP: Red-OFFP');
name_figure    = sprintf('fittedNL_WN_CrossPrep');
mean_WN_ONP = [mean(allexp_WN_ONP,1)];
std_WN_ONP  = [std(allexp_WN_ONP,1)];
mean_WN_OFFP = [mean(allexp_WN_OFFP,1)];
std_WN_OFFP  = [std(allexp_WN_OFFP,1)];
if strcmp(plotversion, 'v0')
    plotNL_v0(mean_WN_ONP,std_WN_ONP,mean_WN_OFFP, std_WN_OFFP, name_title,name_figure,figuredir);
end





end



function plotNL_v0(mean_ONP,std_ONP,mean_OFFP, std_OFFP, name_title,name_figure,plotdir)
LW2 = 1.5; LW = 12;

figure(1); clf; hold on;
set(gca,'fontsize',12); axis square
xvals = [0,.25,.5,.75,1];
title(sprintf('%s',name_title))
plot(xvals,mean_ONP + 1* std_ONP,'b','linewidth',LW2);
plot(xvals,mean_ONP - 1* std_ONP,'b','linewidth',LW2); 
plot(xvals,mean_OFFP + 1* std_OFFP,'r','linewidth',LW2);
plot(xvals,mean_OFFP - 1* std_OFFP,'r','linewidth',LW2); 
plot(xvals,mean_ONP,'b','linewidth',LW)
plot(xvals,mean_OFFP,'r','linewidth',LW)
xlim([0,1]); ylim([0,1]); 
set(gca,'xtick', xvals);
set(gca,'ytick',xvals); % hold off

figname = sprintf('%s/%s', plotdir,name_figure);
saveas(gcf,figname,'fig')
eval(sprintf('print -dpdf %s/%s.pdf',plotdir,name_figure));
eval(sprintf('print -depsc %s/%s.eps',plotdir,name_figure));   
end