% Redone version of "collect points"
% Started on 2014-10-16
% "collect points" does full WN fit NSEM check etc.

% Dirty Code showing scatter plots of normalized GLM performances comparing
% by stimulus type

clear; close all; clc
% Use this for the convergence check!
% INITIALIZATION AND DIRECTORY IDENTIFICATION / IMPORTANT PARAMS

smoothing_bins = false;

if smoothing_bins
    baseoutput_dir = sprintf('/Users/akheitman/NSEM_Home/CrossStim_Performance/Normalize_BinSmoothing');
else
    baseoutput_dir = sprintf('/Users/akheitman/NSEM_Home/CrossStim_Performance/Normalize_NoSmoothing')
end

% SETUP cells and experiments, the TYPE of GLM (GLMType) 
BD = NSEM_BaseDirectories;
exptests = [1 2 3 4];
%cellselectiontype = 'shortlist';%cellselectiontype = 'debug';
cellselectiontype = 'all';
%GLMType.cone_model = '8pix_Identity_8pix'; GLMType.cone_sname='p8IDp8';%
GLMType.cone_model = 'DimFlash_092413Fc12_shift0'; GLMType.cone_sname = 'timekernelCONEMODEL';
%GLMType.cone_model = '8pix_Model1_1e4_8pix'; GLMType.cone_sname = 'p8Mod1Max1e4p8';
%GLMType.k_filtermode = 'OnOff_hardrect_fixedSP_STA'; GLMType.fixedSPlength = 13;  GLMType.fixedSP_nullpoint = 'mean'; 
GLMType.nullpoint = 'mean'; 
GLMType.map_type = 'mapPRJ';
GLMType.debug = false; 
GLMType.specialchange = true;

%GLMType.stimfilter_mode = 'rk1';
GLMType.stimfilter_mode = 'fixedSP_rk1_linear';
%GLMType.input_pt_nonlinearity      = true;
%GLMType.input_pt_nonlinearity_type = 'piece_linear_aboutmean';
GLMType.CONVEX = true;
%GLMType.specialchange = true;
GLMType.specialchange_name = 'Fit_Convergence';
%GLMType.input_pt_nonlinearity      = true;
%GLMType.DoubleOpt = true;
%GLMType.DoubleOpt_Manual = true;
%GLMType.input_pt_nonlinearity_type = 'piece_linear_aboutmean';
%GLMType.input_pt_nonlinearity_type = 'piece_linear_shiftmean';
%GLMType.input_pt_nonlinearity_type = 'polynomial_order5_part4';
%GLMType.input_pt_nonlinearity_type = 'piecelinear_fourpiece_eightlevels';
%GLMType.postfilter_nonlinearity      =  true;
%GLMType.postfilter_nonlinearity_type = 'ConductanceBased_HardRect';
%GLMType.postfilter_nonlinearity_type =  'oddfunc_powerraise_aboutmean';
%GLMType.postfilter_nonlinearity_type =  'piece_linear_aboutmean';


%GLMType.DoubleOpt = true;
%{
GLMType.stimfilter_mode = 'rk1';
GLMType.specialchange = true;
GLMType.specialchange_name = 'ROIlength_9';
GLMType.CONVEX = false;
%}

GLMType.TonicDrive = true;
GLMType.StimFilter = true;
GLMType.PostSpikeFilter = true;
GLMType.CouplingFilters = false;
GLMType.fixed_spatialfilter = true;
GLMType.func_sname = 'glmwrap_23';
GLMType.fullmfilename =mfilename('fullpath'); 
i_exp = 1; i_cell = 1;

GLMType.fitname  = GLM_fitname(GLMType);  

if GLMType.specialchange && strcmp(GLMType.specialchange_name,'Fit_Convergence')
    
    GLMType.fitname = sprintf('%s_%dPct',GLMType.fitname,100);
end

troubleshoot.doit    = true;
troubleshoot.plotdir = '/Users/akheitman/Matlab_code/troubleshooting_plots'
%troubleshoot.plotdir = BD.GLM_troubleshootplots  % temporarily change to
troubleshoot.name    = 'singleopt';



agg_perf.byexpnm = cell(4,1)
agg_perf.fitname = GLMType.fitname;
agg_perf.fullGLMType = GLMType;
agg_perf.note1 = 'rows are experiments, (2012-08-09-3,2012-09-27-3,2013-08-19-6,2013-10-10-0)';
agg_perf.note1 = 'columns are fits, (WN, NSEM)';

