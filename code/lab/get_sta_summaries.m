function datarun = get_sta_summaries(datarun, cell_spec, varargin)
% get_sta_summaries     get marks, time course, rf, and rf com
%
% usage:  datarun = get_sta_summaries(datarun, cell_spec, varargin)
%
% arguments:  datarun - datarun struct
%           cell_spec - which cells (see get_cell_indices for options)
%            varargin - struct or list of optional parameters (see below)
%
% outputs:    datarun - datarun struct with sta info entered
%
%
% optional parameters, their default values, and what they specify:
%
%
% verbose               true      	show output
% show_mem              false       after loading each cell, show how much memory datarun occupies
% fig_or_axes           []         	figure or axes to plot in. if 0, make new figure. if empty, don't plot
% pause                 false       if RFs are plotted, pause after plotting each one
% keep_stas             true        keep any STA which was not already stored in datarun?
%
% robust_std_method     3           Algorithm for robust_std; just gets loaded directly into marks_params;
%                                   will not override if already set in marks_params; see robust_std for 
%                                   more information.
%
% marks_params          struct      struct of parameters to pass to significant_stixels
% keep_marks            true        load marks into datarun.stas.marks?
%
% time_course_params   	struct      struct of parameters to pass to time_course_from_sta
% keep_time_courses     true        load time courses into datarun.stas.time_courses?
%
% keep_polarities   	true        load polarities into datarun.stas.polarities?
%
% rf_params             struct      struct of parameters to pass to rf_from_sta
% keep_rfs              true        load rfs into datarun.stas.rfs?
%
% rf_com_params        	struct      struct of parameters to pass to rf_com
% keep_rf_coms        	true        load rf COMs into datarun.stas.rf_coms?
%
%
% This will usually run significantly faster if you pass: 'robust_std_method', 6
%
%
%
% 2008-10 gauthier
% 2009-10 gdf: added warning messages if significant stixels were not obtained for a cell
% 2010-01 phli: dropped CoM finding for earlier MatLab versions without compatible REGIONPROPS
%
% to change:
% currently the function computes all summaries.  it should only compute those needed for the ones that will be kept.
%


% SET UP OPTIONAL ARGUMENTS

p = inputParser;

% specify list of optional parameters
p.addParamValue('verbose', true);
p.addParamValue('show_mem', false);
p.addParamValue('fig_or_axes', []);
p.addParamValue('pause', false);

p.addParamValue('keep_stas', true);

p.addParamValue('robust_std_method', 3);

p.addParamValue('marks_params', struct);
p.addParamValue('keep_marks', true);

p.addParamValue('time_course_params', struct);
p.addParamValue('keep_time_courses', true);

p.addParamValue('keep_polarities', true);

p.addParamValue('rf_params', struct);
p.addParamValue('keep_rfs', true);

p.addParamValue('rf_com_params', struct);
p.addParamValue('keep_rf_coms', true);

% resolve user input and default values
p.parse(varargin{:});

% get params struct
params = p.Results;


if ~isfield(params.marks_params, 'robust_std_method') || isempty(params.marks_params.robust_std_method)
    params.marks_params.robust_std_method = params.robust_std_method;
end




% BODY OF THE FUNCTION

% set up plot axes
plot_axes = set_up_fig_or_axes(params.fig_or_axes);

% get list of cells
[cell_indices] = get_cell_indices(datarun,cell_spec);

% show output
if params.verbose
    T = text_waitbar(sprintf('Getting %d STA summaries...', length(cell_indices)));
    start_time = clock; % note when it started
end


