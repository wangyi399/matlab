% hack XV means cross validation
% here we use inputstats in our evaluation.. will work better for
% non-linearities  and NSEM 

% AKHeitman 2014-04-27
% GLMPars = GLMParams  or GLMPars = GLMParams(GLMType.specialchange_name)
% Sensitive to naming changes in GLMParams.
% Lon function call is   "spatialfilterfromSTA"
% Only saves stuff (and calls directories) if we are in a troubleshooting mode
% Heavily GLMType dependent computations will be carried out here
% Outsourcable computations will be made into their own functions
%troubleshoot optional
% need troublshoot.doit (true or false), 
%troubleshoot.plotdir,
% troubleshoot.name
function [X_frame,X_bin] = prep_stimcelldependentGPXV(GLMType, GLMPars, stimulus, inputstats, center_coord,STA,troubleshoot)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load up GLMParams
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cut the Movie down to ROI
% Normalize Movie and set nullpoint
% output of this section is stim
% stim in [xy, time] coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROI_length      = GLMPars.stimfilter.ROI_length;
stimsize.width  = size(stimulus,1);
stimsize.height = size(stimulus,2);
stimsize.frames = size(stimulus,3);
ROIcoord        = ROI_coord(ROI_length, center_coord, stimsize);
stim            = stimulus(ROIcoord.xvals, ROIcoord.yvals, :);


fitmoviestats.mean     =  inputstats.mu_avgIperpix;
fitmoviestats.span     =  inputstats.range;
fitmoviestats.normmean =  inputstats.mu_avgIperpix / inputstats.range;

stim   = double(stim);
stim   = stim / fitmoviestats.span;

if strcmp(GLMType.nullpoint, 'mean')
    stim = stim - fitmoviestats.normmean;
else
    error('you need to fill in how to account for stimulus with a different nullpoint')
end