for i_exp = exptests
    
    expnumber = i_exp;
    [exp_nm,cells,expname]  = cell_list( expnumber, cellselectiontype);
    [~, ~, datarun_slv_WN datarun_mas]   = Directories_Params_v23(exp_nm, 'WN', 'mapPRJ');
	[~, ~, datarun_slv_NSEM datarun_mas] = Directories_Params_v23(exp_nm, 'NSEM', 'mapPRJ');
    if strcmp(cellselectiontype, 'all')
        [exp_nm,cells,expname,badcells]  = cell_list( expnumber, cellselectiontype);
        clear cells
        
        ONP  = intersect(datarun_slv_WN.cell_types{1}.cell_ids , datarun_slv_NSEM.cell_types{1}.cell_ids);
        OFFP = intersect(datarun_slv_WN.cell_types{2}.cell_ids , datarun_slv_NSEM.cell_types{2}.cell_ids);
        for i_cell = 1:length(badcells);
            ONP(find(ONP == badcells(i_cell) )) = [];
            OFFP(find(OFFP == badcells(i_cell) )) = [];
        end
        cells_vec = [ONP OFFP];
        cells = cell(1,length(cells_vec));
        for i_cell = 1:length(cells);
            cells{i_cell} = cells_vec(i_cell);
        end
    end
    
    
for i_type = 1:2
    %% 
    if i_type == 1, GLMType.fit_type = 'WN'; datarun_slv = datarun_slv_WN; end
    if i_type == 2, GLMType.fit_type = 'NSEM'; datarun_slv = datarun_slv_NSEM; end
    
    
    
    agg_perf.byexpnm{i_exp}.exp_nm = expname;
    agg_perf.byexpnm{i_exp}.fit_type = GLMType.fit_type; 
    agg_perf.byexpnm{i_exp}.cells  = cells; 
    agg_perf.byexpnm{i_exp}.ONP    = zeros(1,length(cells));
    agg_perf.byexpnm{i_exp}.OFFP   = zeros(1,length(cells));
    
    if ~smoothing_bins
        if i_type == 1, agg_perf.byexpnm{i_exp}.WNperf_vec      = zeros(1,length(cells));  end
        if i_type == 2, agg_perf.byexpnm{i_exp}.NSEMperf_vec    = zeros(1,length(cells));  end
    end
    if smoothing_bins
        if i_type == 1,agg_perf.byexpnm{i_exp}.WNperf_vec   = cell(1,length(cells)); end
        if i_type == 2,agg_perf.byexpnm{i_exp}.NSEMperf_vec = cell(1,length(cells)); end
    end
    

    clear boolean_debug map_type fit_type shead_cellID
    
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
    
    %% Load Movie and Concatenate the Fitting Section
    clear Main_SolPars Other_SolParss
    %%% Load Stimulus   -- insert more frame cutting here!    
    %[blockedmoviecell, inputstats, origmatfile] = loadmoviematfile(exp_nm , GLMType.fit_type, GLMType.cone_model,'fitmovie');
    
    %[testmovie_WN]   = loadmoviematfile(exp_nm , 'WN', GLMType.cone_model,'testmovie');
    %[testmovie_NSEM] = loadmoviematfile(exp_nm , 'NSEM', GLMType.cone_model,'testmovie');
    clear origmatfile
    clear blockedmoviecell blockstartframe fitblocks fitframesperblock framenums
    %}
 
    %% Load Cell Specific Elements   Spikes and STA
    %{
    inputs.exp_nm       = exp_nm; 
    inputs.map_type     = GLMType.map_type; 
    DirPars.WN_STAdir   = NSEM_secondaryDirectories('WN_STA', inputs); 

    inputs.stim_type    = 'WN';
    DirPars.organizedspikesdir_WN = NSEM_secondaryDirectories('organizedspikes_dir', inputs); 
    
    inputs.stim_type    = 'NSEM';
    DirPars.organizedspikesdir_NSEM = NSEM_secondaryDirectories('organizedspikes_dir', inputs); 
    
    clear inputs
    %}

    for i_cell = 1:length(cells)
        clear glm_cellstruct
        
        cid = cells{i_cell};
        [celltype , cell_savename, ~]  = findcelltype(cid, datarun_mas.cell_types); 
        
        if strcmp(celltype, 'ON-Parasol')
            agg_perf.byexpnm{i_exp}.ONP(i_cell) = 1;
        elseif strcmp(celltype, 'OFF-Parasol')
            agg_perf.byexpnm{i_exp}.OFFP(i_cell) = 1;
        else
            error('messed up celltype naming');
        end
        
       %eval(sprintf('load %s/organizedspikes_%s.mat organizedspikes', DirPars.organizedspikesdir_WN, cell_savename));
        %organizedspikes_WN = organizedspikes; clear organizedspikes
        if ~smoothing_bins
            eval(sprintf('load %s/%s.mat', d_save, cell_savename));
            if i_type == 1
                agg_perf.byexpnm{i_exp}.WNperf_vec(i_cell)   = fittedGLM.xvalperformance.glm_normedbits;  
            end
            if i_type == 2
                agg_perf.byexpnm{i_exp}.NSEMperf_vec(i_cell) = fittedGLM.xvalperformance.glm_normedbits;
            end

        else
            eval(sprintf('load %s/%s_generalXVAL.mat', d_save, cell_savename));
            if i_type == 1
                agg_perf.byexpnm{i_exp}.WNperf_vec{i_cell}.nbps          = xvalperformance.glm_normedbits_smooth;  
                agg_perf.byexpnm{i_exp}.WNperf_vec{i_cell}.smoothingbins = xvalperformance.smoothing_bins_std; 
            end
            if i_type == 2
                agg_perf.byexpnm{i_exp}.NSEMperf_vec{i_cell}.nbps = xvalperformance.glm_normedbits_smooth;
                agg_perf.byexpnm{i_exp}.NSEMperf_vec{i_cell}.smoothingbins = xvalperformance.smoothing_bins_std; 
            end
        end
        
        
        
    end
    
