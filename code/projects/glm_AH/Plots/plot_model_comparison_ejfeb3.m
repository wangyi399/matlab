% AKHEITMAN 2015-01-25
% USE THE DECIDED METRICS

% IN DIRECTORY glm_AH/Plots
% Spits out into NSEM_Home/PrototypePlots/Performance_Comparisons/Model_COmparisons
% Works

% Dumb Restriction  pdf name cna't be too long! 

clear; close all; clear all; clc
BD = NSEM_BaseDirectories;
eval(sprintf('load %s/allcells.mat', BD.Cell_Selection));  % allcells structire

baseoutput_dir = '/Users/akheitman/NSEM_Home/PrototypePlots/Performance_Comparisons/Model_Comparisons';
datainput_dir  = '/Users/akheitman/NSEM_Home/PrototypePlots/input_data';
if ~exist(baseoutput_dir), mkdir(baseoutput_dir); end

cellselectiontype = 'shortlist';
exptests = [1 2 3];

%comparison = 'InputNL-HingeMean'%_fixedSP_linearCONE';
%comparison = 'FixedSP-ConductanceBased'
%comparison = 'rk2-ConductanceBased'
comparison = 'InputNL-piecelinear-four'; shortname = '"General" Input-NL: 4 Piece-Linear';
%comparison = 'Full-DynamicCones'; shortname = 'Dynamic Cones';
if strcmp(comparison, 'InputNL-HingeMean')
    changes_cell_A{1}.type = 'cone_model';
    changes_cell_A{1}.name = 'rieke_linear';
    changes_cell_B{1}.type = 'cone_model';
    changes_cell_B{1}.name = 'rieke_linear';
    changes_cell_B{2}.type = 'input_pt_nonlinearity';
    changes_cell_B{2}.name = 'piece_linear_aboutmean';
end
if strcmp(comparison, 'InputNL-piecelinear-four')
    changes_cell_A{1}.type = 'cone_model';
    changes_cell_A{1}.name = 'rieke_linear';
    changes_cell_B{1}.type = 'cone_model';
    changes_cell_B{1}.name = 'rieke_linear';
    changes_cell_B{2}.type = 'input_pt_nonlinearity';
    changes_cell_B{2}.name = 'piecelinear_fourpiece_eightlevels';
end
if strcmp(comparison, 'rk2-ConductanceBased')
    changes_cell_B{1}.type = 'filter_mode';
    changes_cell_B{1}.name = 'rk2-ConductanceBased';
end
if strcmp(comparison, 'FixedSP-ConductanceBased')
    changes_cell_B{1}.type = 'filter_mode';
    changes_cell_B{1}.name = 'fixedSP-ConductanceBased';
end
if strcmp(comparison, 'Full-DynamicCones')
    changes_cell_A{1}.type = 'cone_model';
    changes_cell_A{1}.name = 'rieke_linear';
    changes_cell_B{1}.type = 'cone_model';
    changes_cell_B{1}.name = 'rieke_fullcone';
end





