ChipAddresses=[30 31];
NumberOfChannelsPerChip=32;

%cd C:\praca\data\2008-02-04-0;
cd C:\praca\data\2008-02-19\2008-02-19-1;
CurrentRanges=[0.066 0.266 1.07 4.25 16.9 67.1 264 1040];
Fs=20000;

NS_GlobalConstants=struct('SamplingFrequency',Fs,'ChipAddresses',ChipAddresses,'NumberOfChannelsPerChip',NumberOfChannelsPerChip,'CurrentRanges',CurrentRanges);

FileName='004';
FileName='011';
%[CI,MI]=NS_Report(FileName,1,NS_GlobalConstants);

Channel=54;
MovieNumber=56;
Fn=2;

[Pulse,Status]=NS_FindPulseShapeForMovie(FileName,Channel,MovieNumber,NS_GlobalConstants);
figure(Fn);
clf;
subplot(2,3,1);
[Amplitude,PlotPointer]=NS_PlotStimulationPulse(Pulse,Status,Channel,0,1,'b-',NS_GlobalConstants);

[Timings,PDChunkIndex]=NS_FindPulsesTimingsForMovie(FileName,Channel,MovieNumber,NS_GlobalConstants);

%Channels=[53:56 59:61];
Channels=Channel;
TimeStart=-10;
NumberOfSamples=70;

electrodeMap=edu.ucsc.neurobiology.vision.electrodemap.ElectrodeMapFactory.getElectrodeMap(1);
neighbors = electrodeMap.getAdjacentsTo(Channel,1);
Channels=neighbors;
Channels=neighbors(2:length(neighbors),1);
Offsets=ones(length(Channels))*(-370);
Traces=NS_ReadManyTracesFromRaw(FileName,Channels,Timings,TimeStart,NumberOfSamples,Offsets,NS_GlobalConstants);

dane=Traces(1:100,:,20:50);
Vectors=NS_ConcacenateWaveforms(dane);

Sdane=size(dane);

dane1=Vectors;
Dimensions=3;
NumberOfClusters=2;
[Types,PCA_Coeffs,Inc]=NS_ClusterSignatures(dane1,Dimensions,NumberOfClusters);
'ble'

FigureProperties=struct('FigureNumber',Fn,'Subplot',[2 3 2],'TimeRange',[0 30],'AmplitudeRange',[-200 200],'FontSize',10,'Colors',['g' 'r' 'b' 'm' 'c']);
y=NS_PlotPCA_Coeffs(NumberOfClusters,Types,PCA_Coeffs,FigureProperties);
Waveforms=dane1(:,1:Sdane(3));
WaveformTypes=zeros(length(Channels));
ArrayID=1;
FigureNumber=1;
AmplitudeRange=[-400 0];
FigureProperties=struct('FigureNumber',Fn,'Subplot',[2 3 3],'TimeRange',[0 30],'AmplitudeRange',AmplitudeRange,'FontSize',10,'Colors',['g' 'r' 'b' 'm' 'k']);
h=NS_PlotManyWaveformsOnFigure(Waveforms,Types,ArrayID,FigureProperties,NS_GlobalConstants);

Ind1=find(Types==1);
[Ind11,a1]=NS_CleanCluster(PCA_Coeffs(Ind1,:),1);
Ind2=find(Types==2);
[Ind12,a2]=NS_CleanCluster(PCA_Coeffs(Ind2,:),1);

%STD=std(PCA_Coeffs(Ind1));
%STD=std(PCA_Coeffs(Ind1(Ind11),:))
%STD=std(PCA_Coeffs(Ind2(Ind12),:))

Types1=Types;
Types1(Ind1(Ind11))=NumberOfClusters+1;
Types1(Ind2(Ind12))=NumberOfClusters+2;
FigureProperties.Subplot=[2 3 5];
y=NS_PlotPCA_Coeffs(NumberOfClusters+2,Types1,PCA_Coeffs,FigureProperties);

FigureProperties.Subplot=[2 3 6];
a=find(Types1==NumberOfClusters+1 | Types1==NumberOfClusters+2);
Waveforms=dane1(a,1:Sdane(3));
h=NS_PlotManyWaveformsOnFigure(Waveforms,Types1(a),ArrayID,FigureProperties,NS_GlobalConstants);

%art2=NS_CalculateEI(dane);

subplot(2,3,4);
axis([0 100 0 100]);
h=gca;
set(h,'XTick',[]);
set(h,'YTick',[]);
set(h,'Color',[1 1 1]);
set(h,'XColor',[1 1 1]);
set(h,'YColor',[1 1 1]);
%set(h,'Visible','off');
xstart=10;
ystart=84;
ystep=9;
text(xstart,ystart+ystep,['Traces: ' num2str(length(Ind11)+length(Ind12)) '/' num2str(Sdane(1)) ' - ' num2str((length(Ind11)+length(Ind12))/Sdane(1)*100,3) '%']);
text(xstart,ystart-0.5*ystep,['Cluster 1: ' num2str(length(Ind11)) '/' num2str(length(Ind1)) ' - ' num2str(length(Ind11)/length(Ind1)*100,3) '%']);
text(xstart,ystart-1.5*ystep,['Cluster 2: ' num2str(length(Ind12)) '/' num2str(length(Ind2)) ' - ' num2str(length(Ind12)/length(Ind2)*100,3) '%']);
text(xstart,ystart-3*ystep,'Sigmas before cleaning:');
text(xstart,ystart-4*ystep,['cluster 1: ' num2str(std(PCA_Coeffs(Ind1,1)),2) ' ' num2str(std(PCA_Coeffs(Ind1,2)),2)]);
text(xstart,ystart-5*ystep,['cluster 2: ' num2str(std(PCA_Coeffs(Ind2,1)),2) ' ' num2str(std(PCA_Coeffs(Ind2,2)),2)]);
text(xstart,ystart-6.5*ystep,'Sigmas after cleaning:');
text(xstart,ystart-7.5*ystep,['cluster 1: ' num2str(std(PCA_Coeffs(Ind1(Ind11),1)),2) '  ' num2str(std(PCA_Coeffs(Ind1(Ind11),2)),2)]);
text(xstart,ystart-8.5*ystep,['cluster 2: ' num2str(std(PCA_Coeffs(Ind2(Ind12),1)),2) '  ' num2str(std(PCA_Coeffs(Ind2(Ind12),2)),2)]);