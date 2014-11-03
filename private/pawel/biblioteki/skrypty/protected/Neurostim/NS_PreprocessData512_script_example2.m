ChipAddresses=[24:31];
NumberOfChannelsPerChip=64;
CurrentRanges=[0.066 0.266 1.07 4.25 16.9 67.1 264 1040];
Fs=20000;
NS_GlobalConstants=struct('SamplingFrequency',Fs,'ChipAddresses',ChipAddresses,'NumberOfChannelsPerChip',NumberOfChannelsPerChip,'CurrentRanges',CurrentRanges);
ArrayID=500;

FigureProperties=struct('FigureNumber',1,'Subplot',[2 3 3],'TimeRange',[0 40],'AmplitudeRange',[-50 50],'FontSize',20,'Colors',['g' 'r' 'b' 'm' 'k'],'LineWidth',1);

ChannelsToRead=[1:512];
numberOfElectrodesPerMovie=32;
NumberOfPattnerGroups=16; %32 electrodes/patterns in each movie
[NumberOfMovies,NumberOfPatternsPerMovie,AllPatternsUsed,Patterns]=NS512_MoviePatterns('G:\2010-09-11-0\movie005',NS_GlobalConstants);

FolderName='G:\2010-09-11-0';
DataFilename='003';
ArtifactFileName='005';

for i=1:NumberOfPattnerGroups
    DataMoviesToRead=[i:NumberOfPattnerGroups:223];
    ArtifactMoviesToRead=[i:NumberOfPattnerGroups:193];
    
    cd(FolderName);
    WritePath='D:\Home\Pawel\analysis\2010-09-11-0\data003';
    WritePathFigs=WritePath;
    [PDChunkNumber,MovieBegin,RepetNumber,RepetPeriod,ClusterFileName]=NS_PreprocessDataNew512v2(DataFilename,WritePath,WritePathFigs,ArrayID,FigureProperties,NS_GlobalConstants,0,DataMoviesToRead,[1:32],[1:512]);
    
    cd(FolderName);
    WritePath='D:\Home\Pawel\analysis\2010-09-11-0\data005';
    WritePathFigs=WritePath;
    [PDChunkNumber,MovieBegin,RepetNumber,RepetPeriod,ClusterFileName]=NS_PreprocessDataNew512v2(ArtifactFileName,WritePath,WritePathFigs,ArrayID,FigureProperties,NS_GlobalConstants,0,ArtifactMoviesToRead,[1:32],[1:512]);                
end