function [Hess_Correction] = glm_nonconvex_HessianCorrection(log_cif,spikebins,X_frame,frame_shifts,bins_per_frame, bin_duration)
%%% PURPOSE %%%
% Correction term in Hessian due to non-convex parameter use
% Do this in Frames

%%% INPUTS  %%%
% Log_Cif
% Spikebins
% X_frame
% frame_shifts
% bpf

%%% OUTPUTS %%%
% Hess_Correction


% AKHEITMAN 2014-12-15 
frames = size(X_frame,2);
pixels = size(X_frame,1);
frame_duration = bin_duration * bins_per_frame;
lags = length(frame_shifts);


% Put the CIF back to a frame timescale
cif = exp(log_cif);
cif_byframe_size = reshape(cif,[bins_per_frame,frames]);
cif_byframe      = mean(cif_byframe_size,1);
clear cif_byframe_size cif

spikeframes = ceil(spikebins/(bins_per_frame));
spiketime_vec = zeros(1,frames);
for i_spike = 1:length(spikeframes)
    index = spikeframes(i_spike);
    spiketime_vec(index) = spiketime_vec(index) + 1;
end

multiplier_vec_base = (spiketime_vec - frame_duration * cif_byframe);

%{

for i_frame = 1:size(X_frame,1)
    pixel_movie = 

X_frame;
B                       = repmat(spaceconvStim, [ bpf,1]); 
spaceconvStim_bin       = reshape(B, [1, bins]);    
bin_shifts              = bpf *frame_shifts;
temporal_covariatevec   = prep_timeshift(spaceconvStim_bin,bin_shifts);
%}

Hess0 = zeros(pixels,lags);
for i_pixel = 1:pixels
    pix_movie          = X_frame(i_pixel,:);
    pix_movie_withlags = prep_timeshift(pix_movie,frame_shifts);
    for i_lag = 1:lags
        convolved_score = sum( multiplier_vec_base.*pix_movie_withlags(i_lag,:) );
        Hess0(i_pixel,i_lag) = convolved_score;
    end
end
        


%{
% Shift the multiplier vec rather than go backwards in time
Hess0 = zeros( pixels , length(frame_shifts));
for i_lag = 1:length(frame_shifts)
    shift = frame_shifts(i_lag);
    multiplier_vec = circshift(multiplier_vec_base, shift);
    Hess0(:,i_lag) = X_frame * multiplier_vec;
end
%}    
    
% All computations have this extra multiplier due to fminunc
Hess_Correction = -Hess0;


end