for i_metric = 1
    
    clear metrics
    if i_metric == 1, metrics.name ='BPS_normsubtract_smooth10msec'; metrics.shortname ='BPS';end
    if i_metric == 2, metrics.name ='Viktor_normsubtract_25msec';  metrics.shortname ='VKSP'; end

    if strcmp(metrics.name,'BPS_normsubtract_smooth10msec')
        metrics.raster_normalization_structure = 'selfprediction_10msecsmooth_bps.mat';
        metrics.plots.init_minval = 0;
        metrics.plots.init_maxval = 0;
        metrics.plots.title_base  = 'BPS(GLM)-BPS(Optimal Rate Model(10msec))'
        metrics.plots.xlabel      = ' White Noise';
        metrics.plots.ylabel      = 'Natural Scenes';
    end
    if strcmp(metrics.name,'Viktor_normsubtract_25msec')
        metrics.raster_normalization_structure = 'rasterprecision_paireddistance_Viktor_25msec.mat';
        metrics.plots.init_minval = 0;
        metrics.plots.init_maxval = 1;
        metrics.plots.title_base  = 'VSP(Sim to Raster) - VSP(Raster to Raster)'
        metrics.plots.xlabel      = ' White Noise';
        metrics.plots.ylabel      = 'Natural Scenes';
    end
    eval(sprintf('load %s/%s',datainput_dir,metrics.raster_normalization_structure));
    
    for i_model = 1:2
        clear model_comparison GLMType changes_cell
        
        if i_model == 1
            if exist('changes_cell_A','var')
                changes_cell = changes_cell_A; 
            end
        end
        if i_model == 2, changes_cell = changes_cell_B; end
    
        if exist('changes_cell', 'var')
            GLMType = GLM_settings('default',changes_cell);
        else
            GLMType = GLM_settings('default');
        end
        GLMType.fitname    = GLM_fitname(GLMType) 
        GLMType.func_sname = 'glmwrap';
        GLMType.fullmfilename =mfilename('fullpath'); 


        if i_model == 1, savedir  = sprintf ('%s/%s/%s',  baseoutput_dir, comparison, GLMType.fitname); end
        savename = sprintf('%s_%s',  metrics.shortname,cellselectiontype);

        if ~exist(savedir, 'dir')
            mkdir(savedir);
        end

        model_comparison.metrics        = metrics;
        model_comparison.fitname        = GLMType.fitname;
        model_comparison.fullGLMType    = GLMType;
        model_comparison.note1          = 'rows are experiments, columns are the different models';
        model_comparison.note2          = 'row1 is WN scores, row2 is NSEM scores';

        i_exp = 1;
        i_celltype = 1;
        i_cell = 1;

        % FOR LOOP LOADS THE METRICS
        for i_exp = exptests

            % LOAD CELLS  (OLD WAY)
            expnumber = i_exp;
            if strcmp(cellselectiontype, 'shortlist')
                [exp_nm,cells,expname]  = cell_list( expnumber, 'shortlist'); cells = cell2mat(cells);
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

            if strcmp(metrics.name,'Viktor_normsubtract_25msec')
                d_load_WN   = sprintf('%s/crossval_Viktor_Spike', d_load_WN);
                d_load_NSEM = sprintf('%s/crossval_Viktor_Spike', d_load_NSEM);
            end
        %%
            for i_celltype = 1:2

                if i_celltype == 1
                    celllist = intersect(cells, allcells{i_exp}.ONP);
                    model_comparison.scores{i_exp}.ONP_cells  = celllist;
                    model_comparison.scores{i_exp}.ONP_scores_normsubtract = NaN(2,length(celllist));
                    model_comparison.scores{i_exp}.ONP_scores_normdivide = NaN(2,length(celllist));
                    model_comparison.scores{i_exp}.ONP_scores_raw = NaN(2,length(celllist));
                elseif i_celltype == 2
                    celllist = intersect(cells, allcells{i_exp}.OFFP);
                    model_comparison.scores{i_exp}.OFFP_cells  = celllist;
                    model_comparison.scores{i_exp}.OFFP_scores_normsubtract = NaN(2,length(celllist));
                    model_comparison.scores{i_exp}.OFFP_scores_normdivide = NaN(2,length(celllist));
                    model_comparison.scores{i_exp}.OFFP_scores_raw = NaN(2,length(celllist));
                end

                for i_cell = 1:length(celllist)
                    cid = celllist(i_cell);
                    if i_celltype == 1, cell_savename  = sprintf('ONPar_%d',cid);       end
                    if i_celltype == 2, cell_savename  = sprintf('OFFPar_%d',cid);      end
                    if i_celltype == 1, rast_normindex = find(raster_scores{i_exp}.ONP == cid); end
                    if i_celltype == 2, rast_normindex = find(raster_scores{i_exp}.OFFP== cid); end

                    if strcmp(metrics.name,'Viktor_normsubtract_25msec')
                        cell_savename = sprintf('crossvalperf_%s', cell_savename);
                    end

                    if strcmp(metrics.name,'BPS_normsubtract_smooth10msec')
                        eval(sprintf('load %s/%s.mat', d_load_WN,cell_savename));
                        xval_WN = fittedGLM.xvalperformance; clear fittedGLM
                        eval(sprintf('load %s/%s.mat', d_load_NSEM,cell_savename));
                        xval_NSEM = fittedGLM.xvalperformance; clear fittedGLM
                    elseif strcmp(metrics.name,'Viktor_normsubtract_25msec')
                        eval(sprintf('load %s/%s.mat', d_load_WN,cell_savename));
                        vksp_WN = crossval_perf; clear crossval_perf
                        eval(sprintf('load %s/%s.mat', d_load_NSEM,cell_savename));
                        vksp_NSEM = crossval_perf; clear crossval_perf


                    end



                    if strcmp(metrics.name,'BPS_normsubtract_smooth10msec')
                        score_WN_raw   =    xval_WN.logprob_glm_bpspike; 
                        score_NSEM_raw =  xval_NSEM.logprob_glm_bpspike;
                        
                        
                        score_WN_normsubtract   =    xval_WN.logprob_glm_bpspike - raster_scores{i_exp}.stim_type{1}.celltype{i_celltype}.scores.values(rast_normindex);
                        score_NSEM_normsubtract =  xval_NSEM.logprob_glm_bpspike - raster_scores{i_exp}.stim_type{2}.celltype{i_celltype}.scores.values(rast_normindex);
                        
                        score_WN_normdivide   =    xval_WN.logprob_glm_bpspike / raster_scores{i_exp}.stim_type{1}.celltype{i_celltype}.scores.values(rast_normindex);
                        score_NSEM_normdivide =  xval_NSEM.logprob_glm_bpspike / raster_scores{i_exp}.stim_type{2}.celltype{i_celltype}.scores.values(rast_normindex);

                        if i_celltype == 1
                            model_comparison.scores{i_exp}.ONP_scores_raw(1,i_cell)  = score_WN_raw;
                            model_comparison.scores{i_exp}.ONP_scores_raw(2,i_cell)  = score_NSEM_raw;
                            
                            model_comparison.scores{i_exp}.ONP_scores_normsubtract(1,i_cell)  = score_WN_normsubtract;
                            model_comparison.scores{i_exp}.ONP_scores_normsubtract(2,i_cell)  = score_NSEM_normsubtract;
                            
                            model_comparison.scores{i_exp}.ONP_scores_normdivide(1,i_cell)    = score_WN_normdivide;
                            model_comparison.scores{i_exp}.ONP_scores_normdivide(2,i_cell)    = score_NSEM_normdivide;
                        elseif i_celltype == 2
                            model_comparison.scores{i_exp}.OFFP_scores_raw(1,i_cell) = score_WN_raw;
                            model_comparison.scores{i_exp}.OFFP_scores_raw(2,i_cell) = score_NSEM_raw;
                            
                            model_comparison.scores{i_exp}.OFFP_scores_normsubtract(1,i_cell) = score_WN_normsubtract;
                            model_comparison.scores{i_exp}.OFFP_scores_normsubtract(2,i_cell) = score_NSEM_normsubtract;
                            
                            model_comparison.scores{i_exp}.OFFP_scores_normdivide(1,i_cell)  = score_WN_normdivide;
                            model_comparison.scores{i_exp}.OFFP_scores_normdivide(2,i_cell)  = score_NSEM_normdivide;
                        end
                    end  

                    if strcmp(metrics.name,'Viktor_normsubtract_25msec')
                        WN_timebin = find(vksp_WN.scores.Viktor_Time_Bins == 32);
                        NSEM_timebin = find(vksp_NSEM.scores.Viktor_Time_Bins == 32);
                        
                        score_WN_raw   =  vksp_WN.scores.metric_raw(WN_timebin) ;
                        score_NSEM_raw =  vksp_NSEM.scores.metric_raw(NSEM_timebin);

                        score_WN_normsubtract   =  vksp_WN.scores.metric_raw(WN_timebin) - raster_scores{i_exp}.stim_type{1}.celltype{i_celltype}.scores.values(rast_normindex);
                        score_NSEM_normsubtract =  vksp_NSEM.scores.metric_raw(NSEM_timebin) - raster_scores{i_exp}.stim_type{2}.celltype{i_celltype}.scores.values(rast_normindex);
                            
                        score_WN_normdivide   =  vksp_WN.scores.metric_raw(WN_timebin) / raster_scores{i_exp}.stim_type{1}.celltype{i_celltype}.scores.values(rast_normindex);
                        score_NSEM_normdivide =  vksp_NSEM.scores.metric_raw(NSEM_timebin) / raster_scores{i_exp}.stim_type{2}.celltype{i_celltype}.scores.values(rast_normindex);
                        if i_celltype == 1
                            model_comparison.scores{i_exp}.ONP_scores_raw(1,i_cell)  = score_WN_raw;
                            model_comparison.scores{i_exp}.ONP_scores_raw(2,i_cell)  = score_NSEM_raw;
                            
                            model_comparison.scores{i_exp}.ONP_scores_normsubtract(1,i_cell)  = score_WN_normsubtract;
                            model_comparison.scores{i_exp}.ONP_scores_normsubtract(2,i_cell)  = score_NSEM_normsubtract;
                            
                            model_comparison.scores{i_exp}.ONP_scores_normdivide(1,i_cell)    = score_WN_normdivide;
                            model_comparison.scores{i_exp}.ONP_scores_normdivide(2,i_cell)    = score_NSEM_normdivide;
                        elseif i_celltype == 2
                            model_comparison.scores{i_exp}.OFFP_scores_raw(1,i_cell) = score_WN_raw;
                            model_comparison.scores{i_exp}.OFFP_scores_raw(2,i_cell) = score_NSEM_raw;
                            
                            model_comparison.scores{i_exp}.OFFP_scores_normsubtract(1,i_cell) = score_WN_normsubtract;
                            model_comparison.scores{i_exp}.OFFP_scores_normsubtract(2,i_cell) = score_NSEM_normsubtract;
                            
                            model_comparison.scores{i_exp}.OFFP_scores_normdivide(1,i_cell)  = score_WN_normdivide;
                            model_comparison.scores{i_exp}.OFFP_scores_normdivide(2,i_cell)  = score_NSEM_normdivide;
                        end
                    end 
                end

            end

        end
        
        if i_model == 1, model_comparison_A = model_comparison; end
        if i_model == 2, model_comparison_B = model_comparison; end
    end




