% 2011-04-12: dodajemy oszacowanie dokladnych czasow spikow i histogramy
%clear

ChipAddresses=[24:31];
NumberOfChannelsPerChip=64;
CurrentRanges=[0.066 0.266 1.07 4.25 16.9 67.1 264 1040];
Fs=20000;
NS_GlobalConstants=struct('SamplingFrequency',Fs,'ChipAddresses',ChipAddresses,'NumberOfChannelsPerChip',NumberOfChannelsPerChip,'CurrentRanges',CurrentRanges);
electrodeMap=edu.ucsc.neurobiology.vision.electrodemap.ElectrodeMapFactory.getElectrodeMap(1);

Length=40000;
FontSize=20;
FontSize2=16;
LineWidth=2;
%For neuron 6 (el. 61) must look for spikes smaller than 60!!; for
%electrode 37: make sure we do not capture some other spikes
StimElectrodes=[16 60 27 37 45 54  51];
RecElectrodes=[16 58 27 37 45 47 51];
NeuronsIDs=[227 856 391 541 616 691 736 406];

AllStimElectrodes=[3 6 16 18 27 28 37 45 51 54 60 61];
PulsesNumbers=[10 22 18 19 19 16 26 20 21 23 25 21];

mnoznik=8;
Amplitudes=ones(1,8)*mnoznik;
SpikesThresholds=[45 100 45 40 28 50 30 40 30]; 
ThresholdsForJitter=[40 40 30 30 40 10 30 25];
SpikeWidths=[5 6 4 3 3 9 3];

ThresholdsForJitter2=[60 45 30 40 20 70 40];

ThresholdsForJitter2=ThresholdsForJitter;

PulseWidth=4; %szerokosc impulsu stymulacyjnego
NumberOfElectrodes=length(StimElectrodes);

NumbersOfElectrodes=length(StimElectrodes);

%DataPath=[DrivePath '2010-09-21-0\data017'];
%DataMovieFile=[DrivePath '2010-09-21-0\movie017'];
%ArtifactDataPath=[DrivePath '2010-09-21-0\data020'];
%ArtifactMovieFile=[DrivePath '2010-09-21-0\movie020'];

%ClusterFilesPath=[DrivePath 'analysis\2010-09-21-0\ClusterFiles_data017_copies'];

DataPath='C:\home\Pawel\nauka\StimchipPaper\2012grudzien\dyskusje\raw_data\data017';
DataMovieFile='C:\home\Pawel\nauka\StimchipPaper\2012grudzien\dyskusje\raw_data\movie017';
ArtifactDataPath='C:\home\Pawel\nauka\StimchipPaper\2012grudzien\dyskusje\raw_data\data017';
ArtifactMovieFile='C:\home\Pawel\nauka\StimchipPaper\2012grudzien\dyskusje\raw_data\movie020';

ClusterFilesPath='C:\home\Pawel\nauka\StimchipPaper\2012grudzien\dyskusje\data017_2';

N=20;
%N=4;
Data=int16(zeros(N,length(RecElectrodes),Length));
ArtifactData=int16(zeros(N,Length));

rawFile=edu.ucsc.neurobiology.vision.io.RawDataFile(DataPath);
rawArtFile=edu.ucsc.neurobiology.vision.io.RawDataFile(ArtifactDataPath);

Times=[];
NumberOfPulses=[];
StimElectrodesIndexes=[];

TimesForHist=zeros(NumbersOfElectrodes,1000);
IloscImpulsow=zeros(1,NumbersOfElectrodes);
%ElectrodeOrder=[1 2 5 6 4 7 3];
figure(104)
clf;
FigureYBottom=0.07;
FigureyTop=0.96;
FugyreYSize=FigureyTop-FigureYBottom;
subplot('position',[0.1 0.06 0.73 0.89]);
hold on;

Elektrody=[1:NumberOfElectrodes];
ElectrodeOrder=Elektrody

