FigureProperties=struct('FigureNumber',12,'Subplot',[2 3 3],'TimeRange',[0 50],'AmplitudeRange',[-100 50],'FontSize',12,'Colors',['k' 'r' 'b' 'm' 'g' 'c' 'y'],'LineWidth',1,'YLabel','signal [mV]');
DataPath='D:\Home\Rydygier\NEURO\files'; %sciezka do danych po preprocessingu
NS_GlobalConstants=NS_GenerateGlobalConstants(512);
%usun szumiace kanaly:
%BadChannels=[4 9 25 57];
Channels=[1:512];
%Channels=NS_RemoveBadChannels(Channels,BadChannels);

Patterns=[1:64]; %ktore patterny (zestawy elektrod) chcemy przeanalizowac, domyslnie [1:64]

WritePathFigsGood='D:\Home\Pawel\analysis\retina\2009-11-27-0\figures_good';
WritePathFigsBad='D:\Home\Pawel\analysis\retina\2009-11-27-0\figures_bad';

% !!!!!!!!

MinDelay=6; %valid for 50 us pulses, for 100 us should be 6 

% !!!!!!!!!!!
Movies=[1:151];
ArrayID=500;

for i=1:length(Patterns)
    PatternNumber=Patterns(i);
    [StimChannels,Amplitudes]=NS_StimulatedChannels(DataPath,PatternNumber,1,Channels,NS_GlobalConstants);
    [AmplitudesVsChannels,RMSVsChannels]=NS512_FindThresholdForLocalStimulation4PH(DataPath,WritePathFigsGood,WritePathFigsBad,PatternNumber,Movies,Channels,ArrayID,FigureProperties,NS_GlobalConstants,[],[MinDelay:40]); %7 to 76    
end