%% Plotting change in WN_NSEM Plot
MS = 40;
MS_ON = 20;
MS_old = 40;
for i_plot = [1];
    clear vals_A vals_B
     for i_label = 1
            if i_label == 1, label_points = false; end
            if i_label == 2, label_points = true; end
    minval = Inf;
    maxval = -Inf;
    clf; hold on; set(gca, 'fontsize',12)
    if i_plot == 0
        transform = 'ID'; lineplot = true; norm_type = 'raw';
    elseif i_plot == 1
        transform = 'ID_truncate'; lineplot = true;norm_type = 'normsubtract';
    end
  
    
    
    for i_exp = exptests
        if i_exp == 1, colorstring = 'r'; end
        if i_exp == 2, colorstring = 'g'; end
        if i_exp == 3, colorstring = 'b'; end
        if i_exp == 4, colorstring = 'c'; end

        for i_celltype = 1:2
            if strcmp(norm_type, 'normsubtract')
                if i_celltype == 1, vals_A = model_comparison_A.scores{i_exp}.ONP_scores_normsubtract;   vals_B = model_comparison_B.scores{i_exp}.ONP_scores_normsubtract; end
                if i_celltype == 2, vals_A = model_comparison_A.scores{i_exp}.OFFP_scores_normsubtract;  vals_B = model_comparison_B.scores{i_exp}.OFFP_scores_normsubtract;end
                
                if strcmp(transform, 'ID_truncate')
                    vals_A(find(vals_A <= -.75)) = -.75;
                    vals_B(find(vals_B <= -.75)) = -.75;
                end
                
            elseif strcmp(norm_type, 'normdivide')
                if i_celltype == 1, vals_A = model_comparison_A.scores{i_exp}.ONP_scores_normdivide;   vals_B = model_comparison_B.scores{i_exp}.ONP_scores_normdivide; end
                if i_celltype == 2, vals_A = model_comparison_A.scores{i_exp}.OFFP_scores_normdivide;  vals_B = model_comparison_B.scores{i_exp}.OFFP_scores_normdivide;end
            elseif strcmp(norm_type, 'raw')
                if i_celltype == 1, vals_A = model_comparison_A.scores{i_exp}.ONP_scores_raw;   vals_B = model_comparison_B.scores{i_exp}.ONP_scores_raw; end
                if i_celltype == 2, vals_A = model_comparison_A.scores{i_exp}.OFFP_scores_raw;  vals_B = model_comparison_B.scores{i_exp}.OFFP_scores_raw;end
                
                
                vals_A(find(vals_A<= 0)) = 0;
                vals_B(find(vals_B<= 0)) = 0;            
            end
                
            
            plotstring_new = sprintf('%s.',colorstring);
            
            if strcmp(transform,'ID')
                vals_A = vals_A;
                vals_B = vals_B;
            end
            if length(transform) >=8 &&  strcmp(transform(1:8),'logistic')
                vals_A = 1./ ( 1 + exp(-(log_k)*vals_A) ) - .5;
                vals_B = 1./ ( 1 + exp(-(log_k)*vals_B) ) - .5;
            end

            maxval = max( maxval, max(max(vals_A(:)),max(vals_B(:))) );
            minval = min( minval, min(min(vals_A(:)),min(vals_B(:))) );
            
            
            plot(vals_A(1,:), vals_A(2,:), 'k.', 'markersize', MS_old);
            plot(vals_B(1,:), vals_B(2,:), plotstring_new, 'markersize', MS);
            
            if i_celltype == 1
                plot(vals_B(1,:), vals_B(2,:), 'w.', 'markersize', MS_ON);
            end
            if lineplot 
                for i_cell = 1:size(vals_A,2)
                    x_line = linspace(vals_A(1,i_cell), vals_B(1,i_cell),100);
                    y_line = linspace(vals_A(2,i_cell), vals_B(2,i_cell),100);
                    plot(x_line,y_line,'k');
                end
            end
            
            if exist('label_points','var') && label_points
                    for i_cell = 1:length(cids)
                        lab = sprintf('%d', cids(i_cell));
                        text(vals_B(1,i_cell),vals_B(2,i_cell),lab);
                    end
            end
            
            
        end
    end
    unity_line = linspace(minval, maxval,100);
    plot(unity_line,unity_line,'k')
    xlim([minval,maxval]);
    ylim([minval,maxval]);
     if i_metric == 1 && strcmp(transform, 'ID_truncate')
        xlim([-.75,.25]);
        ylim([-.75,.25]);
        unity_line = linspace(-.75, .25,100);
        plot(unity_line,unity_line,'k')
    end
    
    xlabel(metrics.plots.xlabel);
    ylabel(metrics.plots.ylabel);
    
    if i_metric == 1 && strcmp(transform, 'ID_truncate')
        set(gca,'xtick', [-.75,-.5,-.25,0,.25])
        set(gca,'ytick', [-.75,-.5,-.25,0,.25])
    end
    title(sprintf('%s', shortname))
  % title(sprintf('%s:   %s:( %s  %s)', comparison,transform,metrics.plots.title_base, norm_type),'interpreter','none');
    plotname = sprintf('%s_%s', transform,norm_type); hold off
        if exist('label_points','var') && label_points
            plotname = sprintf('%s_Labels',plotname);
        end
    orient landscape
    eval(sprintf('print -dpdf %s/%s_%s_%s.pdf', savedir,comparison,savename, plotname));
    
     end
    