% * Estimate the artifact - in one step for 40000 samples and all the
% channels
ArtifactData=zeros(N,length(RecElectrodes),Length);
for Repetition=1:N
    Repetition
    for i=Elektrody
        RecElectrode=RecElectrodes(i);
        MovieNumber=2+(Amplitudes(i)-1)*5;
                
        MovieData1=NS512_MovieData2(ArtifactMovieFile,MovieNumber,NS_GlobalConstants);
        [PDChunkNumber,MovieBegin,RepetNumber,RepetPeriod,MovieData]=NS_DecodeMovieDataChunk(MovieData1);          
        ArtifactMovieBegin=MovieBegin;
        Start=ArtifactMovieBegin+(Repetition-1)*Length;
    
        D=int16(rawArtFile.getData(Start,Length)');
        ArtifactData(Repetition,i,:)=D(RecElectrode+1,:);
    end
end
ArtifactShape=reshape(mean(ArtifactData),length(RecElectrodes),Length);

% * Read in the raw data and subtract the artifact
Data=zeros(N,length(RecElectrodes),Length);
for Repetition=1:N
    Repetition
    for i=Elektrody
        RecElectrode=RecElectrodes(i);
        MovieNumber=2+(Amplitudes(i)-1)*5;
                
        MovieData1=NS512_MovieData2(DataMovieFile,MovieNumber,NS_GlobalConstants);
        [PDChunkNumber,MovieBegin,RepetNumber,RepetPeriod,MovieData]=NS_DecodeMovieDataChunk(MovieData1);          
        DataMovieBegin=MovieBegin;
        Start=DataMovieBegin+(Repetition-1)*Length;
    
        D=double(rawFile.getData(Start,Length)');
        Data(Repetition,i,:)=D(RecElectrode+1,:)-ArtifactShape(i,:);
    end
end
    
% tutaj
%ThresholdsForJitter=[40 30 30 40 10 30 40];

for i=[2:7]%Elektrody    
    T=[];
    StimElectrode=StimElectrodes(i);
    RecElectrode=RecElectrodes(i);
    NeuronID=NeuronsIDs(i);            
    MovieNumber=2+(Amplitudes(i)-1)*5;
    
    MovieData1=NS512_MovieData2(DataMovieFile,MovieNumber,NS_GlobalConstants);
    [PDChunkNumber,MovieBegin,RepetNumber,RepetPeriod,MovieData]=NS_DecodeMovieDataChunk(MovieData1);          
    %DataMovieBegin=MovieBegin;
    
    MovieData1=NS512_MovieData2(ArtifactMovieFile,MovieNumber,NS_GlobalConstants);
    [PDChunkNumber,MovieBegin,RepetNumber,RepetPeriod,MovieData]=NS_DecodeMovieDataChunk(MovieData1);          
    %ArtifactMovieBegin=MovieBegin;
    
    TimesIndexes=find(MovieData(2:3:length(MovieData))==StimElectrode);
    Times0=MovieData(TimesIndexes*3-2);        
    PulsesNumber=length(TimesIndexes);
    IloscImpulsow(i)=PulsesNumber*N;
    
    % Plotting the red lines that mark the stimulation pulses timings
    for k=1:PulsesNumber
        PulseTime=Times0(k);
        h=plot([PulseTime PulseTime]/20,[780-ElectrodeOrder(i)*90 790-ElectrodeOrder(i)*90],'r-');
        set(h,'LineWidth',2);
    end
    
    % Reading the information in the cluster file for given neuron
    ClusterFileName=['ClusterFile_ClusterFile_020_id' num2str(NeuronID)];
    ClusterIndexes=NS_ReadClusterFileAll([ClusterFilesPath '\' ClusterFileName]);
    
    DataForNeuron=reshape(Data(:,i,:),N,Length);
    
    % Find precise timing of the stimulated pulses
        
    for j=1:length(AllStimElectrodes)                  
        TimesIndexes=find(MovieData(2:3:length(MovieData))==AllStimElectrodes(j));
        Times0=MovieData(TimesIndexes*3-2);        
        PulsesNumber=length(TimesIndexes);
        
        for k=1:PulsesNumber                        
            PatternNumber=AllStimElectrodes(j)*100+k;
            Types=ClusterIndexes(MovieNumber,PatternNumber,:);
            PulseTime=Times0(k);
            
            IloscSpikow=length(find(Types==2));
            
            if IloscSpikow>0 % jesli                            
                for l=1:length(Types)
                    if Types(l)==2                       
                       if AllStimElectrodes(j)==StimElectrode
                           Thresh=ThresholdsForJitter2(i);
                       else
                           Thresh=ThresholdsForJitter(i);
                       end
                        Waveform=DataForNeuron(l,Times0(k)+4:Times0(k)+50)+Thresh;
                       %plot(Waveform)
                       %hold on;
                       znak=sign(Waveform);
                       SpikeTimesPos=find(diff(znak)>0); %przekroczenie progu "w gore" - czyli szukamy drugiego zbocza spika: potrzebne do wyznaczenia jittera; jesli uzywa sie tych wartosci, trzeba czas spika skorygowac o wartosc szerokosci impulsu
                       SpikeTimesNeg=find(diff(znak)<0);
                                            
                       kl=find(SpikeTimesPos>6);
                       %if 
                       PulseTime=Times0(k)+SpikeTimesPos(kl(1));
                       if AllStimElectrodes(j)==StimElectrode
                           T=[T SpikeTimesPos(kl(1))];
                       end
                       h=plot(PulseTime/20,700-ElectrodeOrder(i)*100+l*3.5,'bd');
                       set(h,'MarkerSize',5);
                    end
                end
            end            
        end  
        TimesForHist(i,1:length(T))=T;
    end       
end

TimesForHist(5,21:40)=0;
IloscImpulsow(5)=IloscImpulsow(5)-20;
auiergheriugh2;

% koniec tutaj

h=gca;
set(h,'Box','off');
set(h,'LineWidth',LineWidth);
set(h,'FontSize',FontSize);
set(h,'XLim',[0 1000]);
%set(h,'FontSize',14);
set(h,'YLim',[90 700]);
set(h,'YLim',[-10 700]);
set(h,'YTick',[]);
set(h,'YTickLabel','');
h=xlabel('Time [ms]');
NS_StimPatternAnalysis_dodatek_seven_neurons2;

break;
% histogramy:
for i=1:6
    h=subplot('position',[0.885,0.95-i*0.145,0.10,0.11]);    
    %h=subplot('position',[0.885,0.95-i*0.145,0.10,0.11]);    
    set(h,'LineWidth',2);
    
    ghj=TimesForHist(i,:);
    T1=find(ghj>0);
    %T1=find(TimesForHist(i,:))~=0;
    T2=TimesForHist(i,T1)-SpikeWidths(i);
    po=hist(T2/20,[1:1:25]/20);
    bar([1:25]/20,po/sum(po)*100,1);
    
    h=gca;
    set(h,'Box','off');
    set(h,'LineWidth',2);
    set(h,'YLim',[0 80]);
    set(h,'YTick',[0:20:80]);
    %set(h,'YTickLabel',[0:1:3]);
    %h=ylabel('p [%]');
    set(h,'FontSize',FontSize);
    set(h,'XLim',[0.2 1.0]);        
    set(h,'XTick',[0.2:0.05:1.0]);
    if i==6
        %set(h,'XTickLabel',{'0.2' '' '' '' '' '' '0.5' '' '' '' '' '' '0.8' '' '' '' '' '' '1.1'});
        set(h,'XTickLabel',{'' '' '0.0' '' '' '' '' '' '0.3' '' '' '' '' '' '0.6' '' ''});
        xlabel('Spike delay [ms]');
    else
        set(h,'XTickLabel','');
    end
            
    h=ylabel('p [%]');
    
    h=text(0.5,74,['\tau=' num2str(round(mean(T2)*50-300)) '\mus']);
    set(h,'FontSize',FontSize);
    
    h=text(0.5,52,['\sigma=' num2str(round(std(T2)*50)) '\mus']);
    set(h,'FontSize',FontSize);
    
    p=length(T1)/IloscImpulsow(i)*100;
    h=text(0.5,30,['\epsilon=' num2str(p, '%10.1f') '%']);
    set(h,'FontSize',FontSize);
end
%auiergheriugh2
break
FullName=['C:\home\Pawel\nauka\StimchipPaper\2012grudzien\dyskusje\figure5_7neurons.tif'];            
h=gcf;
set(h,'PaperUnits','inches');
set(h,'PaperSize',[18.7 13.5]);
set(h,'PaperPosition',[0 0 18.7 13.5]); 
%set(h,'PaperPosition',[0 0 10.7 13.5]); 
print(h, '-dtiff', '-r200', FullName);