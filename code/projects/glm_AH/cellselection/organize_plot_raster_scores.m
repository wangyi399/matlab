%%% PURPOSE %%%
% Collect raster scores in a unified fashion
% Prepare for plotting
% Move raster scores from blockedspikes dir into cellselection mode

%%% COMPUTATIONS %%%
% selfprediction_temporalprecision_bps
% selfprediction_temporalprecision_fracvar
% rasterprecision_paireddistance_Vector


% AKHEITMAN 2014-12-04 start

clear; clc; close all
raster_computation = 'selfprediction_temporalprecision_fracvar';

%raster_computation  = 'rasterprecision_paireddistance_Viktor_25msec';
%raster_computation = 'selfprediction_temporalprecision_bps';
%raster_computation = 'selfprediction_max_bps';
%raster_computation = 'rasterprecision_paireddistance_Vector';

%raster_computation =  'selfprediction_10msecsmooth_bps';

% SET DIRECTORIES
BD = NSEM_BaseDirectories;
Dirs.rastmetdir = sprintf('%s/Raster_Metrics', BD.Cell_Selection);
if ~exist(Dirs.rastmetdir, 'dir'), mkdir(Dirs.rastmetdir); end
Dirs.rast_dir = BD.BlockedSpikes;

% LOAD CELL NUMBERS / INITIALIZE SOLUTION STRUCTURE
eval(sprintf('load %s/allcells.mat', BD.Cell_Selection)); 
raster_scores = allcells;

% HARD PARAMETERS OF THE RASTER WE ALREADY HAVE SET
hard_params.raster_params.bindur         = .00083275;
hard_params.raster_params.bins_per_frame = 10;
hard_params.map_type = 'mapPRJ';


if strcmp(raster_computation, 'selfprediction_temporalprecision_bps')
    foldername   = 'rasterprecision_prediction_avgsignal';
    matname_base = 'rasterprecision_prediction_avgsignal';
    metricnames  = 'Bin Number with Highest raster Bits Per Spike';
elseif strcmp(raster_computation, 'selfprediction_max_bps')
    foldername   = 'rasterprecision_prediction_avgsignal';
    matname_base = 'rasterprecision_prediction_avgsignal';
    metricnames  = 'BPS of Raster given optimal binning of avg signal';
elseif strcmp(raster_computation, 'selfprediction_10msecsmooth_bps')
    foldername   = 'rasterprecision_prediction_avgsignal';
    matname_base = 'rasterprecision_prediction_avgsignal';
    metricnames  = 'BPS of Raster given optimal binning of avg signal';
elseif strcmp(raster_computation, 'selfprediction_temporalprecision_fracvar')
    foldername   = 'rasterprecision_prediction_avgsignal';
    matname_base = 'rasterprecision_prediction_avgsignal';
    metricnames  = 'Bin Number with Highest Variance Factor';
elseif strcmp(raster_computation, 'paireddistance_temporalprecision_fracvar')
    foldername   = 'rasterprecision_paireddistance_Vector';
    matname_base = 'rasterprecision_paireddistance_Vector';
    metricnames  = 'Paired Error'; 
elseif strcmp(raster_computation, 'rasterprecision_paireddistance_Viktor_25msec')
    foldername   = 'rasterprecision_paireddistance_Viktor';
    matname_base = 'rasterprecision_paireddistance_Viktor';
    metricnames  = 'Paired Error: ViktroSpike'; 
end
    
i_exp = 1; i_stimtype = 1; i_celltype = 1; i_cell = 1;


filename = sprintf('%s/%s',Dirs.rastmetdir, raster_computation)
%% Loop experiments/stimulus/celltypes to execute raster compuation

