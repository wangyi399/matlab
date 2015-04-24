%%% COMPLETE AND DOCUMENTED ON 2012-12-09   AK Heitman
%%% This can be a lengthy program

% MetricAnal should automatically get saved into the correct directory 
% Should also place MetricAnal into correct structure of the Solution Space
% Analysis folder!

% Inputs: Basepars and SimandMetrics   
% SimandMetrics.BW{i_trial_i_Sim}
%  .normed_metricdist    SPKD dist from Sim to corresponding Retina sp train
%                        used to compute avg per trial error wrt Retina
%  .sptime_secs          Simulation spike times 
%                        used for intra-trisl Sim variablity
%                        used to make Sim_Raster to estimate Simulations
%                        variability across trial 
%  .MetricPars           parameters used for SPKD, needs to be consistent
%                        used to for Sim)Rater variability

% Outputs: MetricAnal.BW (or NSEM)
%  .pertrial.normederror   avg spkd of simulations per trial to retina
%  .pertrial.normedsimvar  avg spkd within simulations from same trial
%  .avg_pertrial. "        same as above, but averaging over trials
%                          trial strucutre not disrupted.. avg of avg
%  .crosstrail.simvar           

% NORMED = DIVIDED BY RETINA RASTER VARIATION (AVG. TRIAL PAIR SPKD)

% This code calls very little and is mostly self contained



% SPKD is the key program.. JD Victor   

%CALLS:
% Directories_Params_func_all
% raster_variation_metrics
% SPKD

function [MetricAnal] =  analyze_simtoraster_metrics(Basepars,SimandMetrics) 
%% Directory Setting  
%%%%%%%% Make Second Dir for Solution Space Analysis %%%%%%%%%
CrossTrialVar_Simnumber = 2;

GLMPars                       = Basepars.GLMPars;
[StimulusPars DirPars]      = Directories_Params_func_all(Basepars.exp_nm, GLMPars.debug);
%%%%%%%%%% Directory Fixing %%%%%%%%%%%
fit_type = GLMPars.fit_type; Head_CTYPE = Basepars.celltype;
switch (fit_type )
   case 'BW'
      fit_blks =   StimulusPars.BW.FitBlocks;
   case 'NSEM'
      fit_blks = StimulusPars.NSEM.FitBlocks;
end
if GLMPars.debug
    d_sfx = sprintf( 'debug_bin%d_blk%d',GLMPars.binning,length(fit_blks) );
else
    d_sfx = sprintf( 'bin%d_blk%d',GLMPars.binning,length(fit_blks) );
