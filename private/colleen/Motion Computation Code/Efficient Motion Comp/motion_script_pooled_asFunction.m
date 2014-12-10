% This program will compute two types of rasters as well as the speed
% estimate from the population signal when two populations of cells are
% grouped together (like ON and OFF parasol cells)
% It can also downsample spikes but I haven't explored that part


% Saves a file containing the speed estimate for each trial to the specified
% folder
% DATA PARAMETERS


% This is a wrapper for motion_script_colleen that allows it to be called
% as a function. 
% The parameters data_set, data_run, config_num, cell_type, vel as set in
% runMotionScriptColleen. 

% Inputs:
% data_set: Date for run
% data_run: Run number
% config_num: Which stimulus condition to run
% cell_type: Which cell type to run
% vel: true speed 

% Saves a file containing the speed estimate for each trial to the specified
% folder

function motion_script_pooled_asFunction(data_set, data_run, config_num, vel)
% DATA PARAMETERS
run_opt.load = true; % T/F
run_opt.data_set = data_set;
run_opt.data_run = data_run; % 12-19 for 2007-03-27, 2-11 for 2007-08-24, 13-17 for 2005-04-26
run_opt.config_num = config_num; 
% run_opt.cell_type = cell_type; % on/off parasol, on/off midget
run_opt.cell_type{1} = 'On parasol'; % on/off parasol, on/off midget
run_opt.cell_type{2} = 'On midget'; % on/off parasol, on/off midget
run_opt.velocity_exp = vel; % >0
run_opt.cell_types = {'Off midget', 'Off parasol', 'On midget', 'On parasol'};
run_opt.auto_set = false; % T/F -- note: overwrites run_opt params

run_opt.direction = 'left'; % 'left' or 'right'
run_opt.courseIter = 6;
% NUMERICAL PARAMETERS

run_opt.tau = .01; % tuning parameter
run_opt.tol = 1e-4;


% ANALYSES TO RUN
run_opt.downsample_spikes = false; % must run on bertha
run_opt.raster = false; % T/F
run_opt.rasterPerTrial = false; % T/F
run_opt.trial_estimate = true; % T/F






% ANALYSES TO RUN
run_opt.downsample_spikes = false; % must run on bertha
run_opt.raster = false; % T/F
run_opt.rasterPerTrial = false; % T/F
run_opt.trial_estimate = true; % T/F

tic;

% Auto set parameters if flag set to true
if run_opt.auto_set
    [run_opt.cell_types, run_opt.velocity_lim, run_opt.config_num, run_opt.trial_estimate_start, run_opt.tol] =...
        auto_set_params(run_opt.data_set, run_opt.data_run);
end

% Load data
if run_opt.load
    clear datarun tr
    % datarun{1} has vision info (sta fits)
    % datarun{2} has cell_ids, spikes, triggers
    if strcmp(run_opt.data_set, '2007-03-27-1')
        datarun{1}.names.rrs_params_path='/Volumes/Analysis/2007-03-27-1/data011-nwpca/data011-nwpca.params';
        datarun{2}.names.rrs_neurons_path=sprintf('/Volumes/Analysis/2007-03-27-1/data%03d-from-data011-nwpca/data%03d-from-data011-nwpca.neurons', run_opt.data_run, run_opt.data_run);
        datarun{2}.names.stimulus_path=sprintf('/Volumes/Analysis/2007-03-27-1/stimuli/s%02d', run_opt.data_run);
    elseif strcmp(run_opt.data_set, '2007-08-24-4')
        datarun{1}.names.rrs_params_path='/Volumes/Analysis/2007-08-24-4/data001-nwpca/data001-nwpca.params';
        datarun{2}.names.rrs_neurons_path=sprintf('/Volumes/Analysis/2007-08-24-4/data%03d-from-data001-nwpca/data%03d-from-data001-nwpca.neurons', run_opt.data_run, run_opt.data_run);
        datarun{2}.names.stimulus_path=sprintf('/Volumes/Analysis/2007-08-24-4/Stimuli/s%02d', run_opt.data_run);
    elseif strcmp(run_opt.data_set, '2005-04-26-0')
        datarun{1}.names.rrs_params_path='/Volumes/Analysis/2005-04-26-0/data';
    end
    opt=struct('verbose',1,'load_params',1,'load_neurons',1,'load_obvius_sta_fits',true);
    datarun=load_data(datarun,opt);
    datarun=map_cell_types(datarun, struct('map',[1 2],'verbose',true));
    datarun{2}=load_stim(datarun{2},'correction_incomplet_run', 0);