if ~exist(sprintf('%s.mat',filename), 'file')
for i_exp = 1:4
    for i_stimtype = 1:2   
        for i_celltype = 1:2
            %% Experiment Dependent Parameters
            
            % CLEAN UP
            clear StimPars secondDir scores
            % LOAD STIMULUS PARAMETERS / DEFINE CELL NUMBERS
            exp_nm  = allcells{i_exp}.exp_nm;
            expname = allcells{i_exp}.expname;
            map_type= hard_params.map_type;
            if i_stimtype == 1, stimtype = 'WN';   end
            if i_stimtype == 2, stimtype = 'NSEM'; end
            if i_celltype == 1; cellgroup = allcells{i_exp}.ONP;  celltype = 'ONPar'; end
            if i_celltype == 2; cellgroup = allcells{i_exp}.OFFP; celltype = 'OFFPar'; end
            [StimPars]    = Directories_Params_v23(exp_nm, stimtype, map_type);
            
            % TAKE CARE OF DIRECTORIES
            secondDir.exp_nm = exp_nm;
            secondDir.stim_type = stimtype;
            secondDir.map_type  = 'mapPRJ';
            Dirs.organizedspikesdir = NSEM_secondaryDirectories('organizedspikes_dir', secondDir);
            Dirs.loaddir            = sprintf('%s/%s', Dirs.organizedspikesdir, foldername);
            
            
            % INITIALIZE THE SOLUTION STRUCTURE
            scores.metric_name = metricnames;
            scores.values      = zeros(length(cellgroup), 1);

            %%
            for i_cell = 1:length(cellgroup)
                % CLEAN UP
                
                % LOAD STORED RASTER METRICS
                cid = cellgroup(i_cell);
                cell_savename = sprintf('%s_%d', celltype,cid);
                matfilename   = sprintf('%s_%s', matname_base, cell_savename); 
                display(sprintf('Working on Exp: %s Stim: %s Cell: %s', exp_nm,stimtype, cell_savename));
                
                % LOAD Raster_Metrics
                eval(sprintf('load %s/%s.mat', Dirs.loaddir, matfilename));

                
                % COMPUTE SOLUTIONS  % DEPENDENT ON KNOWING STRUCTURE WELL
                if strcmp(raster_computation, 'selfprediction_temporalprecision_bps')
                    [dummy.a , dummy.b]      = max( raster_metrics.prediction_avgsignal.bps_mean );
                    scores.values(i_cell) = raster_metrics.prediction_avgsignal.sigma_bin(dummy.b);
                elseif strcmp(raster_computation, 'selfprediction_temporalprecision_fracvar')
                    
                    [dummy.a , dummy.b]      = max( raster_metrics.prediction_avgsignal.fracvar_mean );
                    scores.values(i_cell) = raster_metrics.prediction_avgsignal.sigma_bin(dummy.b);
                elseif strcmp(raster_computation, 'selfprediction_max_bps')
                    scores.values(i_cell) = max(raster_metrics.prediction_avgsignal.bps_mean);
                elseif strcmp(raster_computation, 'selfprediction_10msecsmooth_bps')
                    scores.values(i_cell) = raster_metrics.prediction_avgsignal.bps_mean(7);
                elseif strcmp(raster_computation,'rasterprecision_paireddistance_Viktor_25msec')
                    dummy = raster_metrics.paireddistances_viktor;
                    index = find(dummy.ViktorParams_Bins == 32);
                    scores.values(i_cell) = dummy.Viktordist_perspike(index);
                end
            end
            raster_scores{i_exp}.stim_type{i_stimtype}.celltype{i_celltype}.scores = scores;
        end
    end
end
eval(sprintf('save %s.mat raster_scores',filename));
end

%% Plotting Histogram / Full Split Stimulus Types
eval(sprintf('load %s.mat raster_scores',filename));
timestamp = datestr(clock);

eval(sprintf('load %s/Raster_By_Eye/rast_eye.mat rast_eye',BD.Cell_Selection));
extremum = cell(2,1);

if exist('rast_eye','var'), ploteye = true; end
for i_stimtype = 1:2
    minval = [];
    maxval = [];
    for i_exp = 1:4
        for i_celltype = 1:2
            values = raster_scores{i_exp}.stim_type{i_stimtype}.celltype{i_celltype}.scores.values;
            minval = [minval min(values)];
            maxval = [maxval max(values)];
        end
    end
    extremum{i_stimtype,1}.minval = min(minval);
    extremum{i_stimtype,1}.maxval = max(maxval);
