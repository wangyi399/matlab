NS_GlobalConstants=NS_GenerateGlobalConstants(512);

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

for i=36%1:length(Neurons)
    Neuron=Neurons(i);
    spikeTimes = double(neuronFile.getSpikeTimes(Neuron)');
    
    Electrode=Electrodes(i);
    
    %3A) Find the primary electrode
    N=200;
    L=60;
    offset=50;
    LBack=30;
    spikes2=zeros(N,512,L); %spike,channel,sample
    for i=1:min(N,length(spikeTimes-offset))
        t=spikeTimes(offset+i);
        d0=rawFile.getData(t-LBack,L)';
        d1=d0([1:512]+1,:);
        spikes2(i,:,:)=d1;
    end
    EI=mean(spikes2);
    Amplitudes=max(abs(EI),[],3); % max amplitude (any polarity) for each electrode for this EI
    %figure(3)
    %plot(Amplitudes)
    MaxElectrodes=find(Amplitudes==max(Amplitudes));
    PrimaryElectrode=MaxElectrodes(1) %this is the primary recording electrode for the given neuron
    HighLimit=10*ceil(max(Amplitudes/10));
    LowLimit=-20*ceil(max(Amplitudes/10));
            
    % 3B) For each spike, identify the latest stimulation pulse and the
    % spike relative latency
    MovieFilePath='D:\Home\Data\slices\2010-09-14-0\movie002';
    MoviesBegins=NS512_MoviesBegins(MovieFilePath,NS_GlobalConstants);
    dane=[];
    for s=1:length(spikeTimes) 
        s
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
        if SubplotNumber==1
            clf;
        end
        %clf
        subplot(4,2,SubplotNumber);
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
            for t2=1:RepetNumber
                %t2
                SpikesIDs=find(dane(1,:)==WhichMovie & dane(2,:)==t2 & dane(3,:)==Electrode)
                for sp=1:length(SpikesIDs)
                    PatternID=dane(5,SpikesIDs(sp))
                    PatternPresenceID=find(WhichPatterns==PatternID)
                    if length(PatternPresenceID)==0
                        error('sldghsoigh!!!!');
                    end
                    if PatternPresenceID==i2
                        t2
                        SpikeLatency=dane(4,SpikesIDs(sp))
                        FirstSample=max(1,SpikeLatency-10);
                        LastSample=min(length(spikes3),SpikeLatency+40);
                        SpikeWaveform=spikes3(t2,FirstSample:LastSample);                        
                        %figure(7)
                        plot([FirstSample:LastSample]/20,SpikeWaveform,'r-');
                    end
                end
            end            
        end
        FullImageName=['C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2013_10_02\Traces\n' num2str(Neuron) '_p' num2str(Electrode) '_r' num2str(FigureNumber) '.tif'];
        h=gcf;
        set(h,'PaperUnits','inches');
        set(h,'PaperSize',[16 9]);
        set(h,'PaperPosition',[0 0 16 9]); 
        print(h, '-dtiff', '-r120', FullImageName);
    end
end