end

% Get indicies for each cell type 
for type  = 1:size(run_opt.cell_type,2)
    % Gets the indicies used by vision of the particular cell type
    if run_opt.raster || run_opt.trial_estimate || run_opt.rasterPerTrial
        
   
        % Get indices for specified cell type and order by RF position
        cell_indices1{type}=get_cell_indices(datarun{1},{run_opt.cell_type{type}});
        cell_indices2{type}=get_cell_indices(datarun{2},{run_opt.cell_type{type}});
        cell_x_pos = cellfun( @(X) X.mean(1), datarun{1}.vision.sta_fits); % x axis position of all STA cells
        [~, cell_sort_idx{type}] = sort(cell_x_pos(cell_indices1{type})); % indicies of how to sort
        
        %cell_indices sorted by their x coordinate of the RF from the STA
        cell_indices1{type} = cell_indices1{type}(cell_sort_idx{type}); % cell_indices1 is now indexes in order from lowest to highest firing rate
        cell_indices2{type} = cell_indices2{type}(cell_sort_idx{type});
        
        % Find trial start and stop times
        start = 0;
        stop = mean(datarun{2}.triggers(2:2:end) - datarun{2}.triggers(1:2:end));
        tr=datarun{2}.triggers(1:2:end); % all start triggers
        t=find(datarun{2}.stimulus.trial_list==run_opt.config_num); %find the times when all the stimulus type 2 starts
        tr=tr(t);
    end
end
% Grouped pooled together
if size(run_opt.cell_type,2) == 1
    cell_indices1 = [cell_indices1{1}];
    cell_indices2 = [cell_indices2{1}];
%     cell_x_pos = [cell_x_pos{1}];
    [~, cell_sort_idx] = sort(cell_x_pos(cell_indices1)); % indicies of how to sort

else
    
    cell_indices1 = [cell_indices1{1}, cell_indices1{2}];
    cell_indices2 = [cell_indices2{1}, cell_indices2{2}];
%     cell_x_pos = [cell_x_pos{1}, cell_x_pos{2}];
    [~, cell_sort_idx] = sort(cell_x_pos(cell_indices1)); % indicies of how to sort
end

    %cell_indices sorted by their x coordinate of the RF from the STA
    cell_indices1= cell_indices1(cell_sort_idx); % cell_indices1 is now indexes in order from lowest to highest firing rate
    cell_indices2 = cell_indices2(cell_sort_idx);
    
    

