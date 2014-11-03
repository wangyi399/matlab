%clear;

ChipAddresses=[24:31];
NumberOfChannelsPerChip=64;
CurrentRanges=[0.066 0.266 1.07 4.25 16.9 67.1 264 1040];
Fs=20000;
NS_GlobalConstants=struct('SamplingFrequency',Fs,'ChipAddresses',ChipAddresses,'NumberOfChannelsPerChip',NumberOfChannelsPerChip,'CurrentRanges',CurrentRanges);
electrodeMap=edu.ucsc.neurobiology.vision.electrodemap.ElectrodeMapFactory.getElectrodeMap(504);

Amplituda=3;
MovieNumber=2+(Amplituda-1)*5; %Amplituda*3;
Length=40000;

StimElectrodes=[6 16 18 3 27 28 37 45 54 51 60 61] % for movie 1% 10 34 43 20 30 52 53 ];
RecElectrodes=[1 16 18 19 27 28 37 45 47 50 60 61];
MovieNumbers=[25 10 23 26 15 21 14 6 10 14 18 24];

ElectrodeIndex=10

NumbersOfElectrodes=length(StimElectrodes);

% 1. Read movie file for RAW data
DataPath='F:\2010-09-21-0\data017';
filename_movie='F:\2010-09-21-0\movie017';
MovieData1=NS512_MovieData2(filename_movie,MovieNumber,NS_GlobalConstants);
[PDChunkNumber,MovieBegin,RepetNumber,RepetPeriod,MovieData]=NS_DecodeMovieDataChunk(MovieData1);
MovieData(1:50);
DataMovieBegin=MovieBegin; %*2/3;

% 2. Read movie file for artifact data
DataPath='F:\2010-09-21-0\data020';
filename_movie='F:\2010-09-21-0\movie020';
MovieData=NS512_MovieData2(filename_movie,MovieNumber,NS_GlobalConstants);
[PDChunkNumber,MovieBegin,RepetNumber,RepetPeriod,MovieData]=NS_DecodeMovieDataChunk(MovieData);
ArtifactMovieBegin=MovieBegin; %*2/3;

