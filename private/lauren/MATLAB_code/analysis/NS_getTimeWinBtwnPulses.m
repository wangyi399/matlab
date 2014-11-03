function [filtData meanSubFiltData] = NS_getTimeWinBtwnPulses(FileName, delayLength, iMov, varargin)

% extracts data between stim pulses of arbitrary electrical stimulation
% responses for a single movie chunk
%   - data is high-pass filtered to reduce length of artifact and then
%   a time window around each stim pulse (from pulse onset to delayLength) is zeroed out on all electrodes
%
% current directory must contain folder of data (.bin) files and corresponding pattern
% and movie files generated by labview
%
% returns data as matrix of 65 channels x (nReps*samples/rep)
% ***first channel = trigger channel, remaing 64 correspond to electrodes
%
%

p = inputParser;

p.addRequired('FileName', @ischar)
p.addRequired('delayLength', @isnumeric)
p.addRequired('iMov', @isnumeric) %index of movie chunk


p.addParamValue('plotLength', 100, @isnumeric) %length of trace to plot, if plotting to check for remaining artifact
p.addParamValue('plotElec', [], @isnumeric) %channel(s) to plot; if empty don't plot anything


p.parse(FileName, delayLength, iMov, varargin{:})

plotLength = p.Results.plotLength;
plotElec = p.Results.plotElec;




%filter parameters that seem to work ok - some small spike shape distortion
%but still easily matched for most cells
c = kaiserord([100 800],[0 1], [0.001 0.001], 20000, 'cell');
b = fir1(c{:});
shiftSize = floor(length(b)/2); %how much the trace is shifted by the filtering operation (to correct for later)

full_path=[pwd filesep 'data' FileName] %#ok<NOPRT>
rawFile=edu.ucsc.neurobiology.vision.io.RawDataFile(full_path);

totalSamples = getRawDataFileSize(full_path);

Channels=1:64;

%% extract all of the stimulus "movie" information

filename_movie = ['movie' FileName];
fid0=fopen(filename_movie,'r','b');
header=readMHchunk(fid0);


%reads in movie file and extracts start time, number of trials (repeats),
%length of trials (repeatPeriod) and movieData (contains application times
%of patterns) for movie chunk of interest
for ii = 1:iMov %stop after you get to the movie of interest
    ID=fread(fid0,8,'int8')';
    if all(ID == [75 116 5 96 -84 122 -59 -64]) %if this is a SC chunk...
        error('command chunk found in the movie file');
    elseif all(ID == [114 -69 27 -4 99 66 -12 -123]) %MD chunk
        % need to leave these in so that the file pointer is in the correct position for the next
        % iteration
        ChunkSize=fread(fid0, 1, 'int64'); %size of MD chunk
        fread(fid0, ChunkSize, 'int32'); %just to move file pointer along
        
        if ii == iMov % only get stim info for movie chunk of interest
            %reading in the movie parameters
            ChunkData=NS_MovieData(FileName,ii);
            
            % interprets first 6 values in chunkdata
            % see NS_DecodeMovieDataChunk for descriptions
            [~, movieBegin, nRepeats, repeatPeriod, movData] = NS_DecodeMovieDataChunk(ChunkData);
        end
    end
end

fclose(fid0);


nPulses=length(movData)/3;


%checks to make sure raw data file has all of the samples that the
%stimulus files thinks it does...
if totalSamples <= movieBegin+repeatPeriod*nRepeats+100
    warndlg(['Raw data file ' full_path ' does not have as many samples as expected by stimulus files']);
    return
end

