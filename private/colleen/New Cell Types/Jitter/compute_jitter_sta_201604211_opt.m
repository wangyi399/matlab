%% --------------- Compute STA of focal white noise in MATLAB (not Java) -------------------
%% Function: Generate STAs for cells that were stimulated with the Voronoi stimulus

%% How to use:
%     1) Called from sta_focal_WN
%     2) Need to have spikes loaded and computes an STA by parsing the movie file correctly based on the number of cells targeted in the run


%% Potential problems:
%     1) Could have a problem parsing movie file correctly for multiple
%     cells (limited testing)
%     2) Binning problems with matlab STA code



%% Inputs
% datarun : generated in sta_focal_WN by load_data
% mdf_file : white noise xml
% num_frames : integer of max frame number (eg 30)
% spikes: n x1 vector of spike times in seconds. Obtained from datarun
% plotting: 1 or 0 for true or false whether to plot the timecourse
% cell : which cell is the STA being computed for, necessary to figure out
% which part of the movie to use
% num_cells : total number of cells targeted with this movie so that it
% knows how many sections to parse the movie into


%% Results
% sta : Computed in matlab not java, binning problems
% timecourse: From sta sig stixels
% significant stixels : standard parameters

%% Author
% Colleen Rhoades (rhoades@stanford.edu)
% April 7, 2015


