clear;

ChipAddresses=[24:31];
NumberOfChannelsPerChip=64;
CurrentRanges=[0.066 0.266 1.07 4.25 16.9 67.1 264 1040];
Fs=20000;
NS_GlobalConstants=struct('SamplingFrequency',Fs,'ChipAddresses',ChipAddresses,'NumberOfChannelsPerChip',NumberOfChannelsPerChip,'CurrentRanges',CurrentRanges);

Amplituda=2;
MovieNumber=Amplituda*3;
Length=40000;

Electrodes=[27 5 10 17 19];
RecElectrodes=[24 2 13 17 20];

%RecElectrodes=Electrodes;
NumbersOfElectrodes=length(Electrodes);

% 1. Read movie file for RAW data
DataPath='E:\2010-08-20-0\data009';
filename_movie='E:\2010-08-20-0\movie009';
MovieData=NS512_MovieData2(filename_movie,MovieNumber,NS_GlobalConstants);
[PDChunkNumber,MovieBegin,RepetNumber,RepetPeriod,MovieData]=NS_DecodeMovieDataChunk(MovieData);
MovieData(1:50);
DataMovieBegin=MovieBegin*2/3;

% 2. Read movie file for artifact data
DataPath='E:\2010-08-20-0\data012';
filename_movie='E:\2010-08-20-0\movie012';
MovieData=NS512_MovieData2(filename_movie,MovieNumber,NS_GlobalConstants);
[PDChunkNumber,MovieBegin,RepetNumber,RepetPeriod,MovieData]=NS_DecodeMovieDataChunk(MovieData);
ArtifactMovieBegin=MovieBegin*2/3;

% 3. Read RAW data
full_path='E:\2010-08-20-0\data009';
rawFile=edu.ucsc.neurobiology.vision.io.RawDataFile(full_path);
RawData=int16(rawFile.getData(DataMovieBegin,Length)'); 

% 4. Read artifact data
artifact_path='E:\2010-08-20-0\data012';
rawArtFile=edu.ucsc.neurobiology.vision.io.RawDataFile(artifact_path);
N=20;
ArtifactData=int16(zeros(N,5,Length));
Data=int16(zeros(N,5,Length));
for i=1:N
    Start=DataMovieBegin+(i-1)*Length;
    D=int16(rawFile.getData(Start,Length)');
    Data(i,:,:)=D(RecElectrodes+1,:); 
    
    Start=ArtifactMovieBegin+(i-1)*Length;
    D=int16(rawArtFile.getData(Start,Length)');
    ArtifactData(i,:,:)=D(RecElectrodes+1,:);    
end
%ArtifactData=ArtifactData./25;

%Data=RawData(Electrodes+1,:);

%for each channel: dat = 20 raw traces; art - 20 raw artifact shapes; s1 -
%averages artifact shape

s2=zeros(N,Length);
for i=1:NumbersOfElectrodes    
    dat=reshape(Data(:,i,:),N,Length);
    art=reshape(ArtifactData(:,i,:),N,Length);
    s1=int16(mean(art)); %just averaged artifact shape on given electrode
    
    electrode=Electrodes(i);
    TimesIndexes=find(MovieData(2:3:length(MovieData))==electrode);
    Times=MovieData(TimesIndexes*3-2);
    
    figure(Amplituda*100+5);
    subplot(5,1,i);
    plot(art');
    
    figure(Amplituda*100+6);
    subplot(5,1,i);
    plot([1:Length],dat,'b-',Times,ones(1,length(Times))*50,'rd');
    
    for j=1:N
        s2(j,:)=dat(j,:)-s1;
    end
    
    figure(Amplituda*100+7);
    subplot(5,1,i);
    plot([1:Length],s2,'b-',Times,ones(1,length(Times))*50,'rd');
                
    TimesIndexes=find(MovieData(2:3:length(MovieData))==electrode);
    Times=MovieData(TimesIndexes*3-2);
    
    
    %s2=s0-s1;
   
    %subplot(NumbersOfElectrodes,3,3+3*(i-1));
    %plot([1:Length],s2,'b-',Times,ones(1,length(Times))*50,'rd');     
    
    %figure(200+i);    
    %clf;
    %subplot(2,3,6);
    %axis([0 40 -150 50]);
    %grid on;
    %hold on;
    for j=1:0 %length(Times)
        p=reshape(ArtifactData(:,i,Times(j):Times(j)+39),N,40);
        pmean=int16(mean(p));        
        %figure(100+i);
        for k=1:N
            p(k,:)=p(k,:)-pmean;
        end
        h=plot(p');  
        set(h,'Color','b')
        %hold on;
        p=reshape(Data(:,i,Times(j):Times(j)+39),N,40);
        for k=1:N
            p(k,:)=p(k,:)-pmean;
        end
        %figure(200+i);
        h1=plot(p');      
        set(h1,'Color','r')
        %hold on;
    end
end

break;
figure(6)
for i=1:N
    subplot(5,5,i);
    plot(art(i,:)')
end