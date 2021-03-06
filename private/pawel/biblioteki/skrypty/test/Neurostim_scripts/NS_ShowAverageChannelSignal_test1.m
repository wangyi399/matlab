ChipAddresses=[30 31];
NumberOfChannelsPerChip=32;

cd C:\praca\data\2008-02-04-0;
FileName='004';
CurrentRanges=[0.066 0.266 1.07 4.25 16.9 67.1 264 1040];
Fs=20000;

NS_GlobalConstants=struct('SamplingFrequency',Fs,'ChipAddresses',ChipAddresses,'NumberOfChannelsPerChip',NumberOfChannelsPerChip,'CurrentRanges',CurrentRanges);

%[CI,MI]=NS_Report(FileName,1,NS_GlobalConstants);

Channel=56;
MovieNumber=87;
TimeRange=[-20 60];

Limit=100;
AmplitudeRange=[-700 -500];
AdditionalChannels=[Channel+1];

[Timings,PDChunkIndex]=NS_FindPulsesTimingsForMovie(FileName,Channel,MovieNumber,NS_GlobalConstants);
[Pulse,Status]=NS_FindPulseShapeForMovie(FileName,Channel,MovieNumber,NS_GlobalConstants);
figure(1);
Amplitude=NS_PlotStimulationPulse(Pulse,Status,Channel,20,NS_GlobalConstants)

FigureNumber=22;
FigureProperties=struct('FigureNumber',FigureNumber,'TimeRange',TimeRange,'AmplitudeRange',AmplitudeRange,'FontSize',13,'Colors',['k' 'r' 'b' 'y']);

size(Timings)
%Timings=Timings(1,120:124);
Delay=1;
WaveformTypes=ones(1,length(Timings));
%WaveformTypes([8 25 26 60 74 79 81])=0;
WaveformTypes([5 8 14 26 45 62 63 69 72 73 79 82 95 97 103 106 116 124 130 142])=0;
y=NS_PlotManyTracesOnFigure(FileName,Timings,WaveformTypes,Channel,FigureProperties,Delay,NS_GlobalConstants);

Channels=[53:56 58:62];
%Channels=[1:64];
a=find(WaveformTypes==1);
signal1=NS_AverageTraces(FileName,Timings(a),Channels,TimeRange,NS_GlobalConstants);
a=find(WaveformTypes==0);
signal2=NS_AverageTraces(FileName,Timings(a),Channels,TimeRange,NS_GlobalConstants);

FigureProperties=struct('TimeRange',TimeRange,'AmplitudeRange',[-100 100],'FontSize',11,'Colors',['g' 'b' 'r' 'y']);
OffsetCancellation=2;
OffsetSamples=[1:-TimeRange(1)-1];
WaveformTypes=ones(1,length(Timings));
WaveformTypes(1,Channel)=2;
WaveformTypes([9 25 57 41 64 28 37])=0; %noisy electrodes
y=NS_PlotTracesOnArrayLayout(signal1'-signal2',Channels,WaveformTypes,OffsetCancellation,OffsetSamples,1,32,FigureProperties,NS_GlobalConstants);

Channels=[31 32 33 36 47 54];
signal2=NS_AverageTraces(FileName,Timings(a),Channels,TimeRange,NS_GlobalConstants);

figure(45);
spectrum=NS_PlotMultipleSpectrumsOnFigure(signal2',FigureProperties,NS_GlobalConstants);

Timings=Timings(1,1:min(1000,length(Timings)));
%NS_PlotManyTracesOnArrayLayout(FileName,Channels,Timings,1,14,FigureProperties,NS_GlobalConstants);