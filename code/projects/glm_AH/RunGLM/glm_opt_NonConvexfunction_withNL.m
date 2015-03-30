% AKHEITMAN 2014-06-24


% Computes the objetive function being sought (monotonic to -logprob)
% function, gradiant, Hessian, log_cif (conditional intensity)
% COV_NL modified covariates

% Post Filter Non-Linearities
% Must be imbedded within the GLM optimization

% COmpare to glm_convex_optimizationfunction


% Created 2015-01-18 
% Handles both Non-Convexity and Non-Linearity!
% Incorporated into Versions 3_0 and 3_1
function  [f grad Hess log_cif]= glm_opt_NonConvexfunction_withNL(linear_params,covariates,lcif_derivative_preNL,spikebins,bin_duration,X_frame,frame_shifts,bins_per_frame,paramind,nonlinearity)

% ASSIGN VARIABLES
p   = linear_params;
COV = covariates;
dt  = bin_duration;
spt = spikebins;



%% COMPUTE NONLINEARITY LCIF and the NL multiplier to  LCIF_DERIV HERE
if strcmp(nonlinearity.type, 'ConductanceBased_HardRect')
    % COMPUTE THE NONLINEAR COMPONENT OF LCIF
    excitatory_part = (p(nonlinearity.excitatoryfilter_index)') * COV(nonlinearity.excitatoryfilter_index,:);    
    negative_ind    = find(excitatory_part< 0);
    excitatory_part(negative_ind) = 0;
    inhibitory_part   = (p(nonlinearity.inhibitoryfilter_index)') * COV(nonlinearity.inhibitoryfilter_index,:);
    positive_ind      = find(inhibitory_part> 0);
    inhibitory_part(positive_ind) = 0;
    
    lcif_comp.nonlin_part = excitatory_part + inhibitory_part;
    
    % FIND THE DERIVATIVE OF THE NON-LINEARITY
    excitatory_deriv               = ones(1,size(COV,2));
    excitatory_deriv(negative_ind) = 0;
    inhibitory_deriv               = ones(1,size(COV,2));
    inhibitory_deriv(positive_ind) = 0;
    
    % INCORPORATE NL DERIVATIVE INTO THE TOTAL LCIF_DERIVATIVE
    % KEY CHANGE IN VERSION 3-1 FROM VERSION 3-0
    lcif_derivative = lcif_derivative_preNL;
    for i_ind = nonlinearity.excitatoryfilter_index
        lcif_derivative(i_ind,:) = lcif_derivative_preNL(i_ind,:) .* excitatory_deriv;
    end
    for i_ind = nonlinearity.inhibitoryfilter_index
        lcif_derivative(i_ind,:) = lcif_derivative_preNL(i_ind,:) .* inhibitory_deriv;
    end
    
    % DEBUGGING PLOTS
    %{
    clf;
    subplot(2,2,1); plot(excitatory_part(1:3000));
    subplot(2,2,3); plot(excitatory_deriv(1:3000)); ylim([-.5,1.5]);
    subplot(2,2,2); plot(inhibitory_part(1:3000),'r');
    subplot(2,2,4); plot(inhibitory_deriv(1:3000),'r');ylim([-.5,1.5]);
    %}    
end
%% Complete Classic Computations

% FIND CIF AND LCIF
lcif_comp.lin_part = (p(nonlinearity.linear_index)') * COV(nonlinearity.linear_index,:);
lcif =  lcif_comp.lin_part  + lcif_comp.nonlin_part;
cif  = exp(lcif);

% EVALUATE FUNCTION
f_eval = sum( lcif(spt) ) - dt * sum(cif);

% EVALUATE GRADIENT
g_eval = sum(lcif_derivative(:,spt),2)  - dt * ( lcif_derivative * (cif') );

% EVALUTE HESSIAN BASE 
hessbase = zeros(size(lcif_derivative));
for i_vec = 1:size(lcif_derivative,1)
    hessbase(i_vec,:) = sqrt(cif) .* lcif_derivative(i_vec,:) ;
end
H_eval_base = -dt * (hessbase * hessbase');


%% Hess Correction 
% Done on Frame Time Scale to Save Time

% 
frames = size(X_frame,2);
pixels = size(X_frame,1);
frame_duration = bin_duration * bins_per_frame;
lags = length(frame_shifts);


cif_byframe_size = reshape(cif,[bins_per_frame,frames]);
cif_byframe      = mean(cif_byframe_size,1);


spikeframes = ceil(spikebins/(bins_per_frame));
spiketime_vec = zeros(1,frames);
for i_spike = 1:length(spikeframes)
    index = spikeframes(i_spike);
    spiketime_vec(index) = spiketime_vec(index) + 1;
end
multiplier_vec_base = (spiketime_vec - frame_duration * cif_byframe);


if strcmp(nonlinearity.type, 'ConductanceBased_HardRect')
    excitatory_base = mean(reshape(excitatory_deriv,[bins_per_frame,frames]),1);
    inhibitory_base = mean(reshape(inhibitory_deriv,[bins_per_frame,frames]),1);
    
    excitatory_multiplier = multiplier_vec_base.*excitatory_base;
    inhibitory_multiplier = multiplier_vec_base.*inhibitory_base;

    HessCorrect_Excit = zeros(pixels,lags);
    HessCorrect_Inhib = zeros(pixels,lags);
    for i_pixel = 1:pixels
        pix_movie          = X_frame(i_pixel,:);
        pix_movie_withlags = prep_timeshift(pix_movie,frame_shifts);
        for i_lag = 1:lags
            e_convolved_score = sum( excitatory_multiplier.*pix_movie_withlags(i_lag,:) );
            HessCorrect_Excit(i_pixel,i_lag) = e_convolved_score;
            
            i_convolved_score = sum( inhibitory_multiplier.*pix_movie_withlags(i_lag,:) );
            HessCorrect_Inhib(i_pixel,i_lag) = i_convolved_score;
        end

    end
    
    H_eval = H_eval_base;
    H_eval(paramind.space1,paramind.time1 ) = H_eval(paramind.space1,paramind.time1 ) + HessCorrect_Excit ;
    H_eval(paramind.time1 ,paramind.space1) = H_eval(paramind.time1 ,paramind.space1) + HessCorrect_Excit';
    H_eval(paramind.space2,paramind.time2 ) = H_eval(paramind.space2,paramind.time2 ) + HessCorrect_Inhib ;
    H_eval(paramind.time2 ,paramind.space2) = H_eval(paramind.time2 ,paramind.space2) + HessCorrect_Inhib';
end



%% Final Assigment
% Switch signs because using a minimizer  fmin
f       = -f_eval;
grad    = -g_eval;
Hess    = -H_eval;
log_cif = lcif;


end