function [uop_bps crm_bps pstar] = rastbps_comp_findPS(raster,t_bin,options)
% AKHEITMAN: not stnadalone!!  relies on create_histbasis from CHAITU folder
% Compute conditioned model (find Post spikefilter) and optimal rate model from raster
% Compute corresponding Bits Per Spike
%{
%%% PURPOSE %%%
% Compute a Conditioned Rate Model (CRM) from the raster and psfilter
% Compute the Uncoditioned Optimal Rate Model from raster alone
% Compute corresponding Bits_Per_Spike Code
%
%%% NOTES %%%
% Implement 10 msec guassian smoothing time for all spikes
% Uses post-spike filter generated previously (glm fits) as means for
% conditioning
% Fits run through GLM like fit procedure
% Base Model features only 3 free parameters
%
%%% INPUTS  %%%
% raster: rows are repitions, columns times, binary 0 1 for spike 
% t_bin: time duration of each bin in seconds
%
%%% OUTPUTS %%%
% uop_bps: Bits per Spike of the Unconditioned Optimal Model
% crm_bps: Bits per Spike of the Conditioned Rate Model
%
%%% OUTSIDE CALLS %%%
% NONE
%
%%% KEY MATLAB CALLS %%%
% fminunc
%
% AKHEITMAN 2015-03-02

%}

