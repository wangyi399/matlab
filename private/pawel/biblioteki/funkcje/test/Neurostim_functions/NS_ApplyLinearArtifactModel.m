function Responses=NS_ApplyLinearArtifactModel(DataPath,PatternNumber,Movies,GoodChannels,TracesNumberLimit,EventNumber,ClusterFileName);

NS_GlobalConstants=NS_GenerateGlobalConstants(61);
currentRanges = NS_GlobalConstants.CurrentRanges;
Channels=[1:64];
%Channels=NS_RemoveBadChannels(GoodChannels,PatternNumber);

Amplitudes=Movies;

Amplitudes(1)=NS_StimulationAmplitude(DataPath,PatternNumber,Movies(1),Channels,NS_GlobalConstants);
[DataTraces,ArtifactDataTraces,Channels]=NS_ReadPreprocessedData(DataPath,DataPath,0,PatternNumber,Movies(1),0,0);
Art1=mean(DataTraces);

Amplitudes(2)=NS_StimulationAmplitude(DataPath,PatternNumber,Movies(2),Channels,NS_GlobalConstants);
if Amplitudes(2)==Amplitudes(1)
    error('The first two amplititudes are identical!')
end
[DataTraces,ArtifactDataTraces,Channels]=NS_ReadPreprocessedData(DataPath,DataPath,0,PatternNumber,Movies(2),0,0);
Art2=mean(DataTraces);

A1=Amplitudes(1);
A2=Amplitudes(2);

Samples=[11:70];
Threshold=30;

Responses=[];

for i=3:length(Movies)   
    MovieNumber=Movies(i);
    [DataTraces,ArtifactDataTraces,Channels]=NS_ReadPreprocessedData(DataPath,DataPath,0,PatternNumber,MovieNumber,0,0);    
    SD=size(DataTraces);
    DataTracesFinal=zeros(SD(1),SD(2),SD(3));
    
    A=NS_StimulationAmplitude(DataPath,PatternNumber,MovieNumber,Channels,NS_GlobalConstants);
    %a=A2;
    %b=A1;
    Art=Art2+(A-A2)/(A2-A1)*(Art2-Art1);
    
    for j=1:SD(1)
        DataTracesFinal(j,:,:)=DataTraces(j,:,:)-Art;                   
    end     
    
    FigureProperties=struct('FigureNumber',12,'Subplot',[2 3 3],'TimeRange',[0 65],'AmplitudeRange',[-30 30],'FontSize',16,'Colors',['k' 'r' 'b' 'm' 'g' 'c' 'y'],'LineWidth',1,'YLabel','signal [mV]');
    WaveformTypes=ones(1,SD(1));
    
    if A~=A2        
        Art1Old=Art1; %just for tests!!
        Art2Old=Art2;
        A1=A2;
        A2=A;        
        Art1=Art2;        
        Art2=mean(DataTraces);
    end        
    
    GoodChannels2=NS_RemoveBadChannels(GoodChannels,PatternNumber);
    x=DataTracesFinal(:,GoodChannels2,Samples);
    %y=NS_PlotClustersOfSignaturesOnArrayLayout(x,GoodChannels2,WaveformTypes,1,FigureProperties,NS_GlobalConstants);

    [mins,indexes]=min(x,[],3);    
    [Events,Electrodes]=find(mins<-Threshold);

    Counts=histc(Electrodes,[1:512]);
            
    EventsFinal=unique(Events); %so each event is count only once, even if the spike exceeds threshold on more than opne electrode
    
    if length(EventsFinal)>10
    PN=PatternNumber
    MN=MovieNumber
    ilosc=length(EventsFinal)
    elektrody=unique(GoodChannels2(Electrodes))
        
    BestElectrodes=GoodChannels2(find(Counts==max(Counts)));
    PrimaryRecordingElectrode=BestElectrodes(1);
    ElectrodesFinal=GoodChannels2(unique(Electrodes));
    WaveformTypes=ones(1,SD(1));
    Responses=[PatternNumber MovieNumber PrimaryRecordingElectrode];
    %Responses=[Responses a];
        %smins=size(mins)
        %sev=size(event)        
        %PatternNumber

        %electrodes=GoodChannels2(unique(electrode))
        %ElNumber=50;
        %b=reshape(DataTracesFinal(:,electrodes(1),Samples),SD(1),length(Samples));
        %b=reshape(DataTracesFinal(:,ElNumber,Samples),SD(1),length(Samples));

        %figure(1);
        %plot(b');
        %axis([0 70 -240 240]);
        %grid on;
        
        %figure(2);
        %size(Art1)
        %size(Art2)
        %nn=Art1Old(1,ElNumber,Samples);        
        %size(nn)
        %plot(reshape(nn,1,length(Samples)));
        
        %figure(3);
        %nn=Art2Old(1,ElNumber,Samples);        
        %size(nn)
        %plot(reshape(nn,1,length(Samples)));        
        
        %pause(1);          
                
        WaveformTypes(EventsFinal)=2;
        header=NS_SaveClusterFile(ClusterFileName,PatternNumber,Movies(i),WaveformTypes);
        break;
    end        
        %pause(3);
end