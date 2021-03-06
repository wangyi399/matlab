NS_GlobalConstants=NS_GenerateGlobalConstants(512);
SpikeLeftMargin=10;
SpikeRightMargin=40;
electrodeMap=edu.ucsc.neurobiology.vision.electrodemap.ElectrodeMapFactory.getElectrodeMap(500);

%1) Definition of Vision output files paths
full_path='D:\Home\Data\slices\2010-09-14-0\data002'; %define path to raw data file
rawFile=edu.ucsc.neurobiology.vision.io.RawDataFile(full_path); 

paramsFile=edu.ucsc.neurobiology.vision.io.ParametersFile('C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2012_04_10\Vision_output\2010-09-14-0\data002\data002.params');
neuronFile = edu.ucsc.neurobiology.vision.io.NeuronFile('C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2012_04_10\Vision_output\2010-09-14-0\data002\data002.neurons');
idList = neuronFile.getIDList(); %this imports list of neurons IDs from the file that is defined above as 'neuronFile';

%2) Find the int
FullName=['C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2012_04_10\histograms5\GaussParameters.bin']; % pokoj 109
fid=fopen(FullName,'r','ieee-le');
a=fread(fid,'double');
GaussParameters=reshape(a,length(a)/5,5); %NeuronID, interesting electrode, Amplitude, tau, sigma