% AKHEITMAN 2015-03-01
% Version 0 Works in correcting aberrant WN vs NSEM comparison 
%          NOT standalone

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% TEST CODE %%%
%{
% INPUT
clear; clc
load rastbps_comp_test_1_1.mat
[uop_bps crm_bps pstar] = rastbps_comp_findPS(raster,t_bin);
display(sprintf('## uop_bps = %d; crm_bps = %d', uop_bps, crm_bps))
display(sprintf('## uop_bps_OLD COMPUTATION = %d; crm_bps_OLD COMPUTATION = %d', uop_bps_correct, crm_bps_correct))

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%
%display('Once Bertha UP run with 5 digit accuracy opt  (rather than current 3)')
%
%


% OPEN UP THE OPTIONS
if exist('options','var')
    if isfield(options, 'higher_order')
        higher_order = options.higher_order;
    end
end


%PICK PARAMETERS
reps = size(raster,1);
bins = size(raster,2);



% CONSTRUCT THE UOP BY SMOOTHING WITH 10 MSEC GAUSSIANS
binned_rate        = sum(raster,1);
sig_val            = 12; % 10 msecs
convolve_dur       = 10; %
convolve_index     = [-convolve_dur*sig_val:convolve_dur*sig_val];
convolve_vec       = normpdf(convolve_index,0,sig_val) / sum(normpdf(convolve_index,0,sig_val) );
prob_fulluop_bin   = sum(raster,1) / (size(raster,1));
convolved_raw      = conv(prob_fulluop_bin, convolve_vec);
fulluop_smooth     = convolved_raw( (convolve_dur*sig_val+1):(end-convolve_dur*sig_val));
uop                = fulluop_smooth;  
clear fulluop_smooth convovled_raw prob_fulluop_bin 
clear convolve_vec convolve_index sig_val binned_rate

rate_persec  = 1200*uop;
log_rate     = log(rate_persec);
COV_constant = repmat(ones(1,bins),[1, reps]);
COV_rate     = repmat(log_rate    ,[1, reps]);

if exist('higher_order') && higher_order == 2
    rate_p2 = rate_persec.*2;
    rate_n2 = rate_persec.*(1/2);
    
    rate_p3 = rate_persec.*3;
    rate_n3 = rate_persec.*(1/3);
    
    COV_rate_p2 = repmat(log(rate_p2) , [1, reps]);
    COV_rate_n2 = repmat(log(rate_n2) , [1, reps]);
    COV_rate_p3 = repmat(log(rate_p3) , [1, reps]);
    COV_rate_n3 = repmat(log(rate_n3) , [1, reps]);
    
    display('Running Higher Order expansion of the rate')
end


% HARD PS PARAMETERS  MATCHES GLMPARAMS
% WANT TO KEEP AS INDEPENDENT CODE AS POSSIBLE
ps_params.ms           = 100 ;     
ps_params.filternumber = 20;
ps_params.spacing      = pi/2;
ps_params.bstretch     = .05;
ps_params.alpha        = 0;
ps_params.fratio       = .5;  
ps_basis               = ps_basis_get(ps_params,t_bin);


% COVARIATES WHICH ARE REP DEPENDENT ( CONDITIONING TERMS )
%{
total_bins    = reps * bins;
concat_Spikes = NaN(1,total_bins); 
for i_rep = 1:reps
	index_start = (i_rep-1)*bins + 1;
	index_end   =  i_rep * bins;
    concat_Spikes(index_start:index_end) = raster(i_rep,:); 
end
home_spbins        = find(concat_Spikes);
[COV_PS]  = loc_convolvespike_basis(home_spbins,ps_basis',total_bins);
%}
PS_CONV = cell(reps,1);
for i_rep = 1:reps
    sp_bins         = find(raster(i_rep,:));
    PS_CONV{i_rep}  = loc_convolvespike_basis(sp_bins,ps_basis',bins);
end

total_bins    = reps * bins;
COV_PS        = NaN(ps_params.filternumber,total_bins);
concat_Spikes = NaN(1,total_bins); 
for i_rep = 1:reps
    index_start = (i_rep-1)*bins + 1;
	index_end   =  i_rep * bins;
    COV_PS(:,index_start:index_end) = PS_CONV{i_rep};
    concat_Spikes(index_start:index_end) = raster(i_rep,:);
end
home_spbins        = find(concat_Spikes);



COV         = [COV_constant ; COV_rate ; COV_PS]; 
p_init      = [0 1 zeros(1,20)]';


if exist('higher_order') && higher_order == 2
    COV = [COV_constant ; COV_rate ; COV_rate_p2; COV_rate_n2; COV_rate_p3; COV_rate_n3; COV_PS]; 
    p_init      = [0 1 0 0 0 0 zeros(1,20)]';
end





COV(find(COV<= -36)) = -(10^15);



optim_struct = optimset(...
'derivativecheck','off',...
'diagnostics','off',...  % 
'display','iter',...  %'iter-detailed',... 
'funvalcheck','off',... % don't turn this on for 'raw' condition (edoi).
'GradObj','on',...
'largescale','on',...
'Hessian','on',...
'MaxIter',100,... % you may want to change this
'TolFun',10^(-(3)),...
'TolX',10^(-(9))   );

[pstar fstar eflag output] = fminunc(@(p) rastbps_comp_glm_convexopt(p,COV,home_spbins,t_bin),p_init,optim_struct);
lcif            = pstar' * COV;
crm_ratepersec_concat  = exp(lcif);
crm_ratepersec         = NaN(reps,bins);
for i_rep = 1:reps
	index_start = (i_rep-1)*bins + 1;
	index_end   =  i_rep * bins;
	crm_ratepersec(i_rep,:) = crm_ratepersec_concat(index_start:index_end);
end

crm_rateperbin = t_bin*crm_ratepersec;
crm_model      = crm_rateperbin;
uop_model      = repmat(uop,[reps,1]);
null_model     = repmat( (1/(reps*bins)*sum(raster(:)))*ones(1,bins) , [reps,1]);

crm_logprob          = sum(rastbps_comp_logprob( raster, crm_model,  'binary')) ;
uop_logprob          = sum(rastbps_comp_logprob( raster, uop_model,  'binary')) ;
null_logprob         = sum(rastbps_comp_logprob( raster, null_model,  'binary')) ;

uop_bits = uop_logprob - null_logprob;
uop_bps  = uop_bits / (sum(null_model(1,:)));

crm_bits = crm_logprob - null_logprob;
crm_bps  = crm_bits / (sum(null_model(1,:)));

figure(1); plot( ps_basis * (pstar( (end-20+1):end)));

end


function  [f grad Hess log_cif]  = rastbps_comp_glm_convexopt(linear_params,covariates,spikebins,bin_duration)
% Brought local copy of optimization function to keep the code stand alone
%
%%%%%%%%% PURPOSE %%%%%%%
% Compute the Objective Function being optimized (f)
% Compute the grad/hess as well for the optimizer
% Monotonically related to  negative of log_cif
% log_cif:= log of the conditional intensity function


%%% NOTES %%%%
% Row indexes the parameters and corresponding covariate
% Column indexes time

%%% INPUTS  %%%
% Params: glm parameters to be optimized, column vector
% Covariates: time dependent input with multiplies into the params
% SpikeBins: spike time in bins of cell
% Bin_Duration: duration of each bin in seconds 
% AKHEITMAN 2014-12-04

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize
p = linear_params;
COV = covariates;
dt = bin_duration;
spt = spikebins;


% Find Conditional Intensity and its log
lcif = p' * COV;
cif  = exp(lcif);


% Evaluate the objective function (monotonic in log-likelihood)
f_eval = sum( lcif(spt) ) - dt * sum(cif);

% Evaluate the gradient
g_eval = sum(COV(:,spt),2)  - dt * ( COV * (cif') );

% Evaluate the hessian
hessbase = zeros(size(COV));
for i_vec = 1:size(COV,1)
    hessbase(i_vec,:) = sqrt(cif) .* COV(i_vec,:) ;
end
H_eval = -dt * (hessbase * hessbase');


% Switch signs because using a minimizer  fmin
f       = -f_eval;
grad    = -g_eval;
Hess    = -H_eval;
log_cif = lcif;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ raster_logprob_bin, logprobmat] = rastbps_comp_logprob( spikemat, ratemodel, spikemat_type) 
% Brought local copy of optimization function to keep the code stand alone
% 
%%% PURPOSE %%%
% Compute Likelihood of Spike Raster (usa binary)
% Model is a binned rate model

%%% NOTES %%%%
% Row Indexes the repitition
% Column indexes time


trials = size(spikemat,1);
bins   = size(spikemat,2);

if strcmp(spikemat_type, 'binary')
    % EVALUATE MODEL LIKELIHOOD OF SPIKE AND NO SPIKES
    P_nospike = exp(-ratemodel);
    P_spike   = ratemodel.*P_nospike;
    
    % FIND SPIKES
    spindex   = find(spikemat);
    
    % EVALUATE PROBABLITY OF SPIKEMAT GIVEN MODEL
    probmat             = P_nospike;
    probmat(spindex)    = P_spike(spindex); 
    logprobmat          = log(probmat);
    raster_logprob_bin  = mean(logprobmat,1);
end

end

function basis_vectors = ps_basis_get(basis_params,bin_size)
% MY_FUNCTION     This finds all the params associated with the 2 filters.
%                 Whcih were not specified in   
%   Calls create_histbasis  (should be renamed create_psbasis)
%
%                                           'bore' - activate remotely
%  NOT A VERY GNERAL FUNCTION
%
% Works as of 
%



% Done in an microbin that's been adjusted for with the ps_fratio factor
%ps_f ration mean spost spike filter to linear filter ratio!!!
%init_pars.ps_timebins = floor((init_pars.spikebins_perstimframe*init_pars.k_stimframes)*init_pars.ps_fratio); % on fine timescale ~ 6/factor m(s)^-1

dt = bin_size;
 
basis_params.timebins  = floor( (basis_params.ms/1000) / dt );
basis_params.beta    = (basis_params.timebins-1)*dt; % ending point for ps filters
% History filters (postspike and coupling)
bstretch = basis_params.bstretch;
alpha_ps = basis_params.alpha;
beta_ps  = basis_params.beta;
if (basis_params.filternumber > 0)
   basis_vectors = create_histbasis(alpha_ps,beta_ps,bstretch,...
      basis_params.filternumber,basis_params.timebins,dt,'L2',basis_params.spacing);
else
   basis_params.basis = [];
end
end


function [spikesconvbasis]  = loc_convolvespike_basis(binned_spikes,basis,bins)
% AKHeitman 2014-05-04
% Parameter independent!
% basis should be a vector of [basis vectors , bins] already binned
% t_bin is used to put spike times into their appropriate bin 
% t_bin is duration of each bin in msecs
% bins  is the maximum bin number


vectors = size(basis,1); vectorbins= size(basis,2);
%offset by 1,  so PS filter starts in the next bin!!! 
binned_spikes = binned_spikes(find(binned_spikes < bins) ) + 1;


convolvedspikes_base                  = zeros(1,bins);
convolvedspikes_base(binned_spikes+1) = 1; 

convolvedspikes = zeros(vectors, bins + vectorbins - 1);
for i_vec = 1:vectors
    convolvedspikes(i_vec, :) = conv(convolvedspikes_base, basis(i_vec,:), 'full');
end
convolvedspikes = convolvedspikes(:, 1:bins);    

spikesconvbasis = convolvedspikes;
end






    