end



end

%% 

if smoothing_bins
output_dir = sprintf('%s/%s', baseoutput_dir, agg_perf.fitname);
if ~exist(output_dir, 'dir'), mkdir(output_dir); end

eval(sprintf('save %s/agg_perf_%s.mat agg_perf', output_dir,cellselectiontype))



bins = [2 4 6 8];
for i_bin = 1:length(bins)
    binsize = bins(i_bin);
clf;
c = 0;
subplot(5,1,1);
axis off; hold on;
set(gca, 'fontsize', 12)
c = c+1;
text(0, 1-0.1*c,sprintf('Fit by: %s, Cone Model: %s  Smoothed with %d Bins',GLMType.fit_type, GLMType.cone_model, binsize),'interpreter','none')
c = c+1;
text(0, 1-0.1*c,sprintf('Fit name: %s',GLMType.fitname),'interpreter','none')
c = c+1;
text(0, 1-0.1*c,sprintf('Dots are On-Parsols, Asterisks are Off-Parasols'))
c = c+1;
text(0, 1-0.1*c,sprintf('Each Color is a different experiment'))

subplot(3,1,[2 3]);
hold on;
set(gca, 'fontsize', 12);

title('Normalized Bits Per Spike of GLM')
MS = 26;

max_x = 1; max_y = 1;

for i_exp = 1:4
    
    
    WN_vec     = zeros(1,length(agg_perf.byexpnm{i_exp}.cells))
    NSEM_vec   = zeros(1,length(agg_perf.byexpnm{i_exp}.cells))
    for i_cell = 1:length(WN_vec)
        thisbin_WN   = find(agg_perf.byexpnm{i_exp}.WNperf_vec{1}.smoothingbins == binsize);
        thisbin_NSEM = find(agg_perf.byexpnm{i_exp}.NSEMperf_vec{1}.smoothingbins == binsize);
        WN_vec(i_cell) = agg_perf.byexpnm{i_exp}.WNperf_vec{i_cell}.nbps(thisbin_WN);
        NSEM_vec(i_cell) = agg_perf.byexpnm{i_exp}.NSEMperf_vec{i_cell}.nbps(thisbin_NSEM);
    end
   
    
    max_x = max(max_x, max(WN_vec));
    max_y = max(max_y, max(NSEM_vec));
    
        
    
    a = find(NSEM_vec<0); NSEM_vec(a) = 0; 
    b = find(  WN_vec<0);   WN_vec(b) = 0; 
     
    ONP  = find(agg_perf.byexpnm{i_exp}.ONP);
    OFFP = find(agg_perf.byexpnm{i_exp}.OFFP);
   
    if i_exp == 1, plot(WN_vec(ONP), NSEM_vec(ONP),'r.','markersize',MS ); end
    if i_exp == 2, plot(WN_vec(ONP), NSEM_vec(ONP),'g.','markersize',MS ); end
    if i_exp == 3, plot(WN_vec(ONP), NSEM_vec(ONP),'b.','markersize',MS ); end
    if i_exp == 4, plot(WN_vec(ONP), NSEM_vec(ONP),'c.','markersize',MS ); end
    
    if i_exp == 1, plot(WN_vec(OFFP), NSEM_vec(OFFP),'r*','markersize',MS ); end
    if i_exp == 2, plot(WN_vec(OFFP), NSEM_vec(OFFP),'g*','markersize',MS ); end
    if i_exp == 3, plot(WN_vec(OFFP), NSEM_vec(OFFP),'b*','markersize',MS ); end
    if i_exp == 4, plot(WN_vec(OFFP), NSEM_vec(OFFP),'c*','markersize',MS ); end 
    
    WNVec{i_exp}.ONP = WN_vec(ONP); WNVec{i_exp}.OFFP = WN_vec(OFFP);
    NSEMVec{i_exp}.ONP = NSEM_vec(ONP); NSEMVec{i_exp}.OFFP = NSEM_vec(OFFP);
    
