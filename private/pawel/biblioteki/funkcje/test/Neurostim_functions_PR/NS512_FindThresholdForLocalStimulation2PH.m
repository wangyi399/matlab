function [AmplitudesVsChannels,RMSVsChannelsAll]=NS512_FindThresholdForLocalStimulation2PH(DataPath,WritePathFigs,PatternNumber,Movies,Channels,ArrayID,FigureProperties,NS_GlobalConstants,MarkedChannels,Samples);
electrodeMap=edu.ucsc.neurobiology.vision.electrodemap.ElectrodeMapFactory.getElectrodeMap(ArrayID);
SpikesNumberThreshold=50;

ChannelsToRead=Channels;
AmplitudesVsChannels=[];
RMSVsChannelsAll = [];

N=7;
for MovieNumber=Movies
    [DataTraces0,ArtifactDataTraces,DataChannels]=NS_ReadPreprocessedData(DataPath,DataPath,0,PatternNumber,MovieNumber,0,0);                
    DataTracesFull=DataTraces0(1:100,[1:512],Samples);
    [TracesWithoutArtifact,Artifact,Events,ChannelsWithSpikes,SpikesTimings]=FindTracesClasses_PR2(DataTracesFull,ChannelsToRead,10,30); %output for may neurons
    display(ChannelsWithSpikes)
    %{
    s1=size(TracesWithoutArtifact)
    s2=size(Artifact)
    s3=size(Events)
    s4=size(ChannelsWithSpikes)
    s5=size(SpikesTimings)
    %}
    ChannelsWithSpikes
    for i=1:length(ChannelsWithSpikes)
        display(MovieNumber)        
        Channel=ChannelsWithSpikes(i);                
        WaveformTypes=Events(:,Channel);
        ST=SpikesTimings(:,i);
        
        ChannelsPlot = electrodeMap.getAdjacentsTo(Channel,1); % Elektrody sasiadujace z elektroda Channel (ta z wiecej niz 50 spikami)        
        [CorrectedTraces,EI,UniSpikesIndicCorrected]=NS512_TimingsForDetectedNeuron(TracesWithoutArtifact,WaveformTypes,ST,ChannelsPlot);                
        NS512_PlotDetectedSpikes(TracesWithoutArtifact,ChannelsPlot,WaveformTypes,CorrectedTraces,EI,WritePathFigs);       
        h=gcf;
        FullName=[WritePathFigs '\' 'p' num2str(PatternNumber) '_m' num2str(MovieNumber) '_el' num2str(Channel)];            
        set(h,'PaperUnits','inches');
        set(h,'PaperSize',[16 9]);
        set(h,'PaperPosition',[0 0 16 9]); 
        print(h, '-dtiff', '-r120', FullName);
    end
    ChannelsToRead=NS_RemoveBadChannels(ChannelsToRead,ChannelsWithSpikes);
end