end
if  Basepars.Coupling, d_save = sprintf('%s/%s_FIT/%s/%s_ps%d_%s/%s',DirPars.output_dir,fit_type,Head_CTYPE,Basepars.k_filtermode,Basepars.ps_filternumber,'cpON' ,d_sfx); end
if ~Basepars.Coupling, d_save = sprintf('%s/%s_FIT/%s/%s_ps%d_%s/%s',DirPars.output_dir,fit_type,Head_CTYPE,Basepars.k_filtermode,Basepars.ps_filternumber,'cpOFF',d_sfx); end
if Basepars.Coupling && Basepars.BiDirect_CP, d_save = sprintf('%s/%s_FIT/%s/%s_ps%d_%s/%s',DirPars.output_dir,fit_type,Head_CTYPE,Basepars.k_filtermode,Basepars.ps_filternumber,'cpBiD',d_sfx);end
MetricAnalysis_dir = sprintf('%s/Metric_Analysis',d_save);  clear d_sfx d_save fit_blks fit_type Head_CTYPE
if (~isdir(MetricAnalysis_dir)),mkdir(MetricAnalysis_dir); end
cd(MetricAnalysis_dir);  
SolutionSpace_AnalysisDir =sprintf('%s/SolutionSpace_Analysis',DirPars.output_dir);
if (~isdir(SolutionSpace_AnalysisDir)),mkdir(SolutionSpace_AnalysisDir); end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
for count = 1:2
    %% Average across simulations, Maintain Trial Distances
    clear MA SimMet
    if count == 1, stim_vrf = 'BW';   SimMet = SimandMetrics.BW;   RetVar= SimandMetrics.BW_RasterVariation;   Slv_StimPars = StimulusPars.BW;   end
    if count == 2, stim_vrf = 'NSEM'; SimMet = SimandMetrics.NSEM; RetVar= SimandMetrics.NSEM_RasterVariation; Slv_StimPars = StimulusPars.NSEM; end
    trials = size(SimMet,1);
    MA.cellid = Basepars.headid; 
    MA.stim        = stim_vrf;
    MA.pertrial.normederror    = cell (trials , 1);    
    for i_trial = 1 : trials
        atemp     = [SimMet{ i_trial , :}]; 
        met_temp  = [atemp.metricdist];
        norm_temp = [atemp.normed_metricdist];            
        
        MA.pertrial.normederror{i_trial}.blocknum              =  atemp(1).blocknum;
        MA.pertrial.normederror{i_trial}.avg_millisec          =  mean ([norm_temp.millisec]);
        MA.pertrial.normederror{i_trial}.avg_halfcentisec      =  mean ([norm_temp.halfcentisec]);
        MA.pertrial.normederror{i_trial}.avg_centisec          =  mean ([norm_temp.centisec]);
        MA.pertrial.normederror{i_trial}.avg_halfdecisec       =  mean ([norm_temp.halfdecisec]);
        MA.pertrial.normederror{i_trial}.avg_decisec           =  mean ([norm_temp.decisec]);
        
        MA.pertrial.normederror{i_trial}.std_millisec          =  std ([norm_temp.millisec]);
        MA.pertrial.normederror{i_trial}.std_halfcentisec      =  std ([norm_temp.halfcentisec]);
        MA.pertrial.normederror{i_trial}.std_centisec          =  std ([norm_temp.centisec]);     
        MA.pertrial.normederror{i_trial}.std_halfdecisec       =  std ([norm_temp.halfdecisec]);
        MA.pertrial.normederror{i_trial}.std_decisec           =  std ([norm_temp.decisec]);   
    end
    clear norm_temp met_temp atemp i_trial
    
    %% Average across simulatinos and Trials
    atemp = [MA.pertrial.normederror{:}];
    MA.avg_pertrial.message       ='Average Across Trials of trial specific measurements. Coresspondence between Raster Trial and neighbor spikes used for Simulations held intact !!';
    MA.avg_pertrial.normederror.avg_milli     = mean( [atemp.avg_millisec] ); 
    MA.avg_pertrial.normederror.avg_halfcenti = mean( [atemp.avg_halfcentisec] ); 
    MA.avg_pertrial.normederror.avg_centi     = mean( [atemp.avg_centisec] ); 
    MA.avg_pertrial.normederror.avg_halfdeci  = mean( [atemp.avg_halfdecisec] ); 
    MA.avg_pertrial.normederror.avg_deci      = mean( [atemp.avg_decisec] ); 

    MA.avg_pertrial.normederror.std_milli     = mean( [atemp.std_millisec] ); 
    MA.avg_pertrial.normederror.std_halfcenti = mean( [atemp.std_halfcentisec] ); 
    MA.avg_pertrial.normederror.std_centi     = mean( [atemp.std_centisec] ); 
    MA.avg_pertrial.normederror.std_halfdeci  = mean( [atemp.std_halfdecisec] ); 
    MA.avg_pertrial.normederror.std_deci      = mean( [atemp.std_decisec] );
   % MA.avg_pertrial.normederror.message       ='Averaging the avg error pertrial across trials.  Trial structure is still maintained';
    clear atemp    
    
    %% Compute intratrial variability of the Simulations 
	clear choseones chosenpairs 
	simnum         = size(SimMet,2);
	simpairs       = nchoosek(1:simnum, 2);
	totalsimpairs  = min (20, size(simpairs,1));
     
    if totalsimpairs >  size(simpairs,1), chosenones = ceil ( size(simpairs,1)* rand (totalsimpairs , 1) ); end
    if totalsimpairs <= size(simpairs,1), chosenones =  1: size(simpairs,1);                                end
	chosenpairs    = simpairs(chosenones,:);


	MA.pertrial.normedsimvar = cell(trials, 1);
	clear i_pair i_trial chosenones simnum simpairs
	pctdonepre =0;
	for i_trial = 1 : trials
        MA.pertrial.normedsimvar{i_trial}.pairs.millisec        = zeros(totalsimpairs, 1);
        MA.pertrial.normedsimvar{i_trial}.pairs.halfcentisec    = zeros(totalsimpairs, 1);
        MA.pertrial.normedsimvar{i_trial}.pairs.centisec        = zeros(totalsimpairs, 1);
        MA.pertrial.normedsimvar{i_trial}.pairs.halfdecisec     = zeros(totalsimpairs, 1);
        MA.pertrial.normedsimvar{i_trial}.pairs.decisec         = zeros(totalsimpairs, 1);
        for i_pair = 1: totalsimpairs
            train1 = SimMet{i_trial , chosenpairs(i_pair,1)}.metric_spikes;  
            train2 = SimMet{i_trial , chosenpairs(i_pair,2)}.metric_spikes;           
            MA.pertrial.normedsimvar{i_trial}.pairs.millisec(i_pair)     = spkd ( train1 , train2 , 1000) / RetVar.avgmillisec;
            MA.pertrial.normedsimvar{i_trial}.pairs.halfcentisec(i_pair) = spkd ( train1 , train2 , 200 ) / RetVar.avghalfcentisec;
            MA.pertrial.normedsimvar{i_trial}.pairs.centisec(i_pair)     = spkd ( train1 , train2 , 100 ) / RetVar.avgcentisec; 
            MA.pertrial.normedsimvar{i_trial}.pairs.halfdecisec(i_pair)  = spkd ( train1 , train2 , 20  ) / RetVar.avghalfdecisec;
            MA.pertrial.normedsimvar{i_trial}.pairs.decisec(i_pair)      = spkd ( train1 , train2 , 10  ) / RetVar.avgdecisec;
        end
        pctdone =100* i_trial / trials;
        if round(pctdone/10) > round(pctdonepre/10);
            display(sprintf('PercentIntraTrialSimulationVaraibilityDone_%d',round(pctdone)));
        end
        pctdonepre = pctdone;
        MA.pertrial.normedsimvar{i_trial}.avg_millisec         = mean(MA.pertrial.normedsimvar{i_trial}.pairs.millisec);
        MA.pertrial.normedsimvar{i_trial}.avg_halfcentisec     = mean(MA.pertrial.normedsimvar{i_trial}.pairs.halfcentisec);
        MA.pertrial.normedsimvar{i_trial}.avg_centisec         = mean(MA.pertrial.normedsimvar{i_trial}.pairs.centisec); 
        MA.pertrial.normedsimvar{i_trial}.avg_halfdecisec      = mean(MA.pertrial.normedsimvar{i_trial}.pairs.halfdecisec); 
        MA.pertrial.normedsimvar{i_trial}.avg_decisec          = mean(MA.pertrial.normedsimvar{i_trial}.pairs.decisec);         
    end
    clear pctdonepre pctdone chosenpairs atemp  totalsimpairs simpairs
	clear atemp train1 train2 i_trial i_pair clear Ret_Var
    
	atemp = [MA.pertrial.normedsimvar{:}];
    MA.avg_pertrial.normedsimvar.avg_millisec  = mean( [atemp.avg_millisec] ); 
    MA.avg_pertrial.normedsimvar.avg_halfcenti = mean( [atemp.avg_halfcentisec] ); 
    MA.avg_pertrial.normedsimvar.avg_centi     = mean( [atemp.avg_centisec] ); 
    MA.avg_pertrial.normedsimvar.avg_halfdeci  = mean( [atemp.avg_halfdecisec] ); 
    MA.avg_pertrial.normedsimvar.avg_deci      = mean( [atemp.avg_decisec] ); 
    
    %% Compute Total Simulation Variability
    clear SimXTVar_1 SimXTVar_2 SIM_RasterCell
    for i_Sim = 1:CrossTrialVar_Simnumber
        SIM_RasterCell = cell(trials , 1);

        for i_trial= 1:trials
            SIM_RasterCell{i_trial}.spikes = SimMet{i_trial , i_Sim}.sptimes_secs;
        end
        startlate = SimandMetrics.MetricPars.startlate; endearly = SimandMetrics.MetricPars.endearly; 

        maxpairs = 4 * max(trials);  raster_time = Slv_StimPars.nsec_o; 
        SIM_RasterVariability = raster_variation_metrics( SIM_RasterCell, raster_time, startlate, endearly, maxpairs);
        
        if i_Sim == 1, SimXTVar_1 = SIM_RasterVariability.summary_stats; end
        if i_Sim == 2, SimXTVar_2 = SIM_RasterVariability.summary_stats; end
    end
    MA.crosstrial.normedsimvar.millisec     = ( SimXTVar_1.avgmillisec     + SimXTVar_2.avgmillisec     ) / ( 2 * RetVar.avgmillisec     );
    MA.crosstrial.normedsimvar.halfcentisec = ( SimXTVar_1.avghalfcentisec + SimXTVar_2.avghalfcentisec ) / ( 2 * RetVar.avghalfcentisec );
    MA.crosstrial.normedsimvar.centisec     = ( SimXTVar_1.avgcentisec     + SimXTVar_2.avgcentisec     ) / ( 2 * RetVar.avgcentisec     );
    MA.crosstrial.normedsimvar.halfdecisec  = ( SimXTVar_1.avghalfdecisec  + SimXTVar_2.avghalfdecisec  ) / ( 2 * RetVar.avghalfdecisec  );
    MA.crosstrial.normedsimvar.decisec      = ( SimXTVar_1.avgdecisec      + SimXTVar_2.avgdecisec      ) / ( 2 * RetVar.avgdecisec      );
    
    if count == 1,   BW_Anal = MA; end
    if count == 2, NSEM_Anal = MA; end
    clear MA SIM_RasterVariability startlate endearly maxpairs raster_time SimXTVar_1 SimXTVar_2
    
    
