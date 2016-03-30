clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%% INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the Data for the DS run
run_opt.data_set = '2016-01-05-5';
run_opt.data_run = 'data011/data011';
location = 'Data';

interval = 2; % number of seconds each stimulus was displayed for
num_of_trials = 15;

cell_type = 'ON large';
sfile = 's11';

% Where to save the data
filepath= ['/Volumes/Lab/Users/crhoades/Light Steps/', run_opt.data_set, '/', run_opt.data_run, '/'];

% You can give the cells as all of them (datarun.cell_ids) or give
% specific vision ids
% Find the cell to run by mapping a large cell EI from a white noise run
% cells = [335 1639 6366]; % 'all' or give a vector of vision cell ids
cells = [123 1427 5766]; % 'all' or give a vector of vision cell ids
cells_match = [1 3 7];
steps = [0.5, 1,2, 4,8];
map_order_cells = [128 241 1428 2001 2063 3963 5881];
map_order = kron(map_order_cells, ones(1, length(steps)))';

%%%%%%%%%%%%%%%%%%%%%%%%%% END INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if ~exist(filepath)
    mkdir(filepath)
end


% datarun{1}.names.rrs_params_path=['/Volumes/Analysis/', run_opt.data_set, '/', run_opt.data_run, '/', run_opt.data_run(end-6:end), '.params'];
% datarun{1}.names.rrs_sta_path=['/Volumes/Analysis/', run_opt.data_set, '/', run_opt.data_run, '/', 'data022', '.sta'];

datarun.names.rrs_neurons_path=['/Volumes/Analysis/', run_opt.data_set, '/', run_opt.data_run,'.neurons'];
% datarun.names.stimulus_path=['/Volumes/',location,'/', run_opt.data_set, '/Visual/s', '05'];
datarun.names.stimulus_path=['~/Desktop/2016-01-05-5/',sfile,'.txt'];

% datarun.names.rrs_neurons_path=['/Volumes/Analysis/', run_opt.data_set, '/', run_opt.data_run, '/', run_opt.data_run(end-6:end), '.neurons'];
% datarun.names.stimulus_path=['/Volumes/',location,'/', run_opt.data_set, '/Visual/s', run_opt.data_run(end-1:end)];


opt=struct('verbose',1,'load_sta', 1,'load_params',0,'load_neurons',1,'load_obvius_sta_fits',true);

datarun=load_data(datarun,opt);
% datarun=map_cell_types(datarun, struct('map',[1 2],'verbose',true));

% If the trigger interval in LabView is set long enought (~6 seconds for 5
% second stimuli), then this trigger_iti_thr should be fine.
datarun=load_stim(datarun,'correction_incomplet_run', 0, 'trigger_iti_thr', 0.00001); % manually set threshold until got right number of triggers


if strcmp(run_opt.data_set, '2016-01-05-5') && strcmp(run_opt.data_run, 'data008/data008')
    datarun.triggers = [datarun.triggers(1:1207); 1207; datarun.triggers(1208:end)];
end

if strcmp(cells, 'all')
    cells = datarun.cell_ids;
end
num_spikes = nan(length(cells), length(steps));
cell_index = get_cell_indices(datarun, cells);

