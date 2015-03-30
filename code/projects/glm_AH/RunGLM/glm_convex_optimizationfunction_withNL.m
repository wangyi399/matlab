% AKHEITMAN 2014-06-24


% Computes the objetive function being sought (monotonic to -logprob)
% function, gradiant, Hessian, log_cif (conditional intensity)
% COV_NL modified covariates

% Post Filter Non-Linearities
% Must be imbedded within the GLM optimization

% COmpare to glm_convex_optimizationfunction


% HEAVILY MODIFIED 
% 2014-12-17

% 2015-01-18
% Take into account Grad/Hess are also modulated by Nonlinearities
% Adopt lcif_derivative_preNL nomenclature
% Recommented and Edited to match others 2015-01-18  WORKS!
function  [f grad Hess log_cif COV_NL]= glm_convex_optimizationfunction_withNL(linear_params,covariates,spikebins,bin_duration, nonlinearity)

% INITIALIZE TERMS
p   = linear_params;
COV = covariates;
dt  = bin_duration;
spt = spikebins;

% NONLINEARITY INDUCES CHANGE IN THE LCIF_DERIVATIVE
% IF CONVEX AND LINEAR COV = LCIF_DERIVATIVE
lcif_derivative_preNL = COV;

% COMPUTE LINEAR COMPONENTS OF THE LCIF
lin_index    = nonlinearity.linear_index;
lin_part     = (p(lin_index)') * COV(lin_index,:);



%% ADJUST FOR NON-LINEARITY -- LCIF COMPONENT and LCIF_DERIVATIVE
% Properly adjust the non-linearity
if strcmp(nonlinearity.type, 'piece_linear_aboutmean')
    error('need to modify 2015-01-18  get lcif_derivative_NL')
    nonlin_part0 = (p(nonlinearity.filter_index)') * COV(nonlinearity.filter_index,:);
    
    par = nonlinearity.increment_to_decrement;
    pos_mult  = (2*par) / (par + 1) ;
    neg_mult  =      2  / (par + 1) ;        
    pos_ind = find(nonlin_part0>0);
    neg_ind = find(nonlin_part0<=0);
    
    nonlin_part = nonlin_part0;
    nonlin_part(pos_ind) = pos_mult * (nonlin_part(pos_ind)); 
    nonlin_part(neg_ind) = neg_mult * (nonlin_part(neg_ind));
end
if strcmp(nonlinearity.type, 'oddfunc_powerraise_aboutmean')
    error('need to modify 2015-01-18  get lcif_derivative_NL')
    nonlin_part0 = (p(nonlinearity.filter_index)') * COV(nonlinearity.filter_index,:);
    nonlin_part = nonlin_part0;
        error('nned to account for changes in the gradient')
    par = nonlinearity.scalar_raisedpower;
    pos_mult  = (2*par) / (par + 1) ;
    neg_mult  =      2  / (par + 1) ;        
    pos_ind = find(nonlin_part0>0);
    neg_ind = find(nonlin_part0<=0);
    
    nonlin_part(pos_ind) =  (     (nonlin_part(pos_ind))  .*par );
    nonlin_part(neg_ind) = -( (abs(nonlin_part(neg_ind))) .*par );    
end

if strcmp(nonlinearity.type, 'ConductanceBased_HardRect')
    % COMPUTE THE NONLINEAR COMPONENT OF LCIF
    excitatory_part = (p(nonlinearity.excitatoryfilter_index)') * COV(nonlinearity.excitatoryfilter_index,:);    
    negative_ind    = find(excitatory_part< 0);
    excitatory_part(negative_ind) = 0;
    
    inhibitory_part   = (p(nonlinearity.inhibitoryfilter_index)') * COV(nonlinearity.inhibitoryfilter_index,:);
    positive_ind      = find(inhibitory_part> 0);
    inhibitory_part(positive_ind) = 0;
    
    nonlin_part = excitatory_part + inhibitory_part;
    
    % FIND THE DERIVATIVE OF THE NON-LINEARITY
    excitatory_deriv               = ones(1,size(COV,2));
    excitatory_deriv(negative_ind) = 0;
    inhibitory_deriv               = ones(1,size(COV,2));
    inhibitory_deriv(positive_ind) = 0;
    

    
    % INCORPORATE NL DERIVATIVE INTO THE TOTAL LCIF_DERIVATIVE
    lcif_derivative_NL = lcif_derivative_preNL;
    for i_ind = nonlinearity.excitatoryfilter_index
        lcif_derivative_NL(i_ind,:) = lcif_derivative_preNL(i_ind,:) .* excitatory_deriv;
    end
    for i_ind = nonlinearity.inhibitoryfilter_index
        lcif_derivative_NL(i_ind,:) = lcif_derivative_preNL(i_ind,:) .* inhibitory_deriv;
    end
%{
    clf;
    subplot(2,2,1); plot(excitatory_part(1:3000));
    subplot(2,2,3); plot(excitatory_deriv(1:3000)); ylim([-.5,1.5]);
    subplot(2,2,2); plot(inhibitory_part(1:3000),'r');
    subplot(2,2,4); plot(inhibitory_deriv(1:3000),'r');ylim([-.5,1.5]); 
%}
   
end
%%

% CONDITIONAL INTENSITY FUNCTIONS
lcif = lin_part + nonlin_part;
cif  = exp(lcif);


% THE OBJECTIVE FUNCTION (MONOTONIC IN LOG-LIKELIHOOD)
f_eval = sum( lcif(spt) ) - dt * sum(cif);

% GRADIENT FORMULA WITH NONLINEARITY MODIFICATION TO LCIF_DERIVATIVE
g_eval = sum(lcif_derivative_NL(:,spt),2)  - dt * ( lcif_derivative_NL * (cif') );

% HESSIAN FORMULA WITH NONLINEARITY MODIFICATION TO LCIF_DERIVATIVE
hessbase = zeros(size(lcif_derivative_NL));
for i_vec = 1:size(lcif_derivative_NL,1)
    hessbase(i_vec,:) = sqrt(cif) .* lcif_derivative_NL(i_vec,:) ;
end
H_eval = -dt * (hessbase * hessbase');


% SWITCH SIGNS (TURN MAX TO MIN SO WE CAN USE FMINUNC OF MATLAB)
f            = -f_eval;
grad         = -g_eval;
Hess         = -H_eval;
log_cif      = lcif;

end