if isfield(GLMType, 'input_pt_nonlinearity') && GLMType.input_pt_nonlinearity
   % display('implementing nonlinearity')
    newstim = stim;
    if strcmp(GLMType.input_pt_nonlinearity_type, 'piece_linear_aboutmean')
        par       = GLMPars.others.point_nonlinearity.increment_to_decrement;
        pos_mult  = (2*par) / (par + 1) ;
        neg_mult  =      2  / (par + 1) ;
        
        pos_stim          = find(stim > 0 );
        neg_stim          = find(stim < 0 );
        
        newstim(pos_stim) = pos_mult * (newstim(pos_stim)); 
        newstim(neg_stim) = neg_mult * (newstim(neg_stim));
    
    elseif strcmp(GLMType.input_pt_nonlinearity_type, 'piece_linear_shiftmean')
        par = GLMPars.others.point_nonlinearity.increment_to_decrement;
        par_shift = GLMPars.others.point_nonlinearity.shiftmean; 

        pos_mult  = (2*par) / (par + 1) ;
        neg_mult  =      2  / (par + 1) ;
        
        pos_stim          = find(stim > par_shift);
        neg_stim          = find(stim < par_shift);
        
        newstim(pos_stim) = pos_mult * (newstim(pos_stim)-par_shift) + par_shift; 
        newstim(neg_stim) = neg_mult * (newstim(neg_stim)-par_shift) + par_shift;
        
    elseif strcmp(GLMType.input_pt_nonlinearity_type, 'raisepower_meanafter')
        %{
        newstim = newstim - min(newstim(:));
        newstim = newstim / max(newstim(:));  % back to a 0 1 scale
        
        newstim = newstim .^ (GLMPars.others.point_nonlinearity.scalar_raisedpower);
        newstim = newstim - min(newstim(:));
        newstim = newstim / max(newstim(:));
        newstim = newstim - mean(newstim(:));
        %}
        
        newstim = newstim + fitmoviestats.normmean;  % 0 1
        newstim = newstim .^ (GLMPars.others.point_nonlinearity.scalar_raisedpower);
        newstim = newstim - min(newstim(:));
        newstim = newstim / max(newstim(:));
        newstim = newstim - mean(newstim(:));
        
    
    elseif strcmp(GLMType.input_pt_nonlinearity_type, 'oddfunc_powerraise_aboutmean')
        par               = GLMPars.others.point_nonlinearity.scalar_raisedpower_aboutmean;
        
        pos_stim          = find(stim > 0 );
        neg_stim          = find(stim < 0 );
        
        newstim(pos_stim) =  (     (newstim(pos_stim))  .*par );
        newstim(neg_stim) = -( (abs(newstim(neg_stim))) .*par );
        
    elseif strcmp(GLMType.input_pt_nonlinearity_type, 'log')
        display('implenting log')
        newstim = stim + fitmoviestats.normmean + 1; % now back on 0 1 scale
        newstim = log(newstim);
        newstim = newstim - log(fitmoviestats.normmean+1);
    elseif strcmp(GLMType.input_pt_nonlinearity_type, 'exp')
        display('implenting exp')
        newstim = stim + fitmoviestats.normmean; % now back on 0 1 scale
        newstim = exp(newstim);
        newstim = newstim - exp(fitmoviestats.normmean); 
        
        
    elseif strcmp(GLMType.input_pt_nonlinearity_type, 'polynomial_androot_order2')
    
        newstim = stim + fitmoviestats.normmean;  % now back on 0 1 scale 
        linear_term    = newstim;
        quadratic_term = newstim.^2;
        sqroot_term    = newstim.^(.5);
        coeff = GLMPars.others.point_nonlinearity.coefficients;
        newstim = coeff.linear * linear_term + coeff.quadratic * quadratic_term + coeff.sqroot*sqroot_term ; 
        
        a     = fitmoviestats.normmean;
        a_map = coeff.linear * a + coeff.quadratic * a^2 + coeff.sqroot * a^.5;
        
        newstim = newstim - a_map;
        
    elseif strcmp(GLMType.input_pt_nonlinearity_type, 'polynomial_androot_order2_search2')
    
        newstim = stim + fitmoviestats.normmean;  % now back on 0 1 scale 
        linear_term    = newstim;
        quadratic_term = newstim.^2;
        sqroot_term    = newstim.^(.5);
        coeff = GLMPars.others.point_nonlinearity.coefficients;
        
        linearcoeff = coeff.linear;
        quadcoeff   = (1-coeff.linear)* coeff.quadoversqroot;
        sqrootcoeff = (1-coeff.linear)*(1-coeff.quadoversqroot);
        
        
        newstim = linearcoeff * linear_term + quadcoeff * quadratic_term + sqrootcoeff*sqroot_term ; 
        
        a     = fitmoviestats.normmean;
        a_map = linearcoeff * a + quadcoeff * a^2 + sqrootcoeff * a^.5;
        
        newstim = newstim - a_map;
	elseif strcmp(GLMType.input_pt_nonlinearity_type, 'polynomial_androot_order2_search3')
    
        newstim = stim + fitmoviestats.normmean;  % now back on 0 1 scale 
        linear_term    = newstim;
        quadratic_term = newstim.^2;
        sqroot_term    = newstim.^(.5);
        coeff = GLMPars.others.point_nonlinearity.coefficients;
        
        lin0    = coeff.linear; quad0 = coeff.quadratic; sqroot0 = coeff.sqroot;
        lin     = lin0    / (lin0 + quad0 + sqroot0);
        quad    = quad0   / (lin0 + quad0 + sqroot0);
        sqroot  = sqroot0 / (lin0 + quad0 + sqroot0);
        newstim = lin * linear_term + quad * quadratic_term + sqroot * sqroot_term ; 
        
        a     = fitmoviestats.normmean;
        a_map = coeff.linear * a + coeff.quadratic * a^2 + coeff.sqroot * a^.5;
        
        newstim = newstim - a_map;
    
    elseif strcmp(GLMType.input_pt_nonlinearity_type, 'polynomial_order3_part5')
    
        newstim = stim + fitmoviestats.normmean;  % now back on 0 1 scale 
        linear_term     = newstim;
        quadratic_term  = newstim.^2;
        sqroot_term     = newstim.^(1/2);
        thirdpower_term = newstim.^3;
        thirdroot_term  = newstim.^(1/3);
        
        coeff = GLMPars.others.point_nonlinearity.coefficients;
        
        lin     = coeff.linear; quad = coeff.quadratic; sqroot = coeff.sqroot;
        thirdpower = coeff.thirdpower;  thirdroot = coeff.thirdroot;
   
        newstim = lin * linear_term + quad * quadratic_term + sqroot * sqroot_term +...
            thirdpower * thirdpower_term + thirdroot * thirdroot_term; 
        
        a     = fitmoviestats.normmean;
        a_map = lin * a + quad * a^2 + sqroot * a^(.5) +...
            thirdpower * a^3 + thirdroot * a^(1/3); 
        
        newstim = newstim - a_map;

    elseif strcmp(GLMType.input_pt_nonlinearity_type, 'polynomial_order5_part4')
    
        newstim = stim + fitmoviestats.normmean;  % now back on 0 1 scale 
        linear_term     = newstim;
        quadratic_term  = newstim.^2;
        sqroot_term     = newstim.^(1/2);
        thirdpower_term = newstim.^3;
        thirdroot_term  = newstim.^(1/3);
        fourthpower_term = newstim.^4;
        fourthroot_term  = newstim.^(1/4);
        fifthpower_term = newstim.^5;
        fifthroot_term  = newstim.^(1/5);
        
        coeff = GLMPars.others.point_nonlinearity.coefficients;
        
        lin     = coeff.linear; 
        quad = coeff.quadratic; sqroot = coeff.sqroot;
        thirdpower = coeff.thirdpower;  thirdroot = coeff.thirdroot;
        fourthpower = coeff.fourthpower;  fourthroot = coeff.fourthroot;
        fifthpower = coeff.fifthpower;  fifthroot = coeff.fifthroot;
    
        newstim = lin * linear_term + ...
            quad * quadratic_term + sqroot * sqroot_term +...
            thirdpower * thirdpower_term + thirdroot * thirdroot_term + ...
            fourthpower * fourthpower_term + fourthroot * fourthroot_term + ...
            fifthpower * fifthpower_term + fifthroot * fifthroot_term; 
        
        a     = fitmoviestats.normmean;
        a_map = lin * a + quad * a^2 + sqroot * a^(.5) +...
            thirdpower * a^3 + thirdroot * a^(1/3) + fourthpower*a^4 + fourthroot*a^(1/4) + ...
            fifthpower * a^5 + fifthroot * a^(1/5);
        
        newstim = newstim - a_map;
    elseif strcmp(GLMType.input_pt_nonlinearity_type,'piecelinear_fourpiece_eightlevels')
        newstim = stim + fitmoviestats.normmean;
        
        quartile_1 = find(newstim<=.25);
        quartile_2 = setdiff(find(newstim<=.5),quartile_1);
        
        quartile_4 = find(newstim>.75);
        quartile_3 = setdiff(find(newstim >.5),quartile_4);
        
        
        coeff = GLMPars.others.point_nonlinearity.coefficients;
        slope1 = coeff.slope_quartile_1;
        slope2 = coeff.slope_quartile_2;
        slope3 = coeff.slope_quartile_3;
        slope4 = coeff.slope_quartile_4;
        
        offset1 = 0;
        offset2 = .25* slope1;
        offset3 = .25*(slope1+slope2);
        offset4 = .25*(slope1+slope2+slope3);
        
        newstim(quartile_1) = slope1 * (newstim(quartile_1) - .00) + offset1;
        newstim(quartile_2) = slope2 * (newstim(quartile_2) - .25) + offset2;
        newstim(quartile_3) = slope3 * (newstim(quartile_3) - .50) + offset3;
        newstim(quartile_4) = slope4 * (newstim(quartile_4) - .75) + offset4;
        
        newstim = newstim - offset2;
    else
        display('error, need to properly specifiy input non-linearity')
    end
    stim = newstim; clear newstim