end
%% Plotting WNold-WNnew and NSEMold-NSEMnew
%{
MS_A = 16;
MS_B = 20;

for i_stimtype = [1,2]
    
    
    for i_plot = [0,1,2,3];
        clear vals_A vals_B
        for i_label = 1:2
            if i_label == 1, label_points = false; end
            if i_label == 2, label_points = true; end
        
        minval = Inf;
        maxval = -Inf;
        clf;hold on; set(gca,'fontsize',10)
        if i_plot == 0
            transform = 'ID'; lineplot = true;
        elseif i_plot == 1
            transform = 'logistic_1'; log_k=1; lineplot = true;
        elseif i_plot == 2
            transform = 'logistic_2'; log_k=2; lineplot = true;
        elseif i_plot == 3
            transform = 'logistic_3'; log_k=3; lineplot = true;
        elseif i_plot == 4
            transform = 'logistic_4'; log_k=4; lineplot = true;
        elseif i_plot == 5
            transform = 'logistic_5'; log_k=5; lineplot = true;
        end
        
        for i_exp = exptests
            if i_exp == 1, colorstring = 'r'; end
            if i_exp == 2, colorstring = 'g'; end
            if i_exp == 3, colorstring = 'b'; end
            if i_exp == 4, colorstring = 'c'; end

            for i_celltype = 1:2

                if i_celltype == 1, vals_A = model_comparison_A.scores{i_exp}.ONP_scores_normsubtract(i_stimtype,:);   vals_B = model_comparison_B.scores{i_exp}.ONP_scores_normsubtract(i_stimtype,:); end
                if i_celltype == 2, vals_A = model_comparison_A.scores{i_exp}.OFFP_scores_normsubtract(i_stimtype,:);  vals_B = model_comparison_B.scores{i_exp}.OFFP_scores_normsubtract(i_stimtype,:);end

                
                if i_celltype == 1, plotstring_surround = sprintf('%so', colorstring); cids = model_comparison.scores{i_exp}.ONP_cells; end
                if i_celltype == 2, plotstring_surround = sprintf('%ss', colorstring); cids = model_comparison.scores{i_exp}.OFFP_cells; end
                plotstring_center = sprintf('%s.',colorstring);
                
                
                if strcmp(transform,'ID')
                    vals_A = vals_A;
                    vals_B = vals_B;
                end
                if length(transform) >=8 &&  strcmp(transform(1:8),'logistic')
                    vals_A = 1./ ( 1 + exp(-(log_k)*vals_A) ) - .5;
                    vals_B = 1./ ( 1 + exp(-(log_k)*vals_B) ) - .5;
                end


                maxval = max( maxval, max(max(vals_A(:)),max(vals_B(:))) );
                minval = min( minval, min(min(vals_A(:)),min(vals_B(:))) );
                
                
                

                plot(vals_A, vals_B, plotstring_center, 'markersize', MS_B);
                plot(vals_A, vals_B, plotstring_surround, 'markersize', MS_A);
                
                if exist('label_points','var') && label_points
                    for i_cell = 1:length(cids)
                        lab = sprintf('%d', cids(i_cell));
                        text(vals_A(i_cell),vals_B(i_cell),lab);
                    end
                end
                
            end
        end
        unity_line = linspace(minval, maxval,100);
        plot(unity_line,unity_line,'k')
        xlim([minval,maxval]);
        ylim([minval,maxval]);
        %xlabel(metrics.plots.xlabel);
        ylabel(comparison);
        if i_stimtype == 1
            title(sprintf('WN %s: %s:( %s )', comparison,transform,metrics.plots.title_base),'interpreter','none');
        end
        if i_stimtype == 2
            title(sprintf('NSEM %s: %s:( %s )', comparison,transform,metrics.plots.title_base),'interpreter','none');
        end
        plotname = sprintf('%s', transform'); hold off
        if exist('label_points','var') && label_points
            plotname = sprintf('%s_Labels',plotname);
        end
        orient landscape
        
        if i_stimtype == 1
            eval(sprintf('print -dpdf %s/DeltaWN_%s_%s_%s.pdf', savedir,comparison,savename, plotname));
        end
        if i_stimtype == 2
            eval(sprintf('print -dpdf %s/DeltaNSEM_%s_%s_%s.pdf', savedir,comparison,savename, plotname));
        end
        
        end

    end
end
%}

%%
end