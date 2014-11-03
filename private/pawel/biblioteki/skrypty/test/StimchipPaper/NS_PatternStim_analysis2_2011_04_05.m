% DODAJEMY NEURON 856 - ROZGRZEBANE!!!
clear

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
StimElectrodes=[16 27 37 45 54  51 60];
RecElectrodes=[16 27 37 45 47 51 58];
NeuronsIDs=[227 391 541 616 691 736 856];

StimElectrodes=[60 27 37 45 54  51 16];
RecElectrodes=[58 27 37 45 47 51 16];
NeuronsIDs=[856 391 541 616 691 736 227];

AllStimElectrodes=[3 6 16 18 27 28 37 45 51 54 60 61];
PulsesNumbers=[10 22 18 19 19 16 26 20 21 23 25 21];

Amplitudes=[1 7 4 8 9 3 1 5]; %[1 6 3 7 8 3 1];
mnoznik=8;
Amplitudes=ones(1,8)*mnoznik;
%Amplitudes=[4 8 8 8 8 8 4];
SpikesThresholds=[100 45 40 28 50 30 40 45]; 
%SpikesThresholds=[80 45 40 28 50 30 40]; 

SpikeWidths=[4 3 3 2 4 4 2 4];
PulseWidth=4; %szerokosc impulsu stymulacyjnego
NumberOfElectrodes=length(StimElectrodes);

NumbersOfElectrodes=length(StimElectrodes);

DataPath='H:\2010-09-21-0\data017';
DataMovieFile='H:\2010-09-21-0\movie017';
ArtifactDataPath='H:\2010-09-21-0\data020';
ArtifactMovieFile='H:\2010-09-21-0\movie020';

ClusterFilesPath='E:\pawel\analysis\retina\2010-09-21-0\ClusterFiles_data017_copies\';

N=20;
Data=int16(zeros(N,length(RecElectrodes),Length));
ArtifactData=int16(zeros(N,Length));

Times=[];
NumberOfPulses=[];
StimElectrodesIndexes=[];

TimesForHist=zeros(NumbersOfElectrodes,1000);
IloscImpulsow=zeros(1,NumbersOfElectrodes);
%ElectrodeOrder=[1 2 5 6 4 7 3];
figure(101)
clf;
FigureYBottom=0.07;
FigureyTop=0.96;
FugyreYSize=FigureyTop-FigureYBottom;
subplot('position',[0.09 0.07 0.75 0.89]);
hold on;

Elektrody=[1:NumberOfElectrodes];
ElectrodeOrder=Elektrody
for i=Elektrody%1:NumberOfElectrodes
    StimElectrode=StimElectrodes(i)
    RecElectrode=RecElectrodes(i);
    NeuronID=NeuronsIDs(i);            
    MovieNumber=2+(Amplitudes(i)-1)*5;
    MovieData1=NS512_MovieData2(DataMovieFile,MovieNumber,NS_GlobalConstants);
    [PDChunkNumber,MovieBegin,RepetNumber,RepetPeriod,MovieData]=NS_DecodeMovieDataChunk(MovieData1);          
    
    TimesIndexes=find(MovieData(2:3:length(MovieData))==StimElectrode);
    Times0=MovieData(TimesIndexes*3-2);        
    PulsesNumber=length(TimesIndexes);
    
    for k=1:PulsesNumber
        PulseTime=Times0(k);
        h=plot([PulseTime PulseTime]/20,[780-ElectrodeOrder(i)*100 790-ElectrodeOrder(i)*100],'r-');
        set(h,'LineWidth',2);
    end
    
    ClusterFileName=['ClusterFile_ClusterFile_020_id' num2str(NeuronID)];
    ClusterIndexes=NS_ReadClusterFileAll([ClusterFilesPath '\' ClusterFileName]);
    
    
    for j=1:length(AllStimElectrodes)
        TimesIndexes=find(MovieData(2:3:length(MovieData))==AllStimElectrodes(j));
        Times0=MovieData(TimesIndexes*3-2);        
        PulsesNumber=length(TimesIndexes);
        
        for k=1:PulsesNumber
            PatternNumber=AllStimElectrodes(j)*100+k;
            Types=ClusterIndexes(MovieNumber,PatternNumber,:);
            PulseTime=Times0(k);
            
            for l=1:length(Types)
                if Types(l)==2
                    h=plot(PulseTime/20,700-ElectrodeOrder(i)*100+l*3.5,'bd');
                    %h=plot(PulseTime/20,[-i+0.2 -i+0.05],'bd');
                    set(h,'MarkerSize',5);
                end
            end
            
        end
    end       
end
h=gca;
set(h,'Box','off');
set(h,'LineWidth',LineWidth);
set(h,'FontSize',FontSize);
set(h,'XLim',[0 1000]);
%set(h,'FontSize',14);
set(h,'YLim',[90 700]);
set(h,'YTick',[]);
set(h,'YTickLabel','');
h=xlabel('Time [ms]');
NS_StimPatternAnalysis_dodatek2;

FullName=['C:\home\pawel\nauka\Stimchip_paper\obrazki\figure3_sameSF.tif'];            
h=gcf;
set(h,'PaperUnits','inches');
set(h,'PaperSize',[18.7 14]);
set(h,'PaperPosition',[0 0 18.7 14]); 
print(h, '-dtiff', '-r100', FullName);