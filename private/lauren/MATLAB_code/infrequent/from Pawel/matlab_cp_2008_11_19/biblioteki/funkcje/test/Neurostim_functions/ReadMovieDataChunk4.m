function output=ReadMovieDataChunk4(filename,channel,time_range,unit,NS_GlobalConstants);
% Is is assumed that there are no Commands Chunks in the movie file. This
% should be changed in the future (2007-12-03).
%unit - if 0, then the current amplitude is given in DAC units. Id
%different then 0, then it is given in microamps.
%filename - 

%'output' is the array of the size 5xN. N is equal to the length of the
%time period that is defined by time_range. The five rows include information
%about:
%- DAC values (1st row);
%- value of "record" signal;
%- value of "connect" signal;
%- value of "discharge" signal;
%- value of "hold" signal (5th row).
ChipAddresses=NS_GlobalConstants.ChipAddresses;
NumberOfChannelsPerChip=NS_GlobalConstants.NumberOfChannelsPerChip;
CurrentRanges=NS_GlobalConstants.CurrentRanges;

l=length(filename);
SPfilename=[filename(1:l-8) 'pattern' filename(l-2:l)];

pwd;
filename
fid0=fopen(filename,'r','b');
%ID=fread(fid0,8,'int8')'
header=readMHchunk(fid0);
NumberOfMovies=header.number_of_movies;

offset=6; %the value 6 come sfrom the fact that 6 values on the beginning on the data array are not for events definition

output=zeros(5,time_range(2)-time_range(1)+1);
output(2,:)=1;
output(5,:)=1;
sdfg=size(output);
OutputIndex=0;
%output=[];

number=1;
while number<=NumberOfMovies
    index=0;
    
    ID=fread(fid0,8,'int8')';
    if ID==[75 116 5 96 -84 122 -59 -64]; %if this is a SC chunk...
        ChunkSize=fread(fid0,1,'int64'); %read in the chunk size
        commands=fread(fid0,ChunkSize,'int32');
        
    elseif ID==[114 -69 27 -4 99 66 -12 -123] %MD chunk
        ChunkSize=fread(fid0,1,'int64');
        data=fread(fid0,ChunkSize,'int32');
        %reading in the movie parameters:
        PD_chunk_index=data(1);
        MovieBegin=data(2)*(2^30)+data(3); %beginning of first iteration of the movie
        RepetNumber=data(4); %number of repetitions of the movie;
        RepetPeriod=data(5)*(2^30)+data(6); %period of movie repetitions;       
        
        TimeRange(1)=MovieBegin;
        TimeRange(2)=TimeRange(1)+RepetPeriod*RepetNumber; %TimeRange defines the time when given movie is to be realized
        
        %How many iterations of this movie do we need - based on the time range     
        marg1=max(time_range(1)-TimeRange(1),0);
        ignore1=floor(marg1/RepetPeriod);
        offset1=marg1-ignore1*RepetPeriod;
        
        marg2=max(TimeRange(2)-time_range(2),0);
        ignore2=floor(marg2/RepetPeriod);
        offset2=marg2-ignore2*RepetPeriod;
        
        IterationNumber=RepetNumber-ignore1-ignore2;
        
        %Do we need any iteration of this movie?
        Movie=zeros(5,RepetPeriod); %Array for single iteration of the movie
        Movie(2,:)=1; %the "record" signal is equal to 1 by default;
        Movie(5,:)=1; %the "hold" signal is equal to 1 by default;
        MovieAll=[];
        %...then 1) reconstruct one iteration of the movie...
        %1a) Is there any information about given channel in this movie?
        IterationNumber;
        if IterationNumber>0 %if given movie includes information about the time range we are interested in...
            [pattern,PatternsIndexes,status]=ReadPatternDataChunk(SPfilename,PD_chunk_index,NS_GlobalConstants); %reading in the patter data
            %function
            %[patterns_out,PatternsIndexes,Status]=ReadPatternDataChunk(filename,number_of_PD_chunk,NS_GlobalConstants);
            %pattern(1).data
            status;
            status.ChipsStatus;
            status.ChannelsStatus;
            lp=length(pattern);
            for i=1:lp %looking for the definition of pulse for given channel
                pattern(i);
                i;
                pattern(i).channel;
                if pattern(i).channel==channel
                    index=i; % value of index for the channel of interest in the 
                end
            end
        end
        
        if index~=0 %if there is any information about this channel in the movie...            
            %looking for number of pattern that given channel belongs to:
            PulseLength=length(pattern(index).data); % length of the pulse for the given channel in sampling periods
            PatternNumberOfChannel=min(find(PatternsIndexes>=index));
            NumberOfEvents=(ChunkSize-offset)/3; %number of events in one repetition of the movie!
            number;       
            %Reconstructing movie (single iteration):
            for i=1:NumberOfEvents
                PatternNumber=data((i-1)*3+2+offset); 
                if PatternNumber==PatternNumberOfChannel
                    Time=data((i-1)*3+1+offset)+1; %indexing in Matlab from 1!
                    ScalingFactor=data((i-1)*3+3+offset);
                    Movie(1,Time:Time+PulseLength-1)=pattern(index).data(1,:)*ScalingFactor;
                    Movie(2,Time:Time+PulseLength-1)=pattern(index).data(2,:);
                    Movie(3,Time:Time+PulseLength-1)=pattern(index).data(3,:);
                    Movie(4,Time:Time+PulseLength-1)=pattern(index).data(4,:);
                    Movie(5,Time:Time+PulseLength-1)=pattern(index).data(5,:);
                end
            end       
            %...and 2) Build the required fragment of the signal (all the
            %iterations)
            %number;
            %IterationNumber;
            for ii=1:IterationNumber
                MovieAll=[MovieAll Movie];
            end
            %fdghseth=size(MovieAll)
            MovieFinal=MovieAll(:,offset1+1:IterationNumber*RepetPeriod-offset2);
            if unit~=0
                %index
                CurrentMultiplierIndex=status.ChannelsStatus(channel).range+1; %Range index is counted from 0 in the file!!
                CurrentMultiplier=CurrentRanges(CurrentMultiplierIndex)/127;
                MovieFinal(1,:)=MovieFinal(1,:)*CurrentMultiplier;
            end
            MFL=length(MovieFinal);            
            %output=[output MovieAll(:,offset1+1:IterationNumber*RepetPeriod-offset2)];            
            %output(:,OutputIndex+1:OutputIndex+MFL)=MovieFinal;
            GGH=max(TimeRange(1)-time_range(1),0);
            output(:,GGH+1:GGH+MFL)=MovieFinal;
            %OutputIndex=OutputIndex+MFL
        end
    end
    number=number+1;
end
fclose(fid0);