end
%%
i_stimtype = 1; i_exp = 1; i_cellgroup = 1;

hist_divisions = 40;
%{
if strcmp(raster_computation, 'selfprediction_temporalprecision_bps')
    hist_divisions = 40;
elseif strcmp(raster_computation, 'selfprediction_max_bps')
    hist_divisions = 20;
end
%}
for i_stimtype = 1:2
    clf;
    if i_stimtype == 1, stimtype = 'WN';   end
    if i_stimtype == 2, stimtype = 'NSEM'; end
    subplot(6,1,1); hold on
    set(gca, 'fontsize', 10); axis off; 
    c = 0; 
    c = c+2; text(-.1, 1-0.1*c,sprintf('Metric: %s, Stimulus: %s', raster_computation, stimtype),'interpreter','none');
    c = c+2; text(-.1, 1-0.1*c,sprintf('Left Column is On Parasol, Right Column is Off Parasol :: Each Row/Color is a different experiment'));
    if exist('ploteye','var') && ploteye
        c = c+2; text(-.1, 1-0.1*c,sprintf('+ signs are strong rasters,(lower band above barplot), o signs are weak rasters(top band)'));
    end
    c = c+2; text(-.1, 1-0.1*c,sprintf('%s',timestamp));
    
    min_val = extremum{i_stimtype}.minval;
    max_val = extremum{i_stimtype}.maxval;
    xmin = min_val;
    xmax = max_val;% + (max_val - min_val);
    
    hist_x = linspace(xmin,xmax,hist_divisions);
    
    crossexp_on  = zeros(1,length(hist_x));
    crossexp_off = zeros(1,length(hist_x)); 
    %%
    for i_exp = 1:4
        for i_celltype = 1:2
            
            if i_exp == 1, plotstring = 'r'; end
            if i_exp == 2, plotstring = 'g'; end
            if i_exp == 3, plotstring = 'b'; end
            if i_exp == 4, plotstring = 'c'; end
            i_row = [i_exp+1];
            columns = 2;
            i_column = i_celltype;
            plot_index =  2*(i_row-1) + i_column;
            
            subplot(6,columns,plot_index); hold on;
            set(gca, 'fontsize', 10)
            values = raster_scores{i_exp}.stim_type{i_stimtype}.celltype{i_celltype}.scores.values;
            [n1] = hist(values, hist_x);
            bar(hist_x,n1,plotstring);
            xlim([xmin,xmax]);
            
            % add extra line
            if exist('ploteye','var') && ploteye
                maxvalue  = max(n1);
                y_val     = maxvalue;
                
                notsharp_ind = find(rast_eye{i_exp}.stim_type{i_stimtype}.celltype{i_celltype}.not_sharp);
                sharp_ind    = find(rast_eye{i_exp}.stim_type{i_stimtype}.celltype{i_celltype}.sharp);
                
                xlinevals = linspace(xmin,xmax,100);
                plot(xlinevals,y_val*ones(size(xlinevals)),'k');
                
                for i_sharp = 1:length(sharp_ind)
                    new_y = y_val + .05* i_sharp*maxvalue;
                    new_x = values(sharp_ind(i_sharp));
                    plot(new_x,new_y,'+','color',plotstring);
                end
                
                new_y = y_val + .05*(length(sharp_ind)+2)*maxvalue;
                plot(xlinevals,new_y*ones(size(xlinevals)),'k');
                
                for i_notsharp = 1:length(notsharp_ind)
                    new_y = y_val + .05* i_notsharp*maxvalue + .05*(length(sharp_ind)+4)*maxvalue;
                    new_x = values(notsharp_ind(i_notsharp));
                    plot(new_x,new_y,'o','color',plotstring);
                end
                
                new_y = y_val + .05*(length(sharp_ind)+length(notsharp_ind)+6)*maxvalue;
                plot(xlinevals,new_y*ones(size(xlinevals)),'k');
                    
            end
            
            if i_celltype == 1
                crossexp_on  = crossexp_on  + n1;
            elseif i_celltype == 2
                crossexp_off = crossexp_off + n1;
            end 
        end
        
        
        
        subplot(6,2,11); hold on
        xlim([xmin,xmax]); set(gca, 'fontsize',10); 
        bar(hist_x,crossexp_on,'k');
        
        subplot(6,2,12); hold on
        xlim([xmin,xmax]); set(gca, 'fontsize',10); 
        bar(hist_x,crossexp_off, 'k');         
    end
    
    orient tall
    
    if ~exist('ploteye','var') || ~ploteye
        eval(sprintf('print -dpdf %s_Hist_CtypeStim_%s.pdf', filename, stimtype))
    else
        eval(sprintf('print -dpdf %s_Hist_CtypeStim_%s_eyecheck.pdf', filename, stimtype))
    end
            
