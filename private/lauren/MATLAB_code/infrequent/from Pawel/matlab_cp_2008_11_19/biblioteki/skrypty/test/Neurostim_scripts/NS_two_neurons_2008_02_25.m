ChipAddresses=[30 31];
NumberOfChannelsPerChip=32;

%cd E:\2008-02-19-1;
cd C:\praca\data\2008-02-19\2008-02-19-1;
FileName='013';
CurrentRanges=[0.066 0.266 1.07 4.25 16.9 67.1 264 1040];
Fs=20000;

NS_GlobalConstants=struct('SamplingFrequency',Fs,'ChipAddresses',ChipAddresses,'NumberOfChannelsPerChip',NumberOfChannelsPerChip,'CurrentRanges',CurrentRanges);

%[CI,MI]=NS_Report(FileName,1,NS_GlobalConstants);

MovieNumber=17;
TimeRange=[-10 70];
Limit=100;
RecChannel=13;
Channels=[RecChannel];
Channels=[7 10 11 13 14 16 18 19];

[Pulse,Status]=NS_FindPulseShapeForMovie(FileName,11,MovieNumber,NS_GlobalConstants);
figure(51);
subplot(4,1,1);
Amplitude=NS_PlotStimulationPulsesTrain(Pulse,Status,11,100,400,4,20,'r-',NS_GlobalConstants);
gca;
axis([-5 75 -0.6 0.6]);
%grid off;
[Pulse2,Status]=NS_FindPulseShapeForMovie(FileName,16,MovieNumber,NS_GlobalConstants);
subplot(4,1,2);
Amplitude=NS_PlotStimulationPulsesTrain(Pulse2,Status,16,100,400,4,20,'b-',NS_GlobalConstants);
gca;
axis([-15 65 -1 1]);
%grid off;

Channel=11;
[Timings11,PDChunkIndex]=NS_FindPulsesTimingsForMovie(FileName,Channel,MovieNumber,NS_GlobalConstants);
Timings=Timings11(1,1:Limit)
WaveformTypes([13 14 17 25 26 27 32 33 34 39 40 44 47 49 52 53 54 57 59 60 65 66 67 72 73 77 78 86 87 88 91 92 93 94 95 98 99])=0; %channel 11
a11=[13 14 17 25 26 27 32 33 34 39 40 44 47 49 52 53 54 57 59 60 65 66 67 72 73 77 78 86 87 88 91 92 93 94 95 98 99]; %channel 11
artifact11=NS_AverageTraces(FileName,Timings(a11),Channels,TimeRange,NS_GlobalConstants); % artifact connected tu pulse on channel 11
artifact11=artifact11-mean(artifact11(1:-TimeRange(1)-2));
figure(11);
plot(artifact11);

Channel=16;
[Timings16,PDChunkIndex]=NS_FindPulsesTimingsForMovie(FileName,Channel,MovieNumber,NS_GlobalConstants);
Timings=Timings16(1,1:Limit);
a16=[47 48 61 78 79 80 88 89 90 91 92 93];
artifact16=NS_AverageTraces(FileName,Timings(a16),Channels,TimeRange,NS_GlobalConstants); % artifact connected tu pulse on channel 11
artifact16=artifact16-mean(artifact16(1:-TimeRange(1)-2));
figure(16);
plot(artifact16);

Channel=60;
[Timings60,PDChunkIndex]=NS_FindPulsesTimingsForMovie(FileName,Channel,MovieNumber,NS_GlobalConstants);
Timings=Timings60(1,1:Limit);
a=[1:100];
artifact60=NS_AverageTraces(FileName,Timings(a),Channels,TimeRange,NS_GlobalConstants); % artifact connected tu pulse on channel 11
artifact60=artifact60-mean(artifact60(1:-TimeRange(1)-2));
figure(60);
plot(artifact60);

