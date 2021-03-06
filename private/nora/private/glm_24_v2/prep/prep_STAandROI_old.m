% Old because it doesn't work for NSEM  (2013-12-13)

% Saved the Movies as uint8
% But do computations as singles

% ALOT Still left in terms of resolution of STA if its 8-1 or 8-2
% and binning of stimulus .. etc.

% function      prep_STAandROI
%               2013-12-04  AKHeitman (previously EDOI) 
%
%               
%
% usage:        
%
% arguments:    slv_type is either 'BW' or 'NSEM'
%               map_type is either 'mapEI' or 'mapPRJ'
%
%
% calls:        Directories_Params_v18_split
%               STA_blockcomp_v18              
%
%
% outputs:     STAandROI  
%              Full STA and ROI center sd from master       
%
% paths:        run glmpath_18.m before everything
%
%
% Previous:     prep_STAandROI_MoviePlusMinus2


% Principal: Build STA one block at a time.  Just average the STA over all
% blocks !
% Preload the ROI center from computed receouve fuekd in master dataset


% 2012-11-1 UPDATE!!!  BIG CHANGE from .02 .98  to -.5 to .5
 %move the movie back to .5 -.5 in the prep and throughout  


% COMPUTE THE STA, FIND ITS SVD AND INITIALIZE

% 0) INITILIZE  LOAD CELL IDS AND SPIKES
% 1) LOAD THE MOVIE (EITHER NSEM OR BW)
% 2) CYCLE THROUGH CELLS  COMPUTE STA THEN THE ROI
% 3) SAVE INTO STAandROI STRUCT FOR EACH CELL



%%%%%%%%   0. INITIALIZE: LOAD CELL IDS AND SPIKES     %%%%%%%%%%
%clear
%%

function prep_STAandROI_old(stringdate, fit_type, map_type, boolean_debug, boolean_shortlist) 
exp_nm = stringdate; 

CTYPE = { 'On-Parasol' , 'Off-Parasol','On-Midget','Off-Midget'}; %
CTYPE_sname = { 'ONPar' , 'OFFPar','ONMid','OFFMid' };


if shortlist &&


[StimulusPars DirPars datarun_slv datarun_mas] = Directories_Params_v18_split(exp_nm, boolean_debug, fit_type, map_type)   %false means not debug mode
if strcmp(fit_type, 'BW')
    SPars = StimulusPars.BW;
elseif strcmp(fit_type, 'NSEM')
    SPars = StimulusPars.NSEM;
end
 

% Load BW Movie
if strcmp(fit_type, 'BW')
    BWmoviedir = sprintf('%s/%s' ,DirPars.stimulimatxmlfiles, SPars.fit_rast_fullname);
    eval( sprintf('load %s/BWmovie.mat', BWmoviedir) );
end
    

clear moviedir
STAPars.resfactor = 1;
STAPars.frameshift = 1;
STAPars.K_slen     = 15;
STAPars.STA_Frames = 30;

if STAPars.resfactor == 1 && STAPars.frameshift == 1
    d_save = sprintf('%s/STAandROI_default',DirPars.output_dir);
else
    d_save = sprintf('%s/STAandROI_res%d_shift%d',DirPars.output_dir, STAPars.resfactor, STAPars.frameshift);
end
if ~exist(d_save,'dir'),mkdir(d_save),end
plotdir = sprintf('%s/STAplots',d_save);
if ~exist(plotdir,'dir'),mkdir(plotdir),end
% Load Movie into Sngle Format by cell so can be absorbed by STA_blockcomp_v18
totalblocks = max(max(SPars.NovelBlocks), max(SPars.StaticBlocks));
FitBlocks = SPars.FitBlocks;
blocked_stimulus = cell(1,totalblocks);
for i_blk = FitBlocks
	fitmovieind = find(BWmovie.fitmovie.ind_to_block == i_blk);
	blocked_stimulus{i_blk} = single(BWmovie.fitmovie.movie_byblock{fitmovieind}.matrix);
end
    