end

% Difference in WN vs NSEM
% Plot Histogram of Differences
%%
%{
clear extremum
minval = [];
maxval = [];
for i_exp = 1:4
    for i_celltype = 1:2
        wn_values = raster_scores{i_exp}.stim_type{1}.celltype{i_celltype}.scores.values;
        nsem_values = raster_scores{i_exp}.stim_type{2}.celltype{i_celltype}.scores.values;
        values = wn_values - nsem_values;
        minval = [minval min(values)];
        maxval = [maxval max(values)];
    end
    
end
extremum.minval = min(minval);
extremum.maxval = max(maxval);

subplot(6,1,1); hold on
set(gca, 'fontsize', 10); axis off; 
c = 0; 
c = c+2; text(-.1, 1-0.1*c,sprintf('Metric: %s, WNval - NSEMval', raster_computation, stimtype),'interpreter','none');
c = c+2; text(-.1, 1-0.1*c,sprintf('Left Column is On Parasol, Right Column is Off Parasol :: Each Row/Color is a different experiment'));
c = c+2; text(-.1, 1-0.1*c,sprintf('%s',timestamp));
min_val = extremum.minval;
max_val = extremum.maxval;
xmin = min_val;
xmax = max_val;% + (max_val - min_val);
hist_x = linspace(xmin,xmax,hist_divisions);
crossexp_on  = zeros(1,length(hist_x));
crossexp_off = zeros(1,length(hist_x)); 
for i_exp = 1:4
        if i_exp == 1, plotstring = 'r'; end
        if i_exp == 2, plotstring = 'g'; end
        if i_exp == 3, plotstring = 'b'; end
        if i_exp == 4, plotstring = 'c'; end
        
        i_row = [i_exp+1];
        for i_celltype = 1:2
            columns = 2;
            i_column = i_celltype;
            plot_index =  2*(i_row-1) + i_column;
            
            subplot(6,columns,plot_index); hold on;
            set(gca, 'fontsize', 10)
            wn_values = raster_scores{i_exp}.stim_type{1}.celltype{i_cellgroup}.scores.values;
            nsem_values = raster_scores{i_exp}.stim_type{2}.celltype{i_cellgroup}.scores.values;
            values = wn_values - nsem_values;
            [n1] = hist(values, hist_x);
            bar(hist_x,n1,plotstring);
            xlim([xmin,xmax]);
            
            if i_celltype == 1
                crossexp_on  = crossexp_on  + n1;
            elseif i_celltype == 2
                crossexp_off = crossexp_off + n1;
            end 
        end
        
        subplot(6,2,11); hold on
        xlim([xmin,xmax]); set(gca, 'fontsize',10); 
        bar(hist_x,crossexp_on,'k');
        
        subplot(6,2,12); hold on
        xlim([xmin,xmax]); set(gca, 'fontsize',10); 
        bar(hist_x,crossexp_off, 'k');         
    
            
end
orient tall
eval(sprintf('print -dpdf %s_Hist_StimDiff_%s.pdf', filename, stimtype))
%}
%%
