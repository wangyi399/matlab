function [AmplitudesVsChannels, RMSVsChannelsAll ] = NS512_FindThresholdForLocalStimulationPH(DataPath,WritePathFigs,PatternNumber,Movies,Channels,ArrayID,FigureProperties,NS_GlobalConstants,MarkedChannels,Samples);
electrodeMap=edu.ucsc.neurobiology.vision.electrodemap.ElectrodeMapFactory.getElectrodeMap(ArrayID);
SpikesNumberThreshold=50;

ChannelsToRead=Channels;
AmplitudesVsChannels=[];
RMSVsChannelsAll = [];

N=7;
for MovieNumber=Movies
    [DataTraces0,ArtifactDataTraces,DataChannels]=NS_ReadPreprocessedData(DataPath,DataPath,0,PatternNumber,MovieNumber,0,0);                
    DataTracesFull=DataTraces0(1:100,[1:512],Samples);
    [TracesWithoutArtifact,Artifact,Events,ChannelsWithSpikes,SpikesTimings] = FindTracesClasses_PR2(DataTracesFull,ChannelsToRead,10,15); %output for may neurons
    s1=size(TracesWithoutArtifact)
    s2=size(Artifact)
    s3=size(Events)
    s4=size(ChannelsWithSpikes)
    s5=size(SpikesTimings)

    

    for i=1:length(ChannelsWithSpikes)
        Channel=ChannelsWithSpikes(i);                
        WaveformTypes=Events(:,Channel);
        ST=SpikesTimings(:,i);
        
        ChannelsPlot = electrodeMap.getAdjacentsTo(Channel,1)
        
        size(SpikesTimings)
        [TimeCorelSpikes,SpikeUnif,MeanSpike]=NS512_TimingsForDetectedNeuron(TracesWithoutArtifact,SpikesTimings,ChannelsPlot);
                                              
        %ChannelsPlot = electrodeMap.getAdjacentsTo(Channel,1); % Elektrody sasiadujace z elektroda Channel (ta z wiecej niz 50 spikami)                        
        %PlotMultiElectrodes(TracesWithoutArtifact, ChannelsPlot, WaveformTypes, TimeCorelSpikes);
                        
        %{
        for i=1:length(ChannelsPlot)           
            if ChannelsPlot(i) 
            ChannelTraces = TracesWithoutArtifact(:,ChannelsPlot(i),:); %przebiegi na elektrodzie o numerze Channel lub sasiadach
            SCT=size(ChannelTraces);
            ChannelTraces2D = reshape(ChannelTraces,SCT(1),SCT(3));
            
            subplot(1,N,i), h= plot(ChannelTraces2D');
            text(20,-80,num2str(ChannelsPlot(i)),'Fontsize',16);
            set(h(artifactsIndex),'Color','Black');
            set(h(spikeIndex),'Color','Red');
            axis([0 40 -100 50]);
            grid on;
            h23=gca;
            set(h23, 'XTick', [0:5:40]);
            set(h23, 'YTick', [-100:20:40]);
            end
        
        end
        %}        
        
    end
end