end
  
%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%
%% Save to the specific run's output directory
MetricAnal.cid        = Basepars.headid;
MetricAnal.note       ='In General, Rows are the Simulations,  Columns are the trials or blocks';
MetricAnal.BW         = BW_Anal;
MetricAnal.NSEM       = NSEM_Anal;
MetricAnal.MetricPars = SimandMetrics.MetricPars;
if ~SimandMetrics.MetricPars.debug
    save(sprintf('%s/%d_MetricAnal_%s.mat',MetricAnalysis_dir, Basepars.headid,Basepars.fn_save), 'MetricAnal');
end

if SimandMetrics.MetricPars.debug
    save(sprintf('%s/%d_dbugMetricAnal_%s.mat',MetricAnalysis_dir, Basepars.headid,Basepars.fn_save), 'MetricAnal');
end
answer = 1;


%keyboard
%clear MetricAnal
%save(sprintf('%d_MetricAnal_%s',cid,Basepars.fn_save), 'BW_MetricAnal' , 'NSEM_MetricAnal');% 'BW_Simulations','NSEM_Simulations');
Basepars_brief = Basepars;
Basepars_brief = rmfield(Basepars_brief, 'trackprog_dir');
Basepars_brief = rmfield(Basepars_brief, 'kx_STA');
Basepars_brief = rmfield(Basepars_brief, 'crop_idx');
Basepars_brief = rmfield(Basepars_brief, 'p_evolve');