filtData = int16(zeros(length(Channels)+1, nRepeats*repeatPeriod)); %+1 for trigger channel
filtDataMeanSub = int16(zeros(length(Channels)+1, nRepeats*repeatPeriod));
rawDataAll = int16(zeros(length(Channels)+1, nRepeats, repeatPeriod)); %store for plotting purposes only
for jj = 1:nRepeats
    sampStart = repeatPeriod*(jj-1);
    
    rawData = int16(rawFile.getData(movieBegin+sampStart, repeatPeriod)');
    
    %zero-mean each channel
    rawData = rawData - int16(round(mean(rawData,2)*ones(1,size(rawData,2))));
    
    rawDataAll(:,jj,:) = rawData;
        
    %apply filter to each interpulse segment (to avoid contamination of
    %traces just before leading edge of pulses)
    
    for kk = 1:nPulses+1
        %extract ROI to filter (time from onset of previous pulse through onset of current pulse)
        index=(kk-1)*3;
        if kk <= nPulses
            t = movData(index+1);
            %PatternNumber = movData(index+2);
        else
            t = repeatPeriod-1;
        end
        if kk > 1
            tPrev = movData(index-2);
        else
            tPrev = 0;
        end
        
        if ~((kk>1 && t-tPrev < delayLength) || t-tPrev == 0) %there is large enough time interval to contain non-zeroed signal
            
            %filter ROI
            filterInput = [rawData(:,tPrev+1:t+1) zeros(size(rawData,1), shiftSize*2)];
            tmpData = filter(b,1,double(filterInput),[],2); %pad data with zeros so that shift can be corrected
%             if ~isempty(plotElec)
%                 figure; hold on
%                 plot(filterInput(plotElec(1)+1, :), 'r')
%                 plot(tmpData(plotElec(1)+1,:), 'b')
%                 set(gca, 'xlim', [0 plotLength])
% 
%                 keyboard
%             end
            
            %correct for time shift caused by filtering
            tmpData(:,1:end-shiftSize) = tmpData(:,shiftSize+1:end);
            
            if ~isempty(plotElec) && 0
                figure; hold on
                plot(filterInput(plotElec(1)+1, :), 'r')
                plot(tmpData(plotElec(1)+1,:), 'g')
                plot((delayLength)*[1 1], [min(tmpData(plotElec(1)+1,:)) max(tmpData(plotElec(1)+1,:))], 'k--')
                set(gca, 'xlim', [0 plotLength])
                keyboard
            end
                        
            if kk > 1 %only keep data starting delayLength samples after pulse onset
                filtData(:,sampStart+tPrev+delayLength+1:sampStart+t+1) = int16(round(tmpData(:,delayLength+1:(t-tPrev)+1)));
                %keyboard
                %filtData(:,sampStart+tPrev+delayLength+1:sampStart+t+1) = int16(round(tmpData(:,delayLength+1+shiftSize:1+(t-tPrev)+shiftSize)));
            else
                filtData(:,sampStart+1:sampStart+t+1) = int16(round(tmpData(:,1:t+1)));
                %filtData(:,sampStart+tPrev+1:sampStart+t+1) = int16(round(tmpData(:,1+shiftSize:1+(t-tPrev)+shiftSize)));
                %keyboard
            end
        end
    end
end

filtDataMean = mean(reshape(filtData, 65, repeatPeriod, []),3);

maxAbsValEachElec = max(abs(filtDataMean),[],2);
maxAbsValEachElec(1) = []; %trigger channel

[maxDevSorted, maxDevOrder] = sort(maxAbsValEachElec, 'descend');

disp('10 highest deviations from baseline:')
for ii = 1:10
    disp(['mean deviation from baseline = ' num2str(maxDevSorted(ii)) ' (electrode ' num2str(maxDevOrder(ii)) ')'])
end

nMovieReps = size(filtData,2)/repeatPeriod;
filtDataMeanRep = repmat(int16(round(filtDataMean)), [1 nMovieReps]);

meanSubFiltData = filtData - filtDataMeanRep;

%check for remaining artifacts outside of zeroed windows
if ~isempty(plotElec)

    figure('position', [100 100 800 800])
    for ii = 1:length(plotElec)
        axes('position', [0.1 1-0.9*ii/length(plotElec) 0.8 0.9/length(plotElec)-0.02])
        hold on
        %t = movData(3*(kk-1)+1);
        for jj = 1:nRepeats
            sampStart = repeatPeriod*(jj-1);
            %patternNo = movData(3*(kk-1)+2);
            %plot(filtData(plotElec(ii)+1,t:t+plotLength)+patternNo*100)
            plot(filtData(plotElec(ii)+1,sampStart+1:sampStart+repeatPeriod), 'k-')
            plot(meanSubFiltData(plotElec(ii)+1,sampStart+1:sampStart+repeatPeriod), 'b-')

            %filtDataSum = filtDataSum + filtData(plotElec(ii)+1,sampStart+1:sampStart+repeatPeriod
        end
        %plot stim pulse times
        nElecs = max(movData(2:3:end)); %number of different patterns
        pColors = hsv(nElecs);
        
        for kk = 1:nPulses
            iPattern = movData(3*(kk-1)+2);
            t = movData(3*(kk-1)+1);
            
            plot(t, 10*iPattern, 'o', 'markerFaceColor', pColors(iPattern,:), 'markerEdgeColor', [1 1 1])
        end
        
        %plot mean trace
        plot(filtDataMean(plotElec(ii)+1,:), 'r', 'lineWidth', 2)
    end
end