% downsample spikes
if run_opt.downsample_spikes
    
    onp_indices = get_cell_indices(datarun{2}, {'On parasol'});
    numspikes1 = zeros(length(onp_indices),1);
    for i=1:length(onp_indices)
        numspikes1(i) = length(datarun{2}.spikes{onp_indices(i)});
    end
    
    onm_indices = get_cell_indices(datarun{2}, {'On midget'});
    numspikes2 = zeros(length(onm_indices),1);
    for i=1:length(onm_indices)
        numspikes2(i) = length(datarun{2}.spikes{onm_indices(i)});
    end
    
    n1 = mean(numspikes1);
    n2 = mean(numspikes2);
    
    if strcmp(run_opt.data_set, '2007-03-27-1')
        if n1>n2
            if strcmp(run_opt.cell_type{type}, 'On parasol')
                for i=cell_indices2
                    % fractional downsampling:
                    datarun{2}.spikes{i}=datasample(datarun{2}.spikes{i},round(length(datarun{2}.spikes{i})*n2/n1),'Replace',false);
                end
            else
                run_opt.trial_estimate = false; % if no downsampling, don't calculate estimates
            end
        elseif n2>n1
            if strcmp(run_opt.cell_type{type}, 'On midget')
                for i=cell_indices2
                    % fractional downsampling
                    datarun{2}.spikes{i}=datasample(datarun{2}.spikes{i},round(length(datarun{2}.spikes{i})*n1/n2),'Replace',false);
                end
            else
                run_opt.trial_estimate = false; % if no downsampling, don't calculate estimates
            end
        end
    elseif strcmp(run_opt.data_set, '2007-08-24-4')
        if n1>n2
            if strcmp(run_opt.cell_type{type}, 'On parasol')
                for i=cell_indices2
                    % fractional downsampling
                    datarun{2}.spikes{i}=datasample(datarun{2}.spikes{i},round(length(datarun{2}.spikes{i})*n2/n1),'Replace',false);
                end
            else
                run_opt.trial_estimate = false; % if no downsampling, don't calculate estimates
            end
        elseif n2>n1
            if strcmp(run_opt.cell_type{type}, 'On midget')
                for i=cell_indices2
                    % fractional downsampling
                    datarun{2}.spikes{i}=datasample(datarun{2}.spikes{i},round(length(datarun{2}.spikes{i})*n1/n2),'Replace',false);
                end
            else
                run_opt.trial_estimate = false; % if no downsampling, don't calculate estimates
            end
        end
    end
end