end


if exist('troubleshoot','var') && troubleshoot.doit
    clf
    totalframes = stimsize.frames;
    frames = min(1000, totalframes);
    stimulus2   = stimulus(:,:,1:frames);
    stim2       = stim(:,:,1:frames);
    subplot(3,2,[3 5]); hist(double(stimulus2(:)),20); set(gca, 'fontsize', 10); title('histogram of full raw stim')
    subplot(3,2,[4 6]); hist(           stim2(:) ,20); set(gca, 'fontsize', 10); title('histogram of normed stim over ROI') 
    subplot(3,2,[1 2]);   set(gca, 'fontsize', 10); axis off
    c = 0;
    c=c+1; text(-.1, 1-0.1*c,sprintf('Trouble shooting: %s',troubleshoot.name));
    c=c+1; text(-.1, 1-0.1*c,sprintf('Specifically: Stimulus Normalizing Component of "glm-nospace"' ));
    c=c+1; text(-.1, 1-0.1*c,sprintf('Plot Date %s',datestr(clock)));
    c=c+1; text(-.1, 1-0.1*c,sprintf('Mfile: %s', mfilename('fullpath')) );
    
    orient landscape
    eval(sprintf('print -dpdf %s/%s_prepstimcellGP_stimnorm.pdf', troubleshoot.plotdir, troubleshoot.name));
