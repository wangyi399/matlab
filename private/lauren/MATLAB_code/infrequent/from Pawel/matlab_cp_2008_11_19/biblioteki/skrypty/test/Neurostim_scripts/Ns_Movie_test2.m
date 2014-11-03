ChipAddresses=[30 31];
NumberOfChannelsPerChip=32;
CurrentRanges=[0.066 0.266 1.07 4.25 16.9 67.1 264 1040];
Fs=20000;
NS_GlobalConstants=struct('SamplingFrequency',Fs,'ChipAddresses',ChipAddresses,'NumberOfChannelsPerChip',NumberOfChannelsPerChip,'CurrentRanges',CurrentRanges,'ArrayID',1);

RecElectrodes=[1:64];
BadElectrodes=[9 25 28 31 33 37 41 57 64];
RecElectrodes=NS_RemoveBadChannels(RecElectrodes,BadElectrodes);
RE=[1 3 4 6 7 11 12 14 15 17 18 21 22];
RecElectrodes=RE;
%cd C:\praca\data\2008-06-02-0;
cd D:\2008-06-02-0;
FileName='007';
paramsFile=edu.ucsc.neurobiology.vision.io.ParametersFile('D:\analysis\2008-06-02-0\VisionNeurons\data007\data007\data007000\data007000.params');
neuronFile = edu.ucsc.neurobiology.vision.io.NeuronFile('D:\analysis\2008-06-02-0\VisionNeurons\data007\data007\data007000\data007000.neurons');
%paramsFile=edu.ucsc.neurobiology.vision.io.ParametersFile('D:\analysis\2008-06-02-0\VisionNeurons\data000\data000\data000000\data000000.params');
%neuronFile = edu.ucsc.neurobiology.vision.io.NeuronFile('D:\analysis\2008-06-02-0\VisionNeurons\data000\data000\data000000\data000000.neurons');
idList = neuronFile.getIDList();
NeuronID=153;
spikeTimes = neuronFile.getSpikeTimes(NeuronID)';
Timings1=spikeTimes(1,1:min(1000,length(spikeTimes)))-14;
TimeRange=[0 50];
signal=NS_AverageTraces(FileName,Timings1,RecElectrodes,TimeRange,NS_GlobalConstants);
signal=(signal+370);
Offsets=ones(length(RecElectrodes))*(-370);

FigureProperties=struct('FigureNumber',64,'TimeRange',TimeRange,'AmplitudeRange',[-250 250],'FontSize',12,'Colors',['g' 'b' 'r' 'y']);
%h=NS_PlotManyTracesOnArrayLayout(signal,RecElectrodes,ones(1,length(RecElectrodes),1,FigureNumber,FigureProperties,NS_GlobalConstants);
s=zeros(1,length(RecElectrodes),51);
s(1,:,:)=signal';
WaveformTypes=ones(1,length(RecElectrodes));
y=NS_PlotManySignaturesOnArrayLayout(s,RecElectrodes,WaveformTypes,1,FigureProperties,NS_GlobalConstants);
%cd C:\praca\data\2008-06-02-0;%D:\2008-06-02-0;
ReadPath='C:\praca\data\2008-06-02-0';%'D:\2008-06-02-0';
WritePath='C:\pliki\';
TimeStart=80;
%FileName='010';
Traces=NS_ReadManyTracesFromRaw(FileName,RecElectrodes,Timings1,TimeStart,50,Offsets,NS_GlobalConstants);
[DiffEI]=NS_PlotDiffEIsOnArrayLayout(21,24,25,RecElectrodes,BadElectrodes,ReadPath,FileName,WritePath);

%EI=NS_CalculateEI(Traces);
FigureProperties=struct('FigureNumber',63,'TimeRange',TimeRange,'AmplitudeRange',[-400 400],'FontSize',12,'Colors',['g' 'b' 'r' 'y']);
M=NS_SaveMovieFromSignature(reshape(DiffEI,55,60),RecElectrodes,1,FigureProperties,NS_GlobalConstants);
%movie(M);