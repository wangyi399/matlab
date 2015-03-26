function [vksp_mean , vksp_std] = eval_xvalperformance_ViktorDistperSpike(rastRec,rastSim,t_bin,t_cost)

% AKHeitman 2014-11-24
% rastRec is a binary binned matrix of spikes recorded
% rastSim is the corresponding simulation designed to immitate
% t_bin is the size of each bin in the raster in seconds
% t_cost is the duration which will count for a unit of Viktor Spike

if (size(rastRec,1) ~= size(rastSim,1)) || (size(rastRec,2) ~= size(rastSim,2))
    error('rasters need to be of the same size!')
end
reps           = size(rastRec,1);
spikespertrial = length(find(rastRec(:)) == 1) / reps ;  

distances   = zeros(1,reps);

for i_row = 1:reps
    spt_1       = t_bin * find(rastRec(i_row,:));
    spt_2       = t_bin * find(rastSim(i_row,:));
    
    
    if length(spt_2) > 2 * spikespertrial
        distances(i_row) = spikespertrial + length(spt_2);
    else
        distances(i_row) = spkd(spt_1, spt_2, (1/t_cost) );
    end
end

dist_perspike = distances / spikespertrial;

vksp_mean = mean(dist_perspike);
vksp_std  = std(dist_perspike);

end