end 
%}
stim = reshape(stim, [ROI_length^2 , stimsize.frames]);

clear stimsize ROIcoord ROI_length fitmoviestats 

%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create spfilter from the STA 
% output: spfilter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(GLMType.stimfilter_mode, 'fixedSP_rk1_linear') || strcmp(GLMType.stimfilter_mode, 'fixedSP-ConductanceBased')
    ROI_length      = GLMPars.stimfilter.ROI_length;
    stimsize.width  = size(stimulus,1);
    stimsize.height = size(stimulus,2); 
    ROIcoord        = ROI_coord(ROI_length, center_coord, stimsize);
    spfilter = spatialfilterfromSTA(STA,ROIcoord.xvals,ROIcoord.yvals);
    if exist('troubleshoot','var') && troubleshoot.doit
        clf
        subplot(3,2,[1 2]);   set(gca, 'fontsize', 10); axis off
        c = 0;
        c=c+1; text(-.1, 1-0.1*c,sprintf('Trouble shooting: %s',troubleshoot.name));
        c=c+1; text(-.1, 1-0.1*c,sprintf('Specifically: spfilter from WN-STA "glm-nospace/spatialfilterfromSTA"' ));
        c=c+1; text(-.1, 1-0.1*c,sprintf('Plot Date %s',datestr(clock)));
        c=c+1; text(-.1, 1-0.1*c,sprintf('Mfile: %s', mfilename('fullpath')) );


        subplot(3,2,[3 5]);  set(gca, 'fontsize', 10); imagesc(reshape(spfilter,[ROI_length, ROI_length])); colorbar
        xlabel('pixels'); ylabel('pixels');
        title('Spatial Filter first rank of the STA');

        subplot(3,2,[4 6]); set(gca, 'fontsize', 10);   imagesc( (squeeze(mean(STA,1))' )); colorbar
        ylabel('frames');  xlabel('pixel rows')
        title('Raw STA, columns collapsed to 1-spatial dimension');


        orient landscape
        eval(sprintf('print -dpdf %s/%s_prepstimcellGP_spfilterfromSTA.pdf', troubleshoot.plotdir, troubleshoot.name));
    end 
    spfilter  = spfilter';  % dimension [1,ROI_length]
end

clear stimsize ROIcoord ROI_length fitmoviestats 

%%
%%%%%%%%%%%%%%%%%%%%%%%
% Creat the final stim dependent input (X) to the optimization algorithm
% X_bin  ([rank, bins])
%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(GLMType.stimfilter_mode, 'fixedSP_rk1_linear') || strcmp(GLMType.stimfilter_mode, 'fixedSP-ConductanceBased')
    if strcmp(GLMPars.stimfilter.fixedSP_type, 'WNSTA')
        X_frame = (spfilter) * stim;
    end
elseif strcmp(GLMType.stimfilter_mode, 'rk1') || strcmp(GLMType.stimfilter_mode, 'rk2') || ...
        strcmp(GLMType.stimfilter_mode, 'rk2-ConductanceBased')||strcmp(GLMType.stimfilter_mode, 'rk1-newfit')||strcmp(GLMType.stimfilter_mode, 'fullrank')
    X_frame = stim;
else
    error('you need to tell prep_stimcelldependentGP how to process stim for your spatial filter')
end

frames = size(X_frame,2);
dim    = size(X_frame,1);

bpf    = GLMPars.bins_per_frame;
bins   = bpf * frames;
X_bin  = repmat(X_frame, [ bpf,1]); 
X_bin  = reshape(X_bin, [dim, bins]);

clear frames bpf bins 


end