%RecChannel=11;
TimeStart=14210100;
TimeLength=100000;
t=[1:TimeLength]/20;
%rawFile=edu.ucsc.neurobiology.vision.io.RawDataFile('D:\2008-02-19\2008-02-19-1\data013');
rawFile=edu.ucsc.neurobiology.vision.io.RawDataFile('C:\praca\data\2008-02-19\2008-02-19-1\data013');
data = rawFile.getData(TimeStart+1,TimeLength);
SignalTrace=zeros(1,TimeLength);
SignalTrace=double(data(:,RecChannel+1)');
clear data;
figure(1)
plot(t,SignalTrace);

Timings11a=Timings11+TimeRange(1)-TimeStart;
%Timings11=Timings11(1,1:400);
%SignalTrace=NS_SubtractArtifact(SignalTrace,artifact11',Timings11a);
Timings16a=Timings16+TimeRange(1)-TimeStart;
%SignalTrace=NS_SubtractArtifact(SignalTrace,artifact16',Timings16a);
Timings60=Timings60+TimeRange(1)-TimeStart;
%SignalTrace=NS_SubtractArtifact(SignalTrace,artifact60',Timings60);

figure(51);
subplot(2,1,2)
%SignalTrace-mean(SignalTrace(1:-TimeRange(1)-2)))
%plot(t,(SignalTrace-mean(SignalTrace(1:-TimeRange(1)-2))));
plot(t,(SignalTrace-mean(SignalTrace(60:90))),'k-');
axis([490 570 -70 80]);
grid on;
h=gca;
set(h,'FontSize',13);
xlabel('time [ms]');
ylabel('output signal [mV]');

FigureNumber=22;
FigureProperties=struct('FigureNumber',FigureNumber,'TimeRange',TimeRange,'AmplitudeRange',[-800 -400],'FontSize',13,'Colors',['k' 'r' 'b' 'y']);

size(Timings);

Delay=0;
WaveformTypes=ones(1,length(Timings));

%WaveformTypes([13 14 17 25 26 27 32 33 34 39 40 44 47 49 52 53 54 57 59 60 65 66 67 72 73 77 78 86 87 88 91 92 93 94 95 98 99])=0; %channel 11
%WaveformTypes([47 48 61 78 79 80 88 89 90 91 92 93])=0; %channel 16;
WaveformTypes([])=0;

y=NS_PlotManyTracesOnFigure(FileName,Timings,WaveformTypes,Channel,2,[1:10],FigureProperties,Delay,NS_GlobalConstants);
%y=NS_PlotManyTracesOnFigure(FileName,Timings,WaveformTypes,Channel,2,[1:10],FigureProperties,Delay,NS_GlobalConstants);

%Channels=[58:60]; %for channel 11
%Channels=[1:64];
a=find(WaveformTypes==1);
signal1=NS_AverageTraces(FileName,Timings(a),Channels,TimeRange,NS_GlobalConstants);
a=find(WaveformTypes==0)
signal2=NS_AverageTraces(FileName,Timings(a),Channels,TimeRange,NS_GlobalConstants);

FigureProperties=struct('TimeRange',TimeRange,'AmplitudeRange',[-400 200],'FontSize',11,'Colors',['g' 'b' 'r' 'y']);
OffsetCancellation=2;
OffsetSamples=[1:-TimeRange(1)-1];
WaveformTypes=ones(1,length(Timings));
WaveformTypes(1,Channel)=2;
WaveformTypes([9 25 57 41 64 28 37])=0; %noisy electrodes
%y=NS_PlotTracesOnArrayLayout(signal1',Channels,WaveformTypes,OffsetCancellation,OffsetSamples,1,32,FigureProperties,NS_GlobalConstants);

figure(66);
clf;
Limit2=[45:94];
exclude=73;
Limit2=[45:exclude-1 exclude+1:95];
%Limit2=[1:100];
ArtifactCancellation=1;

Timings=Timings11(1,Limit2);
WaveformTypes=ones(1,Limit);
WaveformTypes(a11)=0;
WaveformTypes=WaveformTypes(1,Limit2);
ArrayID=1;
%TimeRange=[-10 60];
FigureProperties=struct('FigureNumber',FigureNumber,'TimeRange',TimeRange,'AmplitudeRange',[-200 100],'FontSize',20,'Colors',['k' 'r' 'b' 'y']);
h=NS_PlotManyTracesOnArrayLayoutOld(FileName,Channels,Timings,WaveformTypes,ArtifactCancellation,ArrayID,66,FigureProperties,NS_GlobalConstants);
%break;
Timings=Timings16(1,Limit2);
WaveformTypes=ones(1,Limit)*2;
WaveformTypes(a16)=0;
WaveformTypes=WaveformTypes(1,Limit2);
h=NS_PlotManyTracesOnArrayLayoutOld(FileName,Channels,Timings,WaveformTypes,ArtifactCancellation,ArrayID,66,FigureProperties,NS_GlobalConstants);