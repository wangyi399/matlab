function [PDChunkNumber,MovieBegin,RepetNumber,RepetPeriod,ClusterFileName]=NS_PreprocessDataNew512(FileName,WritePath,WritePathFigs,FigureProperties,NS_GlobalConstants,makePlots,MoviesToRead,PatternsToRead,ChannelsToRead);
% This function generates quickly plots of overlaid responses for all
% patterns and all movies FOR 1-EL. STIMULATION!!!! It is assumed that the
% number of pattern called in the movie is the number of stimulating
% electrode.
ArrayID=1;

ChipAddresses=NS_GlobalConstants.ChipAddresses;
NumberOfChannelsPerChip=NS_GlobalConstants.NumberOfChannelsPerChip;
CurrentRanges=NS_GlobalConstants.CurrentRanges;
Fs=NS_GlobalConstants.SamplingFrequency;

%full_path=[pwd '\' 'data' FileName];
full_path=[pwd filesep 'data' FileName]
rawFile=edu.ucsc.neurobiology.vision.io.RawDataFile(full_path);
electrodeMap=edu.ucsc.neurobiology.vision.electrodemap.ElectrodeMapFactory.getElectrodeMap(1);

TraceLength=140;

filename_movie=['movie' FileName];
l=length(filename_movie);
SPfilename=[filename_movie(1:l-8) 'pattern' filename_movie(l-2:l)];

fid0=fopen(filename_movie,'r','b');
%ID=fread(fid0,8,'int8')'
header=readMHchunk(fid0);
NumberOfMovies=header.number_of_movies;

Channels=ChannelsToRead;
t0 = clock;
NumberOfPatternsMax=0;
NumberOfRepetitionsMax=0;

for i=1:8:NumberOfMovies-1 %unless specific movie numbers defined!! minus 1 because the last movie is expected to be empty. This loop repeats once for each amplitude (in case of scan data).
    %a ) estimate how much time is left to complete the loop
    if i>1 
        finished = (i-1)/(NumberOfMovies-1); % proportion of files created so far
        disp(sprintf('finished writing %0.1f%% of files', finished*100))
        tnow = clock;
        timeElapsed = etime(tnow, t0); %time elapsed since loop started
        estimatedTimeLeft = (timeElapsed/finished)*(1-finished);
        disp(sprintf('estimated time left: %0.1f seconds',estimatedTimeLeft))
    end

    %b) read in single movie_data_chunk    
    ID=fread(fid0,8,'int8')'
    if ID==[75 116 5 96 -84 122 -59 -64]; %if this is a SC (command) chunk...
        error('command chunk found in the movie file');
        ChunkSize=fread(fid0,1,'int64'); %read in the chunk size
        commands=fread(fid0,ChunkSize,'int32');        
    elseif ID==[114 -69 27 -4 99 66 -12 -123] %MD (movie data) chunk
        ChunkSize=fread(fid0,1,'int64');
        ChunkData=fread(fid0,ChunkSize,'int32');
        %reading in the movie parameters:
        ChunkData=NS_MovieData(FileName,i,NS_GlobalConstants);
        [PDChunkNumber,MovieBegin,RepetNumber,RepetPeriod,MovieData]=NS_DecodeMovieDataChunk(ChunkData);
        %RepetNumber=100; % DELETE!!!!!!
    end
    NumberOfEvents=length(MovieData)/3;
    Events=zeros(NumberOfEvents,1);
    
    %c) read in corresponding pattern_data_chunk, save status into file, predefine array for RAW data
    
    [Patterns,PatternsIndexes,Status]=ReadPatternDataChunk(SPfilename,PDChunkNumber,NS_GlobalConstants);
    'ReadPatternDataChunk done'
    FullName_status=[WritePath filesep 'status_m' num2str(i)];
    save(FullName_status,'Status');
            
    NumberOfPatterns=length(PatternsIndexes);
    NumberOfPatternsMax=max(NumberOfPatternsMax,NumberOfPatterns);
    NumberOfEvents
    RepetNumber
    length(ChannelsToRead)
    TraceLength
    Traces=int16(zeros(NumberOfEvents,RepetNumber,length(ChannelsToRead),TraceLength));
        
    %d) create array of names
    for j=1:NumberOfPatterns
        [Name,ChannelsStim]=NS_PatternAmplitudes(Patterns,PatternsIndexes,Status,j,NS_GlobalConstants);
        Names{j}=Name;
    end    
    
    %d) read in RAW data for each repetition, for each stimulation event
    %identify pattern number, and save RAW data coresponding to each event into
    %Traces array. We assume each repetition of the movie includes identical
    %collection of patterns (logical, isn't it).
    
    for j=1:RepetNumber % one iteration of this loop takes less than 0.5s for 64-channel data (122 events)        
        RepIndex=j;        
        RawData=int16(rawFile.getData(MovieBegin+RepetPeriod*(j-1),RepetPeriod)');                        
        'ReadingRawData'
        for k=1:NumberOfEvents              
            index=(k-1)*3;
            t=MovieData(index+1);
            PatternNumber=MovieData(index+2);                                           
            Events(k)=PatternNumber;            
            Traces(k,j,:,:)=RawData(Channels+1,t+1:t+TraceLength); %this takes less than 0.1ms for 64-channel data                                 
        end        
    end
    clear RawData;
            
    %f) save output files
    for l=1:NumberOfPatterns % this loop should be running only over patterns used in this movie !!!!
        NumberekOfPatternik=l
        WhichEvents=find(Events==l); %which events in this movie corresponded to given pattern
        NumberOfRepetitionsMax=max(NumberOfRepetitionsMax,RepetNumber*length(WhichEvents));
        if length(WhichEvents)>0            
            Pattern=NS_ExtractPatternFromPatternDataChunk(Patterns,PatternsIndexes,l);                                    
                                    
            TracesToSave=reshape(Traces(WhichEvents,:,1:length(Channels),:),RepetNumber*length(WhichEvents),length(Channels),TraceLength);% might be <7                 
            STTS=size(TracesToSave);        
        
            a=reshape(TracesToSave,STTS(1)*STTS(2)*STTS(3),1);
            b=zeros(1000,1);
            b(1)=STTS(1);
            b(2)=STTS(2);
            b(3)=STTS(3);
            b(3+1:3+length(Channels))=Channels';
            b(4+length(Channels))=length(WhichEvents);
            o=[b' a'];                        
                        
            FullName=[WritePath filesep 'p' num2str(l) '_m' num2str(i)];
            fid=fopen(FullName,'wb','ieee-le');
                                    
            fwrite(fid,o,'int16');
            fclose(fid);                    
            
            FullName_pattern=[WritePath filesep 'pattern' num2str(l) '_m' num2str(i)];            
            save(FullName_pattern,'Pattern');
            
            %part below - only for 1-el. scan!!
            if makePlots==1
                ChannelsToPlot=electrodeMap.getAdjacentsTo(l,1);
                TracesToShow=TracesToSave(:,ChannelsToPlot,:);
                c=int16(mean(TracesToShow));
                for ci=1:STTS(1)
                    TracesToShow(ci,:,:)=TracesToShow(ci,:,:)-c;
                end
            
                y=NS_PlotManySignaturesOnArrayLayoutNew(TracesToShow,ChannelsToPlot,ones(1,STTS(1)),ArrayID,FigureProperties,NS_GlobalConstants);
                hj=gcf;
                set(hj, 'PaperOrientation', 'portrait');
        
                %FullName=[WritePathFigs '\' 'p' num2str(l) '_m' num2str(i) Names{l}];
                %print(hj, '-dtiff', FullName);
            end
        end
    end     
    clear Traces;
    clear TracesToSave;
end  

%create cluster file:
ClusterFileName=NS_CreateClusterFile(WritePath,FileName,NumberOfMovies,NumberOfPatternsMax,NumberOfRepetitionsMax);