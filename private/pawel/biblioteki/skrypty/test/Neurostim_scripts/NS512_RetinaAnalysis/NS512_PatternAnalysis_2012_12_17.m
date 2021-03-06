% 1) Find primary electrode for each cell
NeuronIDs=[6 110 139 320 349 367 636 726 873 889 1026 1190 1283 1428 1445 1518 1732 1804 1880 1908 2017 2044 2089 2269 2299 2483 2677 2722 2900 3037 3218 3245 3605 3622 3917 4055 4158 4310 4401 4578 4609 4865 4895 4907 5102 5162 5255 5389 5602 5633 5798 5881 5884 5977 6064 6110 6263 6320 6425 6473 6503 7011 7025 7069 7249 7278 7324 7427 7461 7638];
%NeuronIDs=[6 110 139 320 349 367 636 726 873 889 1026 1190 1283 1428 1445 1518];

NeuronIDs=[6 110 139 320 349 367];

RawDataPath='G:\2012-09-27-4\data000';
VisionOutputPath='D:\Home\Pawel\analysis\2012_09\2012-09-27-4\data000';
PrimaryElectrodes=NeuronIDs;

for i=1:length(NeuronIDs)
    ID=NeuronIDs(i);
    [MinValues,MaxValues]=NS512_FindEIamplitudes(RawDataPath,VisionOutputPath,'000',ID);
    Amplitudes=MaxValues-MinValues;
    [A,I]=max(Amplitudes);
    PrimaryElectrodes(i)=I;
    MaxY=MaxValues(PrimaryElectrodes(i));
    MinY=MinValues(PrimaryElectrodes(i));
    HighLimit(i)=MaxY+(MaxY-MinY)*0.1;
    LowLimit(i)=MinY-(MaxY-MinY)*0.1;    
end

%2) Load information about the stimulating electrode and amplitude for each
%neuron
ThresholdFilePath1=['G:\analysis\2012-09-27-4\stim_scan\thresholds_1']
fid1=fopen(ThresholdFilePath1,'r');
b=fread(fid1,inf,'double');
fclose(fid1);
NeuronInformation=reshape(b,length(b)/4,4);
Neurons1=NeuronInformation(:,1);
Electrodes1=NeuronInformation(:,3);
Amplitudes1=NeuronInformation(:,4);

ThresholdFilePath2=['G:\analysis\2012-09-27-4\stim_scan\thresholds_2']
fid1=fopen(ThresholdFilePath2,'r');
b=fread(fid1,inf,'double');
fclose(fid1);
NeuronInformation=reshape(b,length(b)/4,4);
Neurons2=NeuronInformation(:,1);
Electrodes2=NeuronInformation(:,3);
Amplitudes2=NeuronInformation(:,4);

Neurons=[Neurons1' Neurons2']';
Electrodes=[Electrodes1' Electrodes2']';
Amplitudes=[Amplitudes1' Amplitudes2']';
%trzeba napisac funkcje przeksztalcajaca amplitude na numer movie

%3) Amplitudes -> movie numbers
StimulationDataPath='D:\Home\Pawel\analysis\2012_09\2012-09-27-4\scan_new';
FigurePath='D:\Home\Pawel\analysis\2012_09\2012-09-27-4\figures';
Patterns=[65:320];
Movies=[1:2:63];

for i=1:length(Movies)
    MovieNumber=Movies(i);
    MoviesAmplitudes(i)=NS_AmplitudesForPattern_512_1el('D:\Home\Pawel\analysis\2012_09\2012-09-27-4\scan_new',2,2,MovieNumber,NS_GlobalConstants);
end
    
for i=1:length(Amplitudes)
    [y,MovieIndex]=min(abs(MoviesAmplitudes-Amplitudes(i)));
    TrhesholdMovies(i)=Movies(MovieIndex);
end

%StimulationDataPath='D:\Home\Pawel\analysis\2012_09\2012-09-27-4\scan_new';
%FigurePath='D:\Home\Pawel\analysis\2012_09\2012-09-27-4\figures';
%Patterns=[65:320];
%Movies=[1:2:63];

for i=1:length(Patterns)
    Pattern=Patterns(i);
    for j=1:length(Movies)
        Movie=Movies(j);
        [DataTraces0,ArtifactDataTraces,DataChannels]=NS_ReadPreprocessedData(StimulationDataPath,StimulationDataPath,0,Pattern,Movie,0,0);   %read data                 
        SDT0=size(DataTraces0);
        DataTraces=DataTraces0(:,PrimaryElectrodes,8:SDT0(3));
        SDT=size(DataTraces);
        figure(1);
        for k=1:length(PrimaryElectrodes)
            s=reshape(DataTraces(:,k,:),SDT(1),SDT(3));
            subplot(7,10,k);
            plot(s');           
            h1=gca;
            %set(h1,'YLim',[-500 -300]);
            %LowLimit(k)
            %HighLimit(k)
            set(h1,'XLim',[0 33]);
            set(h1,'YLim',[LowLimit(k) HighLimit(k)]);
        end
        FigureName=[FigurePath '\p' num2str(Pattern) 'm' num2str(Movie)];            
        h=gcf;
        set(h,'PaperUnits','inches');
        set(h,'PaperSize',[16 9]);
        set(h,'PaperPosition',[0 0 16 9]);  
        print(h, '-dtiff', '-r120', FigureName);
    end
end