clear SolSpace_MetricAnal; clear Sol
SolSpace_MetricAnal_thisparset.BW_Test       = BW_Anal;
SolSpace_MetricAnal_thisparset.NSEM_Test     = NSEM_Anal;
SolSpace_MetricAnal_thisparset.cid           = Basepars.headid;
SolSpace_MetricAnal_thisparset.k_filtermode  = Basepars.k_filtermode;
SolSpace_MetricAnal_thisparset.Coupling      = Basepars.Coupling;
SolSpace_MetricAnal_thisparset.BiDirect_CP   = Basepars.BiDirect_CP;
SolSpace_MetricAnal_thisparset.tolfun        = GLMPars.tolfun;
SolSpace_MetricAnal_thisparset.binning       = GLMPars.binning;
SolSpace_MetricAnal_thisparset.Basepars      = Basepars_brief;

if strcmp(Basepars.celltype,'ON-Parasol')
    Ctype = 'ONPar';
elseif strcmp(Basepars.celltype, 'OFF-Parasol')
    Ctype = 'OFFPar';
end
filename = sprintf('%s_%d_Metrics', Ctype ,  Basepars.headid)
if  exist(sprintf('%s/%s.mat',SolutionSpace_AnalysisDir,filename))
    load(sprintf('%s/%s.mat',SolutionSpace_AnalysisDir,filename));  
    index = max(size(SolSpace_MetricAnal)) + 1;
    SolSpace_MetricAnal{index}  = SolSpace_MetricAnal_thisparset;
    clear index
end
if ~exist(sprintf('%s/%s.mat',SolutionSpace_AnalysisDir,filename))
    SolSpace_MetricAnal{1}  = SolSpace_MetricAnal_thisparset;        
end

save(sprintf('%s/%s.mat',SolutionSpace_AnalysisDir,filename), 'SolSpace_MetricAnal');
clear SolSpace_MetricAnal 

end



%}