%%
figure;
for n_ctype = 1:length(CTYPE)
   
   [celltype_index, CID] = celltype_id_AH(CTYPE{n_ctype}, datarun_slv.cell_types);
 %  CID = datarun_mas.cell_types{n_ctype}.cell_id;
   if exist('shortlist_cellID', 'var')
       CID = shortlist_cellID{n_ctype};
   end
   %% RUN THROUGH EACH CELL .. PER CELL LOOP
    
    for n_cid = 1:length(CID) 
       clear STAandROI
       STAandROI.cell_type   = CTYPE{n_ctype};
       STAandROI.cell_id     = CID(n_cid);
       STAandROI.cell_idx    = find(datarun_slv.cell_ids==STAandROI.cell_id);
       STAandROI.master_idx  = find(datarun_mas.cell_ids == STAandROI.cell_id);
       STAandROI.t_sp        = datarun_slv.spikes{STAandROI.cell_idx};
       STAandROI.savename    = sprintf('%s_%d',CTYPE_sname{n_ctype},CID(n_cid));
       STAandROI.maptype     = map_type;
       
       
       
       clear totalblocks fitmovieind
       
       
       rawspiketimes = STAandROI.t_sp;
       blocked_frametimes = datarun_slv.block.t_frame; 
       resfactor  = STAPars.resfactor;
       frameshift = STAPars.frameshift;
       staframes  = STAPars.STA_Frames;
       
       %%%%%%%%%%%%%%%%%%%%%%
       %%%%%  STA blockcomp call %%%%%
       %%%%%%%%%%%%%%%%%%%%%%
       display(sprintf('Working on %s', STAandROI.savename));
       
       [STA , STAoutputnote]= STA_blockcomp_v18(blocked_stimulus,rawspiketimes,FitBlocks,blocked_frametimes,staframes,resfactor,frameshift);
       clear resfactor staframes frameshift
       STAandROI.STA      = STA;
       STAandROI.STAnotes = STAoutputnote; 
       STAandROI.pars     = STAPars;
       %%%%%%%%%%%%%%%
       
       % Compute ROI coord %
       stafit_centercoord = ( datarun_mas.vision.sta_fits{STAandROI.master_idx}.mean );
       stafit_sd = ( datarun_mas.vision.sta_fits{STAandROI.master_idx}.sd);
       slvdim.height = SPars.height; slvdim.width = SPars.width; 
       [center,sd]  = visionSTA_to_xymviCoord(stafit_centercoord, stafit_sd, StimulusPars.master, slvdim);
       
       STAandROI.master_ROIcentercoord = center;
       STAandROI.master_ROIstandarddev = sd;
       STAandROI.note1 = 'ROI refers to master STA coords';
       STAandROI.note2 = 'rk2 decomp and ROI size will be done within glm loop';
       
       eval(sprintf('save %s/STAandROI_%s.mat STAandROI',d_save,STAandROI.savename));
       
       
       clf ; 
       STApeak = .04; % ~40 millisecs before spike the STA peaks
       t_ind = round(STApeak /  SPars.tstim);
       
       subplot(2,1,1); 
       imagesc((STA(:,:,t_ind))'); colorbar; hold on
       stringtitle = sprintf('STA for %s, cell %d ' ,CTYPE_sname{n_ctype}, STAandROI.cell_id);
       title(stringtitle);
       stringxlab = sprintf('STA at %d frames before Spike', t_ind);
       xlabel(stringxlab); hold off
       subplot(2,1,2); imagesc(squeeze(STA(center.x_coord, :, :))); colorbar; hold on
       xlabel('time before spike in frames'); ylabel('ignore xcoord'); hold off
       pdfname = sprintf('%s/%s.pdf', plotdir,STAandROI.savename);
       eval(sprintf('print -dpdf %s',pdfname) )
       %%%%%%%%
    end
end




%%%%%%%%%%%%%%%%%%%%%%
%%%%% OLD STUFF %%%%%%

%{
       %% ROI CONSTRUCTION AND STA OVER THE ROI
       %%%%%%%%

       %%% we could also consider the loading center from the master

       %%% (X,Y) CENTER OF MASS  AND THEN ROI OF SIZE 15 15
       %switch fit_type
          % case 'BW'
             % max_ind      = round( datarun_mas.vision.sta_fits{STAandROI.master_idx}.mean ) % max deviation from the mean   the index of it
              %[t,max_ind2] = max(abs(STAandROI.STA(:)-1/2)); 
              %[max_x,max_y,max_fr] = ind2sub(size(STAandROI.STA),max_ind2);
              %maxind2 = [max_x,max_y]

       %%%      
       
       
       
       
       
       
       max_x   = round( max_ind(1)* (ts_vs.width  /master_width)  );
       max_y   = ts_vs.height - round( max_ind(2)* (ts_vs.height /master_height) );
         %%% just a hack .. don't know why
       [~, max_fr] = max(abs(STAandROI.STA(max_x,max_y,:) - mean(STAandROI.STA(:)))  );



       if rem(K_slen,2) == 1
          STAandROI.ROI.o_s = (K_slen-1)/2; % off-set from the peak
       end
       %%% RECENTER. . DEFINE BEST K_slen BY K_slen ROI
       [xdim,ydim,zdim] =size ( STAandROI.STA );
       xhigh = (round(max_x+STAandROI.ROI.o_s));
       xlow  = (round(max_x-STAandROI.ROI.o_s));
       if xhigh > xdim
           xhigh = xdim; xlow  = xdim - K_slen + 1;
       end
       if xlow < 1
           xlow = 1; xhigh = K_slen ;
       end 
       yhigh = (round(max_y+STAandROI.ROI.o_s));
       ylow  = (round(max_y-STAandROI.ROI.o_s));
       if yhigh > ydim
           yhigh = ydim; ylow  = ydim - K_slen + 1;
       end
       if ylow < 1
           ylow = 1; yhigh = K_slen ;
       end
       STAandROI.ROI.ROI_x = (xlow:xhigh);
       STAandROI.ROI.ROI_y = (ylow:yhigh);
       STAandROI.ROI.max_xyfr = [max_x,max_y,max_fr];
       STAandROI.ROI.STA = STAandROI.STA(STAandROI.ROI.ROI_x,STAandROI.ROI.ROI_y,:);
       %%% COMPUTE STA OVER JUST THE ROI
       STAandROI.ROI.mov = cell(n_blk,1);
       for k = [1,FitBlocks]
          if (k == 1 || rem(k,2) == 0)
             STAandROI.ROI.mov{k} = ts_vs.mov{k}(STAandROI.ROI.ROI_x,STAandROI.ROI.ROI_y,:);
          end
       end
       STAandROI.t_bin = ts_vs.refresh_time/1000; % in sec
       STAandROI.block.t_frame = datarun_slv.block.t_frame;
       %-- first several significant components in STA (in ROI)
       zmSTA = reshape(STAandROI.ROI.STA,K_slen^2,STA_Frames);
         % subtract (true) mean value.
       rk = 15;
       [U,S,V] = svds(zmSTA,rk);

       STAandROI.ROI.zmSTA.STA = zmSTA;
       STAandROI.ROI.zmSTA.U = U;
       STAandROI.ROI.zmSTA.S = S;
       STAandROI.ROI.zmSTA.V = V;

       eval(sprintf('save %s/STAandROI_id%d_%dsq STAandROI',d_save,STAandROI.cell_id,STAandROI.ROI.o_s*2+1));
    %%
       %%%%%%%%%%%%%%%%%%
       %%%%% PLOTTING STA MAIN OUTPUT FIGURES
       %%%%%%%%%%%%%%%%%%
       rk=15;
       for k = 1:3  %WE ONLY REALLY NEED THE FIRST 5 PRINCIPAL COMPONENTS 
          figure(1) 
           %%% pause   if you want to watch things change one by one
           clf
          %-- raw STA
          subplot(3,4,1)
          imagesc(zmSTA')
          title(sprintf('STA (ID %4d)',STAandROI.cell_id))
          xlabel('Space [stixel]')
          ylabel('Time [frame]')
          colorbar horizontal

          m_fr = STAandROI.ROI.max_xyfr(3);
          ax = 5:5:15;

          subplot(3,4,3)
          imagesc(reshape(zmSTA(:,m_fr),K_slen,K_slen)), axis image
          set(gca,'xtick',ax), set(gca,'ytick',ax)
          colorbar horizontal
          title(sprintf('Spatial STA at the peak (%d-th frame)',m_fr))

          %-- k-th rank
          idxk = zeros(rk,1);
          idxk(k) = 1;
          STAk = U*diag(idxk.*diag(S))*V';

          subplot(3,4,5)
          imagesc(STAk')
          title(sprintf('%d-th rank component',k))
          xlabel('Space [stixel]')
          ylabel('Time [frame]')
          colorbar horizontal

          m_fr = STAandROI.ROI.max_xyfr(3);

          subplot(3,4,7)
          imagesc(reshape(STAk(:,m_fr),K_slen,K_slen)), axis image
          set(gca,'xtick',ax), set(gca,'ytick',ax)
          colorbar horizontal
          title(sprintf('Spatial STA (%d-th frame)',m_fr))

          %-- cumulative
          idxc = zeros(rk,1);
          idxc(1:k) = 1;
          STAc = U*diag(idxc.*diag(S))*V';

          subplot(3,4,9)
          imagesc(STAc')
          title(sprintf('Rank-%d STA',k))
          xlabel('Space [stixel]')
          ylabel('Time [frame]')
          colorbar horizontal

          DIFc = zmSTA-STAc;
          subplot(3,4,10)
          imagesc(DIFc')
          err = var(DIFc(:))/var(zmSTA(:))*100;
          title(sprintf('Difference (%2.1f%s)',err,'%'))
          xlabel('Space [stixel]')
          ylabel('Time [frame]')
          colorbar horizontal

          subplot(3,4,11)
          imagesc(reshape(STAc(:,m_fr),K_slen,K_slen)), axis image
          set(gca,'xtick',ax), set(gca,'ytick',ax)
          colorbar horizontal
          title(sprintf('Spatial STA (%d-th frame)',m_fr))

          subplot(3,4,12)
          imagesc(reshape(DIFc(:,m_fr),K_slen,K_slen)), axis image
          xlabel('Space [stixel]')
          ylabel('Time [frame]')
          colorbar horizontal
          title('Difference')

          fl_print = 1;
          if fl_print
             fn = sprintf('STA_cid%d',STAandROI.cell_id);
             orient landscape
             if k == 1
                eval(sprintf('print -dpsc2 %s/%s',d_save,fn))
             else
                eval(sprintf('print -dpsc2 -append %s/%s',d_save, fn))
             end
          else
             fprintf('check the figuer (not printing).\n')
             pause
          end
       end
       

    end
end
%}