% 3. Read RAW data
full_path='F:\2010-09-21-0\data017';
rawFile=edu.ucsc.neurobiology.vision.io.RawDataFile(full_path);
RawData=int16(rawFile.getData(DataMovieBegin,Length)'); 

% 4. Read artifact data
artifact_path='F:\2010-09-21-0\data020';
rawArtFile=edu.ucsc.neurobiology.vision.io.RawDataFile(artifact_path);
N=18;

ArtifactData=int16(zeros(N,length(RecElectrodes),Length));
Data=int16(zeros(N,length(RecElectrodes),Length));

for i=1:N
    Start=DataMovieBegin+(i-1)*Length;
    D=int16(rawFile.getData(Start,Length)');
    Data(i,:,:)=D(RecElectrodes+1,:); 
    
    Start=ArtifactMovieBegin+(i-1)*Length;
    D=int16(rawArtFile.getData(Start,Length)');
    ArtifactData(i,:,:)=D(RecElectrodes+1,:);    
end

% 5. Read timing information for pulse on each electrode
Times=[];
NumberOfPulses=[];
StimElectrodesIndexes=[];
for i=StimElectrodes
    i
    TimesIndexes=find(MovieData(2:3:length(MovieData))==i);
    Times=[Times' MovieData(TimesIndexes*3-2)']';
    StimElectrodesIndexes=[StimElectrodesIndexes ones(1,length(TimesIndexes))*i];
    %NumberOfPulses=[NumberOfPulses length(TimesIndexes)];
end

% 6. Figure 1: raw traces from one electrode
%ElectrodeIndex=5;
TimeStart=2000; %in samples
TimeLength=1000;
figure(11);
clf;

%for each channel: dat = 20 raw traces; art - 20 raw artifact shapes; s1 -
%averages artifact shape
dat=reshape(Data(:,ElectrodeIndex,:),N,Length);
art=reshape(ArtifactData(:,ElectrodeIndex,:),N,Length);
s1=int16(mean(art));
StimElectrode=StimElectrodes(ElectrodeIndex);
RecElectrode=RecElectrodes(ElectrodeIndex);
%TimesIndexes=find(MovieData(2:3:length(MovieData))==StimElectrode);
%Times=MovieData(TimesIndexes*3-2);

s2=zeros(N,Length);
for j=1:N
    s2(j,:)=dat(j,:)-s1;
end

plot([1:Length],s2,'b-');
hold on;

% plot all stimulation pulses in black
for i=1:length(Times)
    T=Times(i);
    StEl=StimElectrodesIndexes(i);  
    shift=find(StimElectrodes==StEl);
    duration=2;
    x=[T-1 T T T+duration T+duration T+2*duration T+2*duration T+3*duration T+3*duration T+3*duration+1];
    A=[2 -3 1];
    y=[0 0 A(1) A(1) A(2) A(2) A(3) A(3) 0 0]+40+6*shift;
    h=plot(x,y);
    set(h,'LineWidth',2);    
    set(h,'Color','k');   
end

for i=1:length(StimElectrodes)
    for j=1:1000:20001
        text(j,40+6*i,[num2str(StimElectrodes(i)) '/' num2str(MovieNumbers(i))]);
    end
end

% plot stimulation pulses on this electrode in red
ThisElectrode=StimElectrodes(ElectrodeIndex);
ThisElectrodePulses=find(StimElectrodesIndexes==ThisElectrode);
ThisElectrodeTimings=Times(ThisElectrodePulses);
for i=1:length(ThisElectrodeTimings)
    T=ThisElectrodeTimings(i);
    StEl=StimElectrodesIndexes(i)
    duration=2;
    %Amplitude=NS_PulseAmplitude('E:\analysis\2010-07-29-0\data',22,[1:512],3)
    x=[T-1 T T T+duration T+duration T+2*duration T+2*duration T+3*duration T+3*duration T+3*duration+1];
    A=[2 -3 1];
    y=[0 0 A(1) A(1) A(2) A(2) A(3) A(3) 0 0]+40+6*ElectrodeIndex;
    h=plot(x,y);
    set(h,'LineWidth',2);
    set(h,'Color','r');    
end

h=gca;
grid on;
break







% 7. Scatter plot
figure(2);
clf;

YCoordinates=[0:1:1*(length(StimElectrodes)-1)];
for i=1:length(Times)
    T=Times(i);
    StEl=StimElectrodesIndexes(i);
    StElIndex=find(StimElectrodes==StEl);
    
    x=[T T];
    A=[-0.1 0.1];
    y=[-0.1 0.1]+YCoordinates(StElIndex);
    
    h=plot(x,y);
    set(h,'LineWidth',2);
    set(h,'Color','r');
    hold on;
end
      
%break;
s2=zeros(N,Length);
for i=3 %1:NumbersOfElectrodes    
    dat=reshape(Data(:,i,:),N,Length);
    art=reshape(ArtifactData(:,i,:),N,Length);
    s1=int16(mean(art)); %just averaged artifact shape on given electrode
    
    electrode=StimElectrodes(i);
    TimesIndexes=find(MovieData(2:3:length(MovieData))==electrode);
    Times=MovieData(TimesIndexes*3-2);
    
    %figure(Amplituda*100+5);
    %subplot(5,1,i);
    %plot(art');
    
    %figure(Amplituda*100+6);
    %subplot(5,1,i);
    %plot([1:Length],dat,'b-',Times,ones(1,length(Times))*50,'rd');
    
    for j=1:N
        s2(j,:)=dat(j,:)-s1;
    end
    
    figure(Amplituda*100+7);
    subplot(5,1,i);
    plot([1:Length],s2,'b-',Times,ones(1,length(Times))*50,'rd');
                
    TimesIndexes=find(MovieData(2:3:length(MovieData))==electrode);
    Times=MovieData(TimesIndexes*3-2);
            
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

% 8. Neuron 2
s3=s2+30;
znak=sign(s3);
break;
s=size(s3);
znaki=zeros(s);
figure(14)
clf;
for i=1:s(1)
    z=znak(i,:);
    znaki(i,:)=z;
    %figure(11)
    %ubplot(5,4,i)
    %plot(z,'bd-')
    %figure(12);
    %ubplot(5,4,i);
    %lot(diff(z),'bd-');
    figure(14)    
    k=find(diff(z)<0);
    %subplot(5,4,i);
    h=plot(k,[i],'bd');
    set(h,'MarkerSize',2);
    hold on;
end
h=gca;
set(h,'XLim',[0 20000]);