for cc=1:length(cell_indices)
    
    % get cell info
    cell_index = cell_indices(cc);
    cell_id = datarun.cell_ids(cell_index);
    
    
    % get the STA
    [sta,sta_stored] = get_sta(datarun,cell_id);
    
    % store STA, if desired
    if ~sta_stored && params.keep_stas
        datarun.stas.stas{cell_index} = sta;
    end
    
    
    % find the significant stixels
    sig_stixels = significant_stixels(sta,params.marks_params);
    
    % if they're empty, try some spatial filtering!
    if sum(sum(sig_stixels)) == 0
        % generate small filter
        filt = make_gaussian('dim',2,'center_radius',3,'x_size',10,'y_size',10);
        % apply it
        sig_stixels = significant_stixels(sta,params.marks_params,'filter',filt);
        temp_message = ['filtering cell ', num2str(datarun.cell_ids(cell_indices(cc))), ' to get significant stixels'];
        warning(temp_message);
    end
    
    % report a warning if no significant stixels were found after filtering
    if (sum(sum(sig_stixels))) == 0
        temp_message = ['No significant stixels were obtained for cell ', num2str(datarun.cell_ids(cell_indices(cc)))];
        warning(temp_message);
    end

    % keep them, if desired
    if params.keep_marks
        datarun.stas.marks{cell_index} = sig_stixels;
    end
    
    
    % if nothing more is needed
    if ~params.keep_rfs && ~params.keep_rf_coms && ~params.keep_time_courses;
        if params.verbose
            T = text_waitbar(T, cc/length(cell_indices));
        end
        continue;
    end
    
    
    % extract the time course
    time_course = time_course_from_sta(sta,sig_stixels,params.time_course_params);
    

    % keep it, if desired
    if params.keep_time_courses
        datarun.stas.time_courses{cell_index} = time_course;
    end
    
    
    
    % set the polarity, if desired
    if params.keep_polarities
        datarun.stas.polarities{cell_index} = guess_polarity(time_course);
    end
    
        
    % use this timecourse to select marks more intelligently
    if 0

        % project STA onto timecourse

        % reshape, so that first dim is space-color, second dim is time
        sta_r = reshape(sta,[],size(sta,4));
        % set timecourse norm to 1
        tc = time_course/sqrt(sum(time_course.^2));
        % extract spatial component, and reshape to standard 3d matrix (y,x,color)
        sta_spatial = sta_r*tc;
        sta_spatial = reshape(sta_spatial,datarun.stimulus.field_height,datarun.stimulus.field_width,[]);

        % select significant stixels again
        sig_stixels = significant_stixels(sta_spatial,params.marks_params);

    end
    
    
    % compute the rf (pass in the marks)
    rf = rf_from_sta(sta,params.rf_params,'sig_stixels',sig_stixels);
    
    % keep it, if desired
    if params.keep_rfs
        datarun.stas.rfs{cell_index} = rf;
    end


    % plot RF
    if ~isempty(plot_axes)
        axes(plot_axes); cla(plot_axes)
        if ~isempty(rf)
            % plot RF
            image(norm_image(rf)); axis image;hold on
            % plot marks
            [ii,jj] = find(sig_stixels);
            plot(jj,ii,'.k')
        end
        title(sprintf('cell id %d',cell_id))
        drawnow
    end

    
    % only compute the CoM if it will be kept
    if params.keep_rf_coms
        the_rf_com = [];
        if ~isempty(rf)
            % Try to compute the CoM, but expect potential failure on older
            % MatLab versions due to REGIONPROPS being out of date.
            the_rf_com = try_warn(@rf_com, {rf, params.rf_com_params, 'sig_stixels', sig_stixels}, ...
                'Images:regionprops:invalidMeasurement', ...
                ['No center-of-mass calculated: the call to REGIONPROPS from rf_com is invalid in R' version('-release')]);
        end
        
        % store the COM in datarun
        datarun.stas.rf_coms{cell_index} = the_rf_com;
    end


    % plot the com
    if ~isempty(plot_axes) && ~isempty(the_rf_com)
        axes(plot_axes)
        plot(the_rf_com(1),the_rf_com(2),'+r','MarkerSize',25)
    end
    
    
    % show datarun size
    if params.show_mem
        a=whos;
        b=whos('datarun');
        fprintf('\n%0.1f MB in datarun, %0.1f MB otherwise (%0.1f MB total)',b.bytes/(2^20), sum([a.bytes])/(2^20)-b.bytes/(2^20), sum([a.bytes])/(2^20))
    end
    
    
    if ~isempty(plot_axes) && params.pause; pause; end
    
    if params.verbose
        T = text_waitbar(T, cc/length(cell_indices));
    end
end

if ~isempty(params.fig_or_axes)
    closefig(plot_axes);
end

% display how long everything took
if params.verbose
    fprintf('    done (%0.1f seconds)\n',etime(clock,start_time));
end