function [sta] = compute_jitter_sta_201604211_opt(datarun, mdf_file, num_frames, spikes, jitter_x, jitter_y,  stixel_size, num_colors,dataparam)
%% This function computes the STA without relying on STAs from vision. The binning is slightly different from Vision.
%     mglBltTexture(frametex, [stimulus.x_start+jitterX, stimulus.y_start+jitterY, stimulus.span_width, stimulus.span_height], -1, -1);
dbstop if error
% jitter_x = zeros(size(jitter_x));
% jitter_y = zeros(size(jitter_y));
%% ---------------------------------- Process movie ------------------------------
%onsets of the stimulus presentation
% datarun.triggers = [datarun.triggers'];
%
triggers = datarun.triggers;
% [mov,height,width,duration,refresh] = get_movie_ath(mdf_file,...
%     triggers, 1,2);
if num_colors == 3
    bw = 0;
else
    bw= 1;
end

[inputs, ~, ~] = get_wn_movie_ath(datarun, mdf_file, bw);


%% account for dropped frames

%% 2016-02-17-6 data026
% 1857 is x coordinate of sharp peak in diff(triggers) graph
triggers = [triggers(1:1857); triggers(1858:end) - mean(diff(triggers(1:1857)))];
jitter_x_new = [jitter_x(1:92851); jitter_x(92900:end)]; %1857*100/2 (refresh is 2)+1 : 1857*100/2 (refresh is 2)+50
jitter_y_new = [jitter_y(1:92851); jitter_y(92900:end)];
inputs = [inputs(:,1:92851), inputs(:,92900:end)];
for i = 1:size(spikes,2)
    ind = find(spikes{i} > 92851/60 & spikes{i} <= 92900/60);
    if ~isempty(ind)
        spikes{i}(ind(end)+1:end) = spikes{i}(ind(end)+1:end) - (92900/60-92851/60);
        spikes{i} = [spikes{i}(1:ind(1)-1); spikes{i}(ind(end)+1:end)];
    end
    
    
end


%% 2016-04-21-1 data005
% 1787 is x coordinate of sharp peak in diff(triggers) graph
triggers = [triggers(1:1787); triggers(1788:end) - mean(diff(triggers(1:1787)))];
jitter_x = [jitter_x(1:89351); jitter_x(89400:end)]; %1857*100/2 (refresh is 2)+1 : 1857*100/2 (refresh is 2)+50
jitter_y= [jitter_y(1:89351); jitter_y(89400:end)];
inputs = [inputs(:,1:89351), inputs(:,89400:end)];
for i = 1:size(spikes,2)
    ind = find(spikes{i} > 89351/60 & spikes{i} <= 89400/60);
    if ~isempty(ind)
        spikes{i}(ind(end)+1:end) = spikes{i}(ind(end)+1:end) - (89400/60-89351/60);
        spikes{i} = [spikes{i}(1:ind(1)-1); spikes{i}(ind(end)+1:end)];
    end
    
    
end
%% data024
% triggers = [triggers(1:392); triggers(393:end) - mean(diff(triggers(1:392)))];
% jitter_x_new = [jitter_x(1:19601); jitter_x(19650:end)]; %392*100/2 (refresh is 2)+1 : 392*100/2 (refresh is 2)+50
% jitter_y_new = [jitter_y(1:19601); jitter_y(19650:end)];
% inputs = [inputs(:,1:19601), inputs(:,19650:end)];
% for i = 1:size(spikes,2)
%     ind = find(spikes{i} > 19601/60 & spikes{i} <= 19650/60);
%     if ~isempty(ind)
%       spikes{i}(ind(end)+1:end) = spikes{i}(ind(end)+1:end) - (19650/60-19601/60);
%       spikes{i} = [spikes{i}(1:ind(1)-1); spikes{i}(ind(end)+1:end)];
%     end
% end




image_width = dataparam.x_dim/stixel_size;
image_height = dataparam.y_dim/stixel_size;

real_frame = int8(zeros(image_width, image_height, num_colors, size(inputs,2)));
if num_colors == 3
    real_frame(:,:,1,1) = reshape(inputs(1:3:image_width*image_height*3)',image_width, image_height);
    real_frame(:,:,2,1) = reshape(inputs(2:3:image_width*image_height*3)',image_width, image_height);
    real_frame(:,:,3,1) = reshape(inputs(3:3:image_width*image_height*3)',image_width, image_height);
else
    real_frame(:,:,1,1) = reshape(inputs(1:image_width*image_height)',image_width, image_height);
    
end


pointer = image_width*image_height*num_colors+1;
%     pointer = 2+25+2;
i =2;
while pointer+image_height*image_width*num_colors-1<size(inputs,2)*size(inputs,1)
    temp = inputs(pointer:pointer+image_height*image_width*num_colors-1);
    if num_colors == 3
        real_frame(:,:,1,i) = reshape(temp(1:3:end), image_width, image_height);
        real_frame(:,:,2,i) = reshape(temp(2:3:end), image_width, image_height);
        real_frame(:,:,3,i) = reshape(temp(3:3:end), image_width, image_height);
    else
        real_frame(:,:,1,i) = reshape(temp, image_width, image_height);
    end
    
    pointer = pointer+image_height*image_width*num_colors;
    i = i+1;
end


bt_triggers = triggers(2:end) - [triggers(1:end-1)];
avg_bt_triggers = mean(bt_triggers);

length_of_time = ceil(triggers(end))+avg_bt_triggers;
upsampled_num_frames = ceil(length_of_time*dataparam.refresh_rate);

upsample_factor = dataparam.interval; % should be interval

frames_needed = uint8(kron(1:ceil(upsampled_num_frames/upsample_factor), ones(1,upsample_factor)));

frame_spacing = zeros(1, size(frames_needed,2));
for i= 1:length(triggers)-1
    spacing = linspace(triggers(i), triggers(i+1),101);
    frame_spacing(1, (i-1)*100+1:(i-1)*100+100)= spacing(1:end-1); %% assume triggers every 100 frames
end

binned_spikes = uint8(zeros(size(spikes,2), size(frames_needed,2)-1));
for j = 1:size(spikes,2)
    for i = 1:size(frames_needed,2)-1
        binned_spikes(j,i) = sum(spikes{j} >= frame_spacing(1,i) & spikes{j} < frame_spacing(1,i+1));
    end
end


%% Compute movie

sta = cell(size(spikes,2),1);
for i = 1:size(spikes,2)
    sta{i} =double(zeros(image_width*stixel_size, image_height*stixel_size,num_colors, num_frames));
end


start_points = [1:10000:size(frames_needed,2) size(frames_needed,2)];

try
    height =image_height;
    width = image_width;
    
    for j = 1:length(start_points)-1
        
        for i = 1:start_points(j+1)-1 - start_points(j)
            
            movie = int8(zeros(image_width*stixel_size, image_height*stixel_size, num_colors));
            
            if start_points(j)-1 + i+num_frames < size(frames_needed,2) %&& start_points(j)_1 + i - num_frames>0
         
                true_frame = int8(zeros(width*stixel_size, height*stixel_size));
                F = real_frame(:,:,:,frames_needed(1,start_points(j)-1 + i));
                shaped_frame = F(:,:,1);
                %                 sized_frame = imresize(shaped_frame, stixel_size, 'nearest');
                
                scale = [stixel_size stixel_size]; % The resolution scale factors: [rows columns]
                oldSize = size(shaped_frame); % Get the size of your image
                newSize = scale.*oldSize;  % Compute the new image size
                
                % Compute an upsampled set of indices:
                
                rowIndex = min(round(((1:newSize(1))-0.5)./scale(1)+0.5),oldSize(1));
                colIndex = min(round(((1:newSize(2))-0.5)./scale(2)+0.5),oldSize(2));
                % Index old image to get new image:
                sized_frame = shaped_frame(rowIndex,colIndex);
                
                
                
                sized_frame = sized_frame((stixel_size/2+1):(end - stixel_size/2), (stixel_size/2+1):(end - stixel_size/2));
                position = int64([jitter_x(frames_needed(1,start_points(j)-1 + i))+1+stixel_size/2, jitter_y(frames_needed(1,start_points(j)-1 + i))+1+stixel_size/2]);
                true_frame(position(1):(int64(size(sized_frame,1))+position(1)-1), position(2):(int64(size(sized_frame,2))+position(2)-1)) = sized_frame;
                movie(:,:,1) = true_frame;
                if num_colors == 3
                    shaped_frame = F(:,:,2);
                    sized_frame = shaped_frame(rowIndex,colIndex);
                    sized_frame = sized_frame((stixel_size/2+1):(end - stixel_size/2), (stixel_size/2+1):(end - stixel_size/2));
                    true_frame(position(1):(int64(size(sized_frame,1))+position(1)-1), position(2):(int64(size(sized_frame,2))+position(2)-1)) = sized_frame;
                    movie(:,:,2) =true_frame;
                    
                    shaped_frame = F(:,:,3);
                    sized_frame = shaped_frame(rowIndex,colIndex);
                    sized_frame = sized_frame((stixel_size/2+1):(end - stixel_size/2), (stixel_size/2+1):(end - stixel_size/2));
                    true_frame(position(1):(int64(size(sized_frame,1))+position(1)-1), position(2):(int64(size(sized_frame,2))+position(2)-1)) = sized_frame;
                    movie(:,:,3) = true_frame;
                end
                
                
                
                
                for cel = 1:size(spikes,2)
                    if mod(i,1000) == 0
                        fprintf('Cell: %d out of %d, Phase: %d out of %d, %d out of %d \n', cel, size(spikes,2), j, length(start_points)-1, i, start_points(j+1)-1 - start_points(j));
                    end
                    
                    for t = 1:num_frames
                        if binned_spikes(cel,start_points(j)-1 + i + t) ~= 0
                            
                            subtract = num_frames - t +1;
                            if subtract < 0
                                sta{cel}(:,:,:,subtract) = sta{cel}(:,:,:,subtract)  + double(movie) * double(binned_spikes(cel,start_points(j)-1 + i +t));
                            end
                        end
                    end
                    
                end
                
                
                
            end
            
            if ~exist(['/Volumes/Lab/Users/crhoades/Jitter/',dataparam.date, '/', dataparam.concatname])
                mkdir(['/Volumes/Lab/Users/crhoades/Jitter/',dataparam.date, '/', dataparam.concatname]);
            end
            if mod(j,floor((length(start_points)-1)/3)) == 0 % save three times
                
                save(['/Volumes/Lab/Users/crhoades/Jitter/',dataparam.date, '/', dataparam.concatname, '/temp'], 'sta', '-v7.3');
            end
        end
        
    end
catch
    disp('out of frames')
end
for i = 1:size(binned_spikes,1)
    sta{i}./sum(binned_spikes(i,:));
end









