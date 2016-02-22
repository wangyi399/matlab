

clear
%% ------------------------------ INPUTS -----------------------------------
cell_list = [397 861 1223 3812 3935 4924 5898 6289 6740 7068]; %from vision

file_name = '2016-02-17-1/data004/data004';

% where to save
file_path = ['/Volumes/Lab/Users/crhoades/Colleen/matlab/private/colleen/New Cell Types/Stimulus Code/2016-02-17-1/data004/large_on/'];
screen_width = 640; % in pixels
screen_height = 320;
stixels_ref = 16; % stixel size of white noise run
%% ------------------------------- Load Data ------------------------------------------
if ~exist(file_path)
    mkdir(file_path)
end

datarun.names.rrs_params_path=['/Volumes/Analysis/', file_name, '.params'];
datarun.names.rrs_sta_path = ['/Volumes/Analysis/', file_name, '.sta'];
opt=struct('verbose',1,'load_params',1,'load_neurons',0,'load_obvius_sta_fits',true, 'load_sta', 1, 'load_sta_params', 1, 'load_all',false);
opt.load_sta_params.frames = 1:30;% if this line is missing, will error; have to input as a vector list of frames, not the number of frames total, counting backwards
datarun=load_data(datarun,opt);
sizes = [0.5 1 2 4 8];
for k = 1:length(cell_list)
    cells = cell_list(k);
    for j = 1:length(sizes)
        
        %% ------------------------------- Plot Vision STA -----------------------------
        myMap = zeros(screen_height, screen_width); % pixesl on the screen
        [cell_numbers, cell_type, cell_type_number] = get_cell_indices(datarun, cells);
        sta = datarun.stas.stas{cell_numbers};
        %     sig_stixels = significant_stixels(sta);
        sig_stixels = significant_stixels(sta);
        
        % find peak frame
        time_course = time_course_from_sta(sta, sig_stixels);
        
        
        temp_rf = rf_from_sta(sta, 'sig_stixels', sig_stixels);
        
        the_fit = datarun.stas.fits{cell_numbers};
        ctr = the_fit.mean;
        rad = the_fit.sd*sizes(j);
        [X,Y] = drawEllipse_upsampled([ctr rad the_fit.angle]);
        %         Y = screen_height/stixels_ref - Y;
        %         figure;
        %                 plot(X,Y,'Color','k');
        axis([0 screen_width/stixels_ref 0 screen_height/stixels_ref])
        
        X_large =  round(screen_width*X/(screen_width/stixels_ref));
        Y_large =  round(screen_height*Y/(screen_height/stixels_ref));
        %        ellipse_t = fit_ellipse( X_large,Y_large)
        %        myMap([Y_large; X_large]') = 1;
        for i = 1:length(X_large)
            
            if Y_large(i) > size(myMap,1)
                Y_large(i) = size(myMap,1);
            elseif Y_large(i) < 1
                Y_large(i) = 1;
            end
            if X_large(i) > size(myMap,2)
                X_large(i) = size(myMap,2);
            elseif X_large(i) < 1
                X_large(i) = 1;
            end
            
            
            myMap(Y_large(i),X_large(i)) = 1;
            
        end
        
        myMap_filled = imfill(myMap,'holes');
        
        
        figure
        imagesc(myMap_filled)
        axis equal
        
        %% ------------------------------- Write the mask to a file ---------------------------------
        dlmwrite([file_path,num2str(cells), '_', num2str(floor(sizes(j))),'.txt'], myMap_filled, 'delimiter', '\t', 'newline', 'pc'); % if this errors which save path
        savedMap = dlmread([file_path,num2str(cells), '_', num2str(floor(sizes(j))), '.txt']);
        
    end
    
    %% ------------------------------- Display mask ----------------------------------------------
    % figure
    % imagesc(savedMap)
    % title('Stixels to be modulated')
    % axis equal
end