map_order(:,2) = repmat(floor(steps)',length(map_order_cells) ,1);
for i = 1:length(map_order)
    names{i,1} = [num2str(map_order(i,1)), '_', num2str(map_order(i,2))];
end

% trials_by_cell = cell(length(names),3);
trials_by_cell(:,1) =  kron(1:length(map_order_cells), ones(1, length(steps)))';
trials_by_cell(:,2) =  repmat(steps', length(map_order_cells),1);
trials = arrayfun(@(x)(x), trials_by_cell, 'unif', 0);
trials(:, 3:4) = cell(size(trials));
%         map_ind = find(map_order == cells(x)) - 1;
%         map_ind = map_ind(s);
for i = 1:length(names)
    for j = 1:length(datarun.stimulus.trials)
        if strcmp(names{i}, datarun.stimulus.trials(j).index_map(2:end-1))
            if datarun.stimulus.trials(j).rgb == [0.48 0.48 0.48];
                trials{i,3} = [trials{i,3} j];
            else
                trials{i,4} = [trials{i,4} j];
            end
            
        end
    end
end
for x = 1:length(cells)
    for s= 1:length(steps)
       
        cell_indicies = find(cell2mat(trials(:,1)) == cells_match(x));
%         trial_ids = cell2mat(trials(cell_indicies(s),3));
        
%         trial_ids = unique(datarun.stimulus.trial_list(trials_by_cell));
        step1_trials = cell2mat(trials(cell_indicies(s),3));
        step2_trials = cell2mat(trials(cell_indicies(s),4));
        
        step1_triggers = datarun.triggers(step1_trials*2-1);
        step2_triggers = datarun.triggers(step2_trials*2-1);
%         step1_triggers = step1_triggers(1:6);
%                 step2_triggers = step2_triggers(1:6);

        spikes = datarun.spikes{cell_index(x)};
        cnt = 0;
        rasters1 = [];
        rasters2 = [];
        psth1 = [];
        psth2 = [];
%         step1_triggers(step1_triggers > 800) = [];
%         step2_triggers(step2_triggers > 800) = [];

        for trig = 1:length(step1_triggers)
            tmp=spikes(spikes>step1_triggers(trig) & spikes< step1_triggers(trig)+interval);
            psth1=[psth1, (tmp'-step1_triggers(trig))];
            rasters1 = [rasters1, (tmp'-step1_triggers(trig))+interval*(trig-1)];
            cnt = cnt+1;
        end
        %   L samples, Sampling rate = 1kHz. Spiketimes are hashed by the trial length.
        cnt = 0;
        for trig = 1:length(step2_triggers)
            tmp=spikes(spikes>step2_triggers(trig) & spikes< step2_triggers(trig)+interval);
            psth2=[psth2, (tmp'-step2_triggers(trig))];
            
            rasters2=[rasters2, (tmp'-step2_triggers(trig))+interval*(trig-1)];
            cnt = cnt+1;
        end
        
        
        num_spikes(x,s) = length(rasters1) + length(rasters2);
        
        % PSTH calculation
        spike_frames1 = floor(psth1*120);
        psth1_spikes = nan(interval*120,1);
        for t = 1:interval*120
            psth1_spikes(t) = sum(spike_frames1 == t);
        end
        psth1_spikes_smoothed = conv(psth1_spikes, gausswin(5));
        
        psth1_spikes_smoothed = psth1_spikes_smoothed*120/num_of_trials;
        
        
        
        
        spike_frames2 = floor(psth2*120);
        psth2_spikes = nan(interval*120,1);
        for t = 1:interval*120
            psth2_spikes(t) = sum(spike_frames2 == t);
        end
        psth2_spikes_smoothed = conv(psth2_spikes, gausswin(5));
        
        psth2_spikes_smoothed = psth2_spikes_smoothed*120/num_of_trials;
        
        
        figure;
        set(gcf, 'Position', [1000, 500, 840,630]);
        if datarun.stimulus.trials(step1_trials(1)).rgb(1) > 0
            
            
            
            
            h= subplot(2,1,1);
            rasterplot(rasters1,num_of_trials ,interval, h)
            set(gca,'xlim', [0 ,interval])
            hold on
            plot([0,1,2], repmat(num_of_trials*2+5.1,1,3), 'k--')
            hold on
            plot([0,0,1,1,2], repmat(num_of_trials*2+5,1,5) + [0,3,3,0,0], 'g')
            plot([1,1], [0, num_of_trials*2], 'r--')
            
            box off
            
            
            g =subplot(2,1,2);
            rasterplot(rasters2,num_of_trials ,interval, g)
            set(gca,'xlim', [0 ,interval])
            
            hold on
            plot([0,1,2], repmat(num_of_trials*2+5.1,1,3), 'k--')
            hold on
            plot([0,0,1,1,2], repmat(num_of_trials*2+5,1,5) + [0,-3,-3,0,0], 'g')
            box off
            %             y_lim = get(gca, 'ylim');
            
            %             plot(zeros(1,10), linspace(y_lim(1), y_lim(2) ,10), 'r--')
            plot([1,1], [0, num_of_trials*2], 'r--')
            suptitle({[run_opt.data_set, ' data',run_opt.data_run(end-2:end)];[' Cell ' num2str(cells(x)), ' ', cell_type]; [num2str(steps(s)), ' of 1 SD Elliptical Fit to RF']})
            print(gcf,'-dpdf',[filepath, 'Cell_',num2str(cells(x)), '_Size_', num2str(floor(steps(s))), '_Raster']);
            
            
            
            
            
            
            
            
            
            
            
            
            figure;
            set(gcf, 'Position', [1000, 500, 840,630]);
            h= subplot(2,1,1);
            plot((1:size(psth1_spikes_smoothed,1))/120, psth1_spikes_smoothed)
            set(gca,'xlim', [0 ,interval])
            hold on
            plot([0,1,2], repmat(max([psth1_spikes_smoothed; psth2_spikes_smoothed])+5.1,1,3), 'k--')
            hold on
            plot([0,0,1,1,2], repmat(max([psth1_spikes_smoothed; psth2_spikes_smoothed])+5,1,5) + [0,3,3,0,0], 'g')
            plot([1,1], [0, max([psth1_spikes_smoothed; psth2_spikes_smoothed])], 'r--')
            
            box off
            
            
            g =subplot(2,1,2);
            plot((1:size(psth2_spikes_smoothed,1))/120, psth2_spikes_smoothed)
            set(gca,'xlim', [0 ,interval])
            
            hold on
            plot([0,1,2], repmat(max([psth1_spikes_smoothed; psth2_spikes_smoothed])+5.1,1,3), 'k--')
            hold on
            plot([0,0,1,1,2], repmat(max([psth1_spikes_smoothed; psth2_spikes_smoothed])+5,1,5) + [0,-3,-3,0,0], 'g')
            box off
            
            plot([1,1], [0, max([psth1_spikes_smoothed; psth2_spikes_smoothed])], 'r--')
            suptitle({[run_opt.data_set, ' data',run_opt.data_run(end-2:end)];[' Cell ' num2str(cells(x)), ' ', cell_type]; [num2str(steps(s)), ' of 1 SD Elliptical Fit to RF']})
            print(gcf,'-dpdf',[filepath, 'Cell_',num2str(cells(x)), '_Size_', num2str(floor(steps(s))), '_PSTH']);
            
            xlabel('Time')
            ylabel('Firing Rate')
            
            
            
            
            
        else
            
            h= subplot(2,1,1);
            rasterplot(rasters2,num_of_trials ,interval, h)
            set(gca,'xlim', [0 ,interval])
            hold on
            plot([0,1,2], repmat(num_of_trials*2+5.1,1,3), 'k--')
            hold on
            plot([0,0,1,1,2], repmat(num_of_trials*2+5,1,5) + [0,3,3,0,0], 'g')
            plot([1,1], [0, num_of_trials*2], 'r--')
            
            box off
            
            
            g =subplot(2,1,2);
            rasterplot(rasters1,num_of_trials ,interval, g)
            set(gca,'xlim', [0 ,interval])
            
            hold on
            plot([0,1,2], repmat(num_of_trials*2+5.1,1,3), 'k--')
            hold on
            plot([0,0,1,1,2], repmat(num_of_trials*2+5,1,5) + [0,-3,-3,0,0], 'g')
            box off
            plot([1,1], [0, num_of_trials*2], 'r--')
            suptitle({[run_opt.data_set, ' data',run_opt.data_run(end-2:end)];[' Cell ' num2str(cells(x)), ' ', cell_type]; [num2str(steps(s)), ' of 1 SD Elliptical Fit to RF']})
            print(gcf,'-dpdf',[filepath, 'Cell_',num2str(cells(x)), '_Size_', num2str(floor(steps(s))), '_Raster']);
            
            figure;
            set(gcf, 'Position', [1000, 500, 840,630]);
            
            h= subplot(2,1,1);
            plot((1:size(psth2_spikes_smoothed,1))/120, psth2_spikes_smoothed)
            set(gca,'xlim', [0 ,interval])
            hold on
            plot([0,1,2], repmat(max([psth1_spikes_smoothed; psth2_spikes_smoothed])+5.1,1,3), 'k--')
            hold on
            plot([0,0,1,1,2], repmat(max([psth1_spikes_smoothed; psth2_spikes_smoothed])+5,1,5) + [0,3,3,0,0], 'g')
            plot([1,1], [0, max([psth1_spikes_smoothed; psth2_spikes_smoothed])], 'r--')
            
            box off
            
            
            g =subplot(2,1,2);
            plot((1:size(psth1_spikes_smoothed,1))/120, psth1_spikes_smoothed)
            set(gca,'xlim', [0 ,interval])
            
            hold on
            plot([0,1,2], repmat(max([psth1_spikes_smoothed; psth2_spikes_smoothed])+5.1,1,3), 'k--')
            hold on
            plot([0,0,1,1,2], repmat(max([psth1_spikes_smoothed; psth2_spikes_smoothed])+5,1,5) + [0,-3,-3,0,0], 'g')
            box off
            
            plot([1,1], [0, max([psth1_spikes_smoothed; psth2_spikes_smoothed])], 'r--')
            suptitle({[run_opt.data_set, ' data',run_opt.data_run(end-2:end)];[' Cell ' num2str(cells(x)), ' ', cell_type]; [num2str(steps(s)), ' of 1 SD Elliptical Fit to RF']})
            print(gcf,'-dpdf',[filepath, 'Cell_',num2str(cells(x)), '_Size_', num2str(floor(steps(s))), '_PSTH']);
            
            xlabel('Time')
            ylabel('Firing Rate')
            
            
        end
        suptitle({[run_opt.data_set, ' data',run_opt.data_run(end-2:end)];[' Cell ' num2str(cells(x)), ' ', cell_type]; [num2str(steps(s)), ' of 1 SD Elliptical Fit to RF']})
        
        print(gcf,'-dpdf',[filepath, 'Cell_',num2str(cells(x)), '_Size_', num2str(floor(steps(s))), '_PSTH']);
        %         save([filepath, 'Cell_',num2str(cells(x)), '_Size_', num2str(floor(steps(s)))], 'num_spikes');
    end
    
    
end
firing_rate = num_spikes./num_of_trials./interval/2; %*2 for raster 1 and raster 2
figure;
plot(repmat(steps,length(cells),1)',firing_rate')
xlabel('Factor * 1 SD Fit to RF')
ylabel('Firing Rate')
legendCell = cellstr(num2str(cells', 'Cell %-d'));
legend(legendCell)
title([cell_type,' responses to increasing spot'])
print(gcf,'-dpdf',[filepath, cell_type]);