Neurons=GaussParameters(:,1);
Electrodes=GaussParameters(:,2);
break
for i=334%:347%168:length(Neurons)
    Neuron=Neurons(i);
    spikeTimes = double(neuronFile.getSpikeTimes(Neuron)');
    
    Electrode=Electrodes(i);
    Xstim=electrodeMap.getXPosition(Electrode);
    Ystim=electrodeMap.getYPosition(Electrode);
    
    %3A) Find the primary electrode
    N=200;
    L=60;
    offset=50;
    LBack=30;
    spikes2=zeros(N,512,L); %spike,channel,sample
    for i100=1:min(N,length(spikeTimes-offset))
        t=spikeTimes(offset+i100);
        d0=rawFile.getData(t-LBack,L)';
        d1=d0([1:512]+1,:);
        spikes2(i100,:,:)=d1;
    end
    EI=mean(spikes2);
    Amplitudes=max(abs(EI),[],3); % max amplitude (any polarity) for each electrode for this EI
    %figure(3)
    %plot(Amplitudes)
    MaxElectrodes=find(Amplitudes==max(Amplitudes));
    PrimaryElectrode=MaxElectrodes(1) %this is the primary recording electrode for the given neuron
    HighLimit=10*ceil(max(Amplitudes/10));
    LowLimit=-20*ceil(max(Amplitudes/10));
    
    %Calculate distance from neuron to stimulating electrode
    Xrec=electrodeMap.getXPosition(PrimaryElectrode);
    Yrec=electrodeMap.getYPosition(PrimaryElectrode);
    Distance=sqrt((Xrec-Xstim)^2+(Yrec-Ystim)^2);
            
    % 3B) For each spike, identify the latest stimulation pulse and the
    % spike relative latency
    MovieFilePath='D:\Home\Data\slices\2010-09-14-0\movie002';
    MoviesBegins=NS512_MoviesBegins(MovieFilePath,NS_GlobalConstants);
    dane=[];
    for s=1:length(spikeTimes)         
        [dane(1,s),dane(2,s),dane(3,s),dane(4,s),dane(5,s)]=NS512_SpikeTimesToStimulationPatterns_v2(MovieFilePath,spikeTimes(s),MoviesBegins,NS_GlobalConstants); % MovieNumber,RepetitionNumber,PatternNumber,Latency,TimeRelativeToRepetitionBegin
    end
    size(dane) 
        
    movieIDList = NS512_GetMoviesWithPatternIDNew(MovieFilePath,Electrode);
    for wm=2:17%1:length(movieIDList)
        FigureNumber=ceil((wm-1)/8);
        SubplotNumber=wm-1-(FigureNumber-1)*8;
        WhichMovie=movieIDList(wm);
        MovieData4=NS_MovieData_GlobalPath(MovieFilePath,movieIDList(wm),NS_GlobalConstants);
        [PDChunkNumber,MovieBegin,RepetNumber,RepetPeriod,MovieData]=NS_DecodeMovieDataChunk(MovieData4);
        SMD=size(MovieData);
        PatternNumbers=MovieData(2:3:SMD(1));
        WhichPatterns=find(PatternNumbers==Electrode);
        WaveformLength=600;
        spikes3=zeros(RepetNumber,WaveformLength);
        figure(FigureNumber)
        
        % Add figure title
        subplot('position',[0.26,0.96,0.1,0.03]);
        plot(1,1,'b-')
        h10=text(1,1,['event ' num2str(i) ', neuron ' num2str(Neuron) ', recording electrode ' num2str(PrimaryElectrode) ', stimulating electrode ' num2str(Electrode) ', distance ' num2str(int32(Distance)) ' \mum']);        
        h=gca;
        set(h,'Visible','off');
        
        if SubplotNumber==1
            clf;
        end
        %clf
        NumberOfRows=4;
        NumberOfColumns=2;
        %subplot(4,2,SubplotNumber);
        HorizontalMargin=0.05;
        VerticalMargin=0.05;
        PlotWidth=0.4;
        PlotHeight=0.2;
        RowIndex=ceil(SubplotNumber/NumberOfColumns);
        ColumnIndex=SubplotNumber-(RowIndex-1)*NumberOfColumns;
        subplot('position',[0.05+(ColumnIndex-1)*0.47,0.76-0.23*(RowIndex-1),0.3,0.18]);
        hold on;
                
        for i2=1%:length(WhichPatterns)
            TimeIndex=MovieData(1+(WhichPatterns(i2)-1)*3);
            PulseTimes=MovieBegin+TimeIndex+(0:RepetNumber-1)*RepetPeriod;
    
            for t1=1:RepetNumber
                PulseTime=PulseTimes(t1);
                d0=rawFile.getData(PulseTime,WaveformLength)';
                d1=d0(PrimaryElectrode+1,:);
                size(d1);
                spikes3(t1,:)=d1;                
            end
            %subplot(1,length(WhichPatterns),i2);
            %subplot(4,1,i2);            
            h1=plot([1:600]/20,spikes3');
            set(h1,'Color','b');
            hold on;
            h2=gca;
            set(h2,'YLim',[LowLimit HighLimit]);
            grid on
            % Overlay traces with spieks from the given neuron
            % Find spikes that are 
            SpikeWaveforms=[];
            SampleIndexes=[];
            for t2=1:RepetNumber                
                %t2
                SpikesIDs=find(dane(1,:)==WhichMovie & dane(2,:)==t2 & dane(3,:)==Electrode);
                for sp=1:length(SpikesIDs)
                    PatternID=dane(5,SpikesIDs(sp))
                    PatternPresenceID=find(WhichPatterns==PatternID)
                    if length(PatternPresenceID)==0
                        error('sldghsoigh!!!!');
                    end                    
                    if PatternPresenceID==i2
                        t2                        
                        SpikeLatency=dane(4,SpikesIDs(sp))
                        FirstSample=max(1,SpikeLatency-SpikeLeftMargin);
                        LastSample=min(length(spikes3),SpikeLatency+SpikeRightMargin);
                        SpikeWaveform=spikes3(t2,FirstSample:LastSample);                                                
                        plot([FirstSample:LastSample]/20,SpikeWaveform,'r-');
                        hold on                        
                        if length(SpikeWaveform)==SpikeLeftMargin+SpikeRightMargin+1
                            SpikeWaveforms=[SpikeWaveforms' SpikeWaveform']';
                            SampleIndexes=[SampleIndexes' [0:SpikeLeftMargin+SpikeRightMargin]'/20]';
                        end                        
                    end
                end
            end
            SSW=size(SpikeWaveforms);
            text(25.5,LowLimit*0.6,['Eff = ' num2str(int32(100*SSW(1)/RepetNumber)) '%']);
            %text(24,LowLimit*0.55,['Dist = ' num2str(int32(Distance)) '\mum']);
            subplot('position',[0.4+(ColumnIndex-1)*0.47,0.76-0.23*(RowIndex-1),0.08,0.18]);
            plot(SampleIndexes',SpikeWaveforms','r-');
            h2=gca;
            set(h2,'YLim',[LowLimit HighLimit]);
            set(h2,'XLim',[0 SpikeLeftMargin+SpikeRightMargin+1]/20);
            grid on;
        end
        FullImageName=['C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2013_10_02\Traces\n' num2str(Neuron) '_p' num2str(Electrode) '_r' num2str(FigureNumber) '.tif'];
        h=gcf;
        set(h,'PaperUnits','inches');
        set(h,'PaperSize',[16 9]);
        set(h,'PaperPosition',[0 0 16 9]); 
        %print(h, '-dtiff', '-r120', FullImageName);
    end
end