% Plot one cell on all trials
if run_opt.raster %raster
    cell_indices1 = [cell_indices1{1}, cell_indices1{2}];
    cell_indices2 = [cell_indices2{1}, cell_indices2{2}];
    cell_x_pos = [cell_x_pos{1}, cell_x_pos{2}];
    [~, cell_sort_idx] = sort(cell_x_pos(cell_indices1)); % indicies of how to sort
    
    %cell_indices sorted by their x coordinate of the RF from the STA
    cell_indices1= cell_indices1(cell_sort_idx); % cell_indices1 is now indexes in order from lowest to highest firing rate
    cell_indices2 = cell_indices2(cell_sort_idx);
    k=1; kmin=1; kmax=length(cell_indices2); hk=loop_slider(k,kmin,kmax);
    
    while k
        if ~ishandle(hk)
            break % script breaks until figure is closed
        end
        k=round(get(hk,'Value'));
        % Takes in start and stop time (0-0.7274)
        % Spikes of the cell with the lowest firing rate first
        % start time of each stimulus type trigger
        % Finds the spikes that happened on a cell from stimulus onset to end
        % Plot those spike times on the x axis versus the trial number on the y
        % axis
        % If tracking motion, the cell should respond to the bar at the same
        % time on every trial
        
        psth_r = psth_raster(start,stop,datarun{2}.spikes{cell_indices2(k)}',tr);
        
        % Title is the cell id according to vision and the mean firing rate
        title(sprintf('%d %.2f', datarun{2}.cell_ids(cell_indices2(k)), datarun{1}.vision.sta_fits{cell_indices1(k)}.mean(1) ))
        
        uiwait;
    end
end

% Plot all cells on one trial
% ONLY WORKS FOR RIGHT MOVING BAR
if run_opt.rasterPerTrial
    
    toPlot = cell(1,length(t));
    
    % Takes in start and stop time (0-0.7274)
    % Spikes of the cell with the lowest firing rate first
    % start time of each stimulus type 2 trigger
    % Finds the spikes that happened on a cell from stimulus onset to end
    % Plot those spike times on the x axis versus the trial number on the y
    % axis
    % If tracking motion, the cell should respond to the bar at the same
    % time on every trial
    for counter = 1:length(cell_indices2)
        psth_r = psth_raster_noPlotting(start,stop,datarun{2}.spikes{cell_indices2(counter)}',tr);
        posThisCell = datarun{1}.vision.sta_fits{cell_indices1(counter)}.mean(1);
        
        posFarthestCell = datarun{1}.vision.sta_fits{cell_indices1(1)}.mean(1);
        
        
        cellNumber = datarun{2}.cell_ids(cell_indices2(counter));
        % Title is the cell id according to vision and the mean firing rate
        %          [psth, bins] = get_psth(datarun{2}.spikes{cell_indices2(counter)}, tr, 'plot_hist', true)
        for trialNum = 1:length(t)
            [x,y] = find(psth_r == trialNum-1);
            toPlot{trialNum}= [toPlot{trialNum}; [psth_r(x,1), repmat(cellNumber, length(x),1), repmat(posThisCell, length(x),1)]];
        end
    end
    
    k=1; kmin=1; kmax=length(t); hk=loop_slider(k,kmin,kmax);
    
    while k
        if ~ishandle(hk)
            break % script breaks until figure is closed
        end
        k=round(get(hk,'Value'));
        y_scale = 1;
        Color = ['k', '.'];
        plot(toPlot{k}(:,1),toPlot{k}(:,3)*y_scale,Color);
        title({run_opt.cell_type{type}, [run_opt.data_set, ' Run ', num2str(run_opt.data_run)],'Bright bar moving right', sprintf(' Trial Number %d',  k)})
        xlabel('time (ms)');
        ylabel('Cell''s centroid distance from reference');
        uiwait;
    end
    
end



if run_opt.trial_estimate
    options = optimset('Display', 'iter', 'TolFun', run_opt.tol , 'MaxFunEvals', 60, 'LargeScale', 'off');
    spikes = datarun{2}.spikes;
    
    %Prior is +/-25% of expected value
    velocity = linspace(0.75*run_opt.velocity_exp, 1.25*run_opt.velocity_exp, run_opt.courseIter);
    strsig1 = zeros(1,length(velocity));
    
    % Run coarse error function to initialize velocity
    for i =1:length(tr)
        parfor j = 1:length(velocity)
            v = velocity(j);
            [strsig1(j)] = -pop_motion_signal_colleen(v, spikes, cell_indices1, cell_indices2, cell_x_pos, tr(i), stop, run_opt.tau, run_opt.tol, datarun, run_opt.direction);
        end
%       figure; plot(velocity, strsig1)
        i
        [x1,y1] = min(strsig1);
        
        % Initialize minimization
        run_opt.trial_estimate_start(i) = velocity(y1);
    end
    
    % Find speed estimate
    parfor i =1:length(tr)

        [estimates(i)] = fminunc(@(v) -pop_motion_signal_colleen(v, spikes, cell_indices1, cell_indices2, cell_x_pos, tr(i), stop, run_opt.tau, run_opt.tol, datarun, run_opt.direction), run_opt.trial_estimate_start(i), options);

        fprintf('for trial %d, the estimated speed was %d', i, estimates(i))
    end
    %save results
%     foldername = sprintf('/Users/vision/Desktop/GitHub code repository/private/colleen/Results/resultsColleen/%s/BrightRight/OnMandOnP', run_opt.data_set);
%     filename = sprintf('/Users/vision/Desktop/GitHub code repository/private/colleen/Results/resultsColleen/%s/BrightRight/OnMAndOnP/%s_data_run_%02d_config_%d.mat', run_opt.data_set, run_opt.cell_type{type}, run_opt.data_run, run_opt.config_num);
     foldername = sprintf('/home/vision/Colleen/matlab/private/colleen/results/resultsColleen/%s/DarkLeft/OnMandOnP', run_opt.data_set);
    filename = sprintf('/home/vision/Colleen/matlab/private/colleen/results/resultsColleen/%s/DarkLeft/OnMandOnP/%s_data_run_%02d_config_%d.mat', run_opt.data_set, run_opt.cell_type{type}, run_opt.data_run, run_opt.config_num);
   
    if exist(foldername)
        save(filename, 'estimates', 'run_opt')
    else
        mkdir(foldername);
        save(filename, 'estimates', 'run_opt')
    end
        
end

% send email when done
% gmail('crhoades227@gmail.com', sprintf('Done with %s %s_data_run_%02d_config_%d_darkright_newmethod',run_opt.data_set, run_opt.cell_type, run_opt.data_run, run_opt.config_num))

ElapsedTime=toc