end
max_val = max(max_x,max_y);
set(gca,'xlim',[0, max_val]);
set(gca,'ylim',[0, max_val]);
plot(linspace(0,max_val,100),linspace(0,max_val,100), 'k')

xlabel('White Noise')
ylabel('Natural Scenes')
%    
orient tall
eval(sprintf('print -dpdf %s/WN_vs_NSEM_Bin%d_%s.pdf', output_dir, binsize,cellselectiontype));


clf;
subplot(5,1,1);
MS = 10;
axis off
c = 0;
text(-.1, 1,sprintf('Xaxis: WN Normed BPS values,  Yaxis: NSEM Normed BPS,   ALL CELLS   NO SMOOTHING' ));
c=c+1; text(-.1, 1-0.1*c,sprintf('Fit Type: %s', GLMType.fitname),'interpreter','none');
c=c+1; text(-.1, 1-0.1*c,'Color are experiments, dots ONP, asterisk OFFP');
c=c+1; text(-.1, 1-0.1*c,'0 value means worse than steady firing rate,1 means unconditioned optimum');
for i_exp = 1:4
    
    if i_exp == 1; basecolor = 'r'; end
    if i_exp == 2; basecolor = 'g'; end
    if i_exp == 3; basecolor = 'b'; end
    if i_exp == 4; basecolor = 'c'; end
    
    for i_type = 1:2
        if i_type == 1,  marktype  = '.'; end
        if i_type == 2,  marktype = '*'; end
        
        
        
        subplot(5,2, (i_exp*2 + i_type))
        hold on;
        if i_type == 1
            WNvals = WNVec{i_exp}.ONP;
            NSEMvals = NSEMVec{i_exp}.ONP;
        end
        if i_type == 2
            WNvals = WNVec{i_exp}.OFFP;
            NSEMvals = NSEMVec{i_exp}.OFFP;
        end
            
        WNvals( WNvals <=0) = 0;
        NSEMvals( NSEMvals <=0) = 0;
        
        max_x = max(1, max(WNvals));
        max_y = max(1, max(NSEMvals));
        max_val = max(max_x,max_y);
        
        set(gca,'xlim',[0 max_val]); set(gca,'ylim',[0 max_val]);
        
        
        plotstring = sprintf('%s%s',basecolor,marktype);
        plot(WNvals, NSEMvals, plotstring,'markersize',MS);
        plot(linspace(0,max_val,100), linspace(0,max_val,100), 'k')
    end
end

orient tall
eval(sprintf('print -dpdf %s/SplitCells_WN_vs_NSEM_Bin%d_%s.pdf', output_dir, binsize,cellselectiontype));
end
end
%%
if ~smoothing_bins
output_dir = sprintf('%s/%s', baseoutput_dir, agg_perf.fitname);
if ~exist(output_dir, 'dir'), mkdir(output_dir); end
eval(sprintf('save %s/agg_perf.mat agg_perf', output_dir))



clf;
c = 0;
subplot(5,1,1);
axis off
set(gca, 'fontsize', 12)
c = c+1;
text(0, 1-0.1*c,sprintf('Fit by: %s, Cone Model: %s',GLMType.fit_type, GLMType.cone_model),'interpreter','none')
c = c+1;
text(0, 1-0.1*c,sprintf('Fit name: %s',fittedGLM.GLMType.fitname),'interpreter','none')
c = c+1;
text(0, 1-0.1*c,sprintf('Dots are On-Parsols, Asterisks are Off-Parasols'))
c = c+1;
text(0, 1-0.1*c,sprintf('Each Color is a different experiment'))

