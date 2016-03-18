function [added_cones,first_dll,W,kernel_norms,num_kern_y,num_kern_x] = bayesian_cone_finding(bcf_params,...
    roi_x,roi_y,W,kernel_norms, cell_constants, stas, kern_c, dist_filt)
%
%
% bayesian_cone_finding     perform bayesian cone finding on a small patch
%
% usage:  bcf = bayesian_cone_finding(datarun,bcf_params)
%
% arguments:  bcf_params - struct of parameters
%
% outputs:     result - struct of results
%
%
%
% 2010-02  gauthier
%

loop_mode = true;

% EXPAND PARAMETERS
% get passed parameters
fn = fieldnames(bcf_params);
for ff=1:length(fn)
    eval(sprintf('%s = bcf_params.%s;',fn{ff},fn{ff}))
end

num_rfs = size(stas,2);


% GENERATE MATRICES


% note locations of kernels in original cone space
if new_W || ~exist('W','var') || isempty(W)  || (exist('loop_mode','var') && loop_mode == 1)
    
%     % note the available cone colors
%     kernel_color_names = fieldnames(kernel_colors);
%     %kern_c = length(kernel_color_names);
    
    % get cone centers
    switch 1
        case 1 % regular lattice, in stixel coordinates
            num_kern_x = length(roi_x(1):kernel_spacing:roi_x(2));
            num_kern_y = length(roi_y(1):kernel_spacing:roi_y(2));
            [kernel_x, kernel_y] = meshgrid(roi_x(1):kernel_spacing:roi_x(2),roi_y(1):kernel_spacing:roi_y(2));
            kernel_x = reshape(kernel_x,[],1);
            kernel_y = reshape(kernel_y,[],1);
    end
    num_kernels = length(kernel_x)*kern_c;
end



% % generate W
% if new_W || ~exist('W','var') || isempty(W)
%     num_cone_types = length(fieldnames(kernel_colors));    
%     % size of the ROI
%     rf_size = [diff(roi_y)+1 diff(roi_x)+1];
%     
%     % generate spec for each kernel
%     
%     % locations
%     kernel_centers = 1 + [kernel_x-roi_x(1) kernel_y-roi_y(1)];
%     % replicate, once for each cone type
%     kernel_centers = reshape(reshape(repmat(kernel_centers,1,kern_c)',[],1),2,[])';
%     % load into struct
%     kernel_spec = struct('center',mat2cell(kernel_centers,ones(size(kernel_centers,1),1)));
%     
%     % types
%     for cc = 1:kern_c; [kernel_spec(cc:num_cone_types:end).type] = deal(kernel_color_names{cc}); end
%     
%     % radii
%     for cc = 1:kern_c; [kernel_spec(cc:num_cone_types:end).radius] = deal(kernel_radii(cc)); end
%     tic
%     % compute W and norm of each kernel
%     [W,kernel_norms] = make_cone_weights_matrix(rf_size,kernel_spec,kernel_colors);
%     toc
% end


% ITERATE

%tic
stas_matrix = stas;

% initialize RGC weights matrix
B = sparse(num_kernels,num_rfs);

% initialize storage variables
best_dll = zeros(num_iter,1);
best_kernel = zeros(num_iter,1);
added_cones = zeros(num_iter,9);
added_cones_mat = zeros(num_kern_y,num_kern_x,kern_c);
likelihood = zeros(num_iter,1);

% effective cone density
eff_q = q * (kernel_spacing^2);




% begin looping through iterations
for ii =1:num_iter
    
    % compute intermediate value (used in a couple computations below)
    temp_value = (stas_matrix - W*B)'*W;
    
    % compute delta_log_likelihood
    delta_log_likelihood =  cell_constants' * (full(temp_value).^2) ./ (2 * kernel_norms);
    
    % this calculation was used before each cell had a different constant:
    %delta_log_likelihood =    sum((full(temp_value).^2),1) ./ (2 * kernel_norms);
    
    % store the dll of the first iteration for plotting below
    if ii==1;first_dll = delta_log_likelihood;end
    
    
    % compute the term in delta prior for cone repulsion
    % initialize
    repulsion_force = zeros(num_kern_y,num_kern_x,kern_c);
    % for each pair of cone types...
    for new_cone_c = 1:kern_c
        for cc=1:kern_c
            % compute the repulsion from other cones
            repulsion_force(:,:,new_cone_c) = repulsion_force(:,:,new_cone_c) + ...
                imfilter(added_cones_mat(:,:,cc),log(dist_filt{new_cone_c,cc}));
        end
    end
    
    % sum up terms in delta_prior
    delta_prior = log(eff_q) - log(1-eff_q) + reshape(permute(repulsion_force,[3 1 2]),1,[]);
    
    
    % arbitrary scale factor!
    delta_prior_ = delta_prior; % save a copy with no multiplier for plotting below
    delta_prior = delta_prior * magic_number;
    
    
    % find best kernel to weights matrix
    [best_dll(ii), best_kernel(ii)] = max(delta_log_likelihood + delta_prior);
    
    % if it is less than 0, finish
    if best_dll(ii) < 0
        break
    end
    
    % add weights to it in each RGC
    B(best_kernel(ii),:) = temp_value(:,best_kernel(ii))' ./ kernel_norms(best_kernel(ii));
    
    %     subplot(4,4,ii)
    %     tmp=full(B);
    %     a=reshape(tmp,58,58);
    %     imagesc(a)
    
    % note the location of the new cone in a list of coordinates
    bk_c = mod(best_kernel(ii)-1,kern_c) + 1;
    bk_y = mod( ceil(best_kernel(ii)/kern_c) - 1, num_kern_y) + 1;
    bk_x = mod( ceil(best_kernel(ii)/(kern_c*num_kern_y)) - 1, num_kern_x) + 1;
    bk_real_x = kernel_x(ceil(best_kernel(ii)/kern_c));
    bk_real_y  = kernel_y(ceil(best_kernel(ii)/kern_c));
    added_cones(ii,:) = [bk_x bk_y bk_c bk_real_x bk_real_y...
        best_dll(ii) delta_log_likelihood(best_kernel(ii)) delta_prior(best_kernel(ii)) best_kernel(ii)];
    
    % and in a matrix
    added_cones_mat(bk_y,bk_x,bk_c) = 1;
    
    
    % compute likelihood
    % used to evaluate whether delta-likelihood is correct
    if 0
        % compute fits
        fit_stas = W*B;
        % initialize to 0
        likelihood_ = 0;
        % add in contribution of each cell
        for cc=1:length(cell_ids)
            likelihood_ = likelihood_ + n_spikes(cc)*(fit_b(cc) + fit_stas(:,cc)'*raw_stas_matrix(:,cc)) + ...
                num_frames * exp(fit_b(cc) + 0.5 * stim_variance * (fit_stas(:,cc)'*fit_stas(:,cc)));
        end
        % store
        likelihood(ii) = likelihood_;
        
        % show
        if ii > 1
            disp(log(likelihood(ii)) - log(likelihood(ii-1)))
        end
    end

end
