ChipAddresses=[30 31];
NumberOfChannelsPerChip=32;
CurrentRanges=[0.066 0.266 1.07 4.25 16.9 67.1 264 1040];
Fs=20000;
NS_GlobalConstants=struct('SamplingFrequency',Fs,'ChipAddresses',ChipAddresses,'NumberOfChannelsPerChip',NumberOfChannelsPerChip,'CurrentRanges',CurrentRanges);
ArrayID=1;

Channels=[1:64];
AmplitudeRange=[-100 100];
GoodChannels=NS_RemoveBadChannels(Channels,[4 9 25 31 57]);

cd H:\2010-09-21-0;
FileName='017';
WritePath='E:\pawel\analysis\retina\2010-09-21-0\data017';
WritePathFigs=WritePath;
FigureProperties=struct('FigureNumber',1,'Subplot',[2 3 3],'TimeRange',[0 40],'AmplitudeRange',[-100 100],'FontSize',20,'Colors',['g' 'r' 'b' 'm' 'k'],'LineWidth',1);
%[PDChunkNumber,MovieBegin,RepetNumber,RepetPeriod,ClusterFileName]=NS_PreprocessDataNew512v3(FileName,WritePath,WritePathFigs,FigureProperties,NS_GlobalConstants,1,[1:38],[5 10 17 19 27],[1:64]);
[PDChunkNumber,MovieBegin,RepetNumber,RepetPeriod]=NS_PreprocessData(FileName,WritePath,WritePathFigs,FigureProperties,NS_GlobalConstants,0);

cd H:\2010-09-21-0;
FileName='020';
WritePath='E:\pawel\analysis\retina\2010-09-21-0\data020';
WritePathFigs=WritePath;
FigureProperties=struct('FigureNumber',1,'Subplot',[2 3 3],'TimeRange',[0 40],'AmplitudeRange',[-100 100],'FontSize',20,'Colors',['g' 'r' 'b' 'm' 'k'],'LineWidth',1);
%[PDChunkNumber,MovieBegin,RepetNumber,RepetPeriod,ClusterFileName]=NS_PreprocessDataNew512v3(FileName,WritePath,WritePathFigs,FigureProperties,NS_GlobalConstants,1,[1:38],[5 10 17 19 27],[1:64]);
[PDChunkNumber,MovieBegin,RepetNumber,RepetPeriod]=NS_PreprocessData(FileName,WritePath,WritePathFigs,FigureProperties,NS_GlobalConstants,0);

break;

PatternNumber=22;
Movies=[7:1:25];
Channels=[1:64];
GoodChannels=NS_RemoveBadChannels(Channels,[4 9 25 31 57]);
AdditionalBadChannels=[];
GoodChannels=NS_RemoveBadChannels(GoodChannels,AdditionalBadChannels);
ClusterFileName='C:\home\pawel\nauka\analysis\2008-12-11-0\ClusterFile_000';
Responses=[];
tic
for PatternNumber=GoodChannels
    PatternNumber;
    a=NS_ApplyLinearArtifactModel(WritePath,PatternNumber,Movies,GoodChannels,0,0,ClusterFileName);
    Responses=[Responses' a']';
end
toc