subplot(3,1,[2 3])
xlim([0,1]);
ylim([0,1]); hold on;
plot(linspace(0,1,100), linspace(0,1,100),'k' );
set(gca, 'fontsize', 12);
set(gca,'xtick',[0:.20:1]); set(gca,'ytick',[0:.20:1]); 
title('Normalized Bits Per Spike of GLM')
MS = 26;
for i_exp = 1:4
    WN_vec   = agg_perf.byexpnm{i_exp}.WNperf_vec;
    NSEM_vec = agg_perf.byexpnm{i_exp}.NSEMperf_vec;
    
    a = find(NSEM_vec<0); NSEM_vec(a) = 0; 
    b = find(  WN_vec<0);   WN_vec(b) = 0; 
     
    ONP  = find(agg_perf.byexpnm{i_exp}.ONP);
    OFFP = find(agg_perf.byexpnm{i_exp}.OFFP);
   
    if i_exp == 1, plot(WN_vec(ONP), NSEM_vec(ONP),'r.','markersize',MS ); end
    if i_exp == 2, plot(WN_vec(ONP), NSEM_vec(ONP),'g.','markersize',MS ); end
    if i_exp == 3, plot(WN_vec(ONP), NSEM_vec(ONP),'b.','markersize',MS ); end
    if i_exp == 4, plot(WN_vec(ONP), NSEM_vec(ONP),'c.','markersize',MS ); end
    
    if i_exp == 1, plot(WN_vec(OFFP), NSEM_vec(OFFP),'r*','markersize',MS ); end
    if i_exp == 2, plot(WN_vec(OFFP), NSEM_vec(OFFP),'g*','markersize',MS ); end
    if i_exp == 3, plot(WN_vec(OFFP), NSEM_vec(OFFP),'b*','markersize',MS ); end
    if i_exp == 4, plot(WN_vec(OFFP), NSEM_vec(OFFP),'c*','markersize',MS ); end 
end

xlabel('White Noise')
ylabel('Natural Scenes')
%    
orient tall
eval(sprintf('print -dpdf %s/WN_outperforms_NSEM.pdf', output_dir));




clf;
subplot(5,1,1);
MS = 10;
axis off
c = 0;
text(-.1, 1,sprintf('Xaxis: WN Normed BPS values,  Yaxis: NSEM Normed BPS,   ALL CELLS   NO SMOOTHING' ));
c=c+1; text(-.1, 1-0.1*c,sprintf('Fit Type: %s', GLMType.fitname),'interpreter','none');
c=c+1; text(-.1, 1-0.1*c,'Color are experiments, dots ONP, asterisk OFFP');
c=c+1; text(-.1, 1-0.1*c,'0 value means worse than steady firing rate,1 means unconditioned optimum');
for i_exp = 1:4
    
    if i_exp == 1; basecolor = 'r'; end
    if i_exp == 2; basecolor = 'g'; end
    if i_exp == 3; basecolor = 'b'; end
    if i_exp == 4; basecolor = 'c'; end
    
    ONP  = find(agg_perf.byexpnm{i_exp}.ONP);
    OFFP = find(agg_perf.byexpnm{i_exp}.OFFP);
    
    
    WN_vec   = agg_perf.byexpnm{i_exp}.WNperf_vec;
    NSEM_vec = agg_perf.byexpnm{i_exp}.NSEMperf_vec;
    
    a = find(NSEM_vec<0); NSEM_vec(a) = 0; 
    b = find(  WN_vec<0);   WN_vec(b) = 0;
    for i_type = 1:2
        if i_type == 1,  marktype  = '.'; end
        if i_type == 2,  marktype = '*'; end
        
        
        
        
        
        
        subplot(5,2, (i_exp*2 + i_type))
        hold on;
        if i_type == 1
            WNvals = WN_vec(ONP);
            NSEMvals = NSEM_vec(ONP);
        end
        if i_type == 2
            WNvals = WN_vec(OFFP);
            NSEMvals = NSEM_vec(OFFP);
        end
            

        
        max_x = max(1, max(WNvals));
        max_y = max(1, max(NSEMvals));
        max_val = max(max_x,max_y);
        
        set(gca,'xlim',[0 max_val]); set(gca,'ylim',[0 max_val]);
        
        
        plotstring = sprintf('%s%s',basecolor,marktype);
        plot(WNvals, NSEMvals, plotstring,'markersize',MS);
        plot(linspace(0,max_val,100), linspace(0,max_val,100), 'k')
    end
end

orient tall
eval(sprintf('print -dpdf %s/SplitCells_WN_vs_NSEM_%s.pdf', output_dir,cellselectiontype));




end
%}