FigureProperties=struct('FigureNumber',12,'Subplot',[2 3 3],'TimeRange',[0 50],'AmplitudeRange',[-100 50],'FontSize',12,'Colors',['k' 'r' 'b' 'm' 'g' 'c' 'y'],'LineWidth',1,'YLabel','signal [mV]');
DataPath='D:\Home\Pawel\analysis\2010-09-21-0\data003'; %sciezka do danych po preprocessingu

[DataTraces0,ArtifactDataTraces,DataChannels]=NS_ReadPreprocessedData(DataPath,DataPath,0,PatternNumber,MovieNumber,0,0); 
[DataTraces0,ArtifactDataTraces,DataChannels]=NS_ReadPreprocessedData(DataPath,DataPath,0,4,7,0,0);                  

break;
%usun szumiace kanaly:
BadChannels=[4 9 25 57];
Channels=[1:64];
Channels=NS_RemoveBadChannels(Channels,BadChannels);

Patterns=Channels; %ktore patterny (zestawy elektrod) chcemy przeanalizowac, domyslnie [1:64]

WritePathFigsGood='D:\Home\Pawel\analysis\2010-09-21-0\proba\figures_good';
WritePathFigsBad='D:\Home\Pawel\analysis\2010-09-21-0\proba\figures_bad';

% !!!!!!!!

MinDelay=6; %valid for 50 us pulses, for 100 us should be 6 

% !!!!!!!!!!!

for i=1:length(Patterns)
    PatternNumber=Patterns(i);
    [StimChannels,Amplitudes]=NS_StimulatedChannels(DataPath,PatternNumber,1,[1:64],NS_GlobalConstants);
    [AmplitudesVsChannels,RMSVsChannels]=NS512_FindThresholdForLocalStimulation4PH(DataPath,WritePathFigsGood,WritePathFigsBad,PatternNumber,Movies,Channels,ArrayID,FigureProperties,NS_GlobalConstants,StimChannels,[MinDelay:40]); %7 to 76    
    [Events,RealChannelsWithSpikes,Thresholds]=NS512_FindThresholdForAxonalStimulation3PH(DataPath,ArtifactDataPath,WritePathFigsGood,WritePathFigsBad,PatternNumber,Movies,Channels,ArrayID,FigureProperties,NS_GlobalConstants,MarkedChannels,Samples);
end