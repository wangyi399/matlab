clear
%'C:\pawel\nauka\analiza\slices\2010-09-14-0\data002minus009paramSninya\201
%0-09-14-0\dane\ID=6648' - dobyr neuron do testowannia multipeak fit; takze
%5823
TotalNumberOfPatterns=64;
MoviesStep=8;

komp='pokoj109';
if komp=='pokoj109'
    RawDataPath='D:\Home\Data\slices\2010-09-14-0\data002'; %pokoj 109
    paramsFile=edu.ucsc.neurobiology.vision.io.ParametersFile('C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2012_04_10\Vision_output\2010-09-14-0\data002\data002.params');
    neuronFile = edu.ucsc.neurobiology.vision.io.NeuronFile('C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2012_04_10\Vision_output\2010-09-14-0\data002\data002.neurons');
    dane_path='D:\Home\Pawel\analysis\2010-09-14-0\data002min009new2\dane';
else
    RawDataPath='C:\pawel\nauka\dane\2010-09-14-0\data002min009'; %laptop
    paramsFile=edu.ucsc.neurobiology.vision.io.ParametersFile('C:\pawel\nauka\analiza\slices\2010-09-14-0\data002min009new2\2010-09-14-0\data002\data002.params');
    neuronFile = edu.ucsc.neurobiology.vision.io.NeuronFile('C:\pawel\nauka\analiza\slices\2010-09-14-0\data002min009new2\2010-09-14-0\data002\data002.neurons');
    dane_path='C:\pawel\nauka\analiza\slices\2010-09-14-0\data002min009new2\dane;'
end

%cd D:\Home\Pawel\analysis\2010-09-14-0\data002min009new2\dane;
a3=importdata('C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2012_04_10\Vision_output\2010-09-14-0\good_neurons002.txt');
%idList = neuronFile.getIDList();
idList=a3;
GaussParameters=double([]);
NoOfEl=0;

for Neuron=1:length(idList)
    NeuronID=idList(Neuron)
    %FullName=['C:\pawel\nauka\analiza\slices\2010-09-14-0\data002minus009paramSninya\2010-09-14-0\dane\ID=' num2str(NeuronID)]; % laptop
    FullName=['C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2012_04_10\dane\ID=' num2str(NeuronID)]; % pokoj 109
    fid=fopen(FullName,'r','ieee-le'); 
    a=fread(fid,'int32');
    l=length(a);
    dane=reshape(a,4,l/4);
    fclose(fid);

    Movies=dane(1,:);
    Patterns=dane(3,:);
    Latencies=dane(4,:);
    %figure(2)
    clf
    p=hist(Patterns,[0:1:512]);
    %plot(p);
    AllPatterns=find(p(2:length(p))>0);
    
        
    %tutaj: dla kazdego pattern i kazdego movie, stwierdzic czy spiki sa
    %"time locked". Powinno by? bardzo proste.
    ble=[];
    for p1=1:length(AllPatterns)
        Pattern=AllPatterns(p1); % which pattern...
        a1=find(Patterns==Pattern); % ktore spiki skojarzone z tym patternem
        AllMoviesHere=unique(Movies(a1)); % wszystkie moviesy dla ktorych dany neuron odpowiedzial na dany pattern
        for m1=1:length(AllMoviesHere) % dla wszystkich tych moviesow...
            s1=find(Movies(a1)==AllMoviesHere(m1));
            %length(s1)
            LatenciesForNeuronForPatternForMovie=Latencies(a1(s1));
            p2=hist(LatenciesForNeuronForPatternForMovie,[1:600]);
            TimeLocking=NS512_AreTheSpikesTimeLocked(p2,30);
            if TimeLocking
                ble=[ble Pattern];
            end
        end
        %AllSpikesPerPattern(p1)=length(find(Patterns==Pattern));
    end
    InterestingElectrodesFinal=unique(ble);
        
    %return;
    
    
    

    %MeanSpikesPerPattern=l/4/TotalNumberOfPatterns;
    %MinimumNumberOfSpikesToBeInteresting=max(MeanSpikesPerPattern*2,200);

    %InterestingElectrodes=find(p>MinimumNumberOfSpikesToBeInteresting)-1; % minus1 bo pierwszy s�upek w histogramie 'p' odpowiada zeru
    %InterestingElectrodesFinal2=InterestingElectrodes(find(InterestingElectrodes>0));
    
    
    
    

    figure(1)
    clf
    NumberOfColumns=ceil(sqrt(length(InterestingElectrodesFinal)));
    NumberOfRows=ceil(length(InterestingElectrodesFinal)/NumberOfColumns);
    t_divider=20;
    t=[0:1:600];
    for i=1:length(InterestingElectrodesFinal)
        NoOfEl=NoOfEl+1;
        Electrode=InterestingElectrodesFinal(i);
        EventsForGivenElectrode=find(Patterns==Electrode);
        LatenciesForGivenElectrode=Latencies(EventsForGivenElectrode);  
        subplot(NumberOfRows,NumberOfColumns*2,(i-1)*2+1);
        p=hist(LatenciesForGivenElectrode,t);
        hist(LatenciesForGivenElectrode/t_divider,t/t_divider);
        h=gca;
        Yrange=get(h,'YLim');
        Ymax=Yrange(2);
        hold on;
        h=text(25/t_divider,0.9*Ymax,['el. ' num2str(Electrode)]);
        set(h,'FontSize',7);
        h=text(25/t_divider,0.8*Ymax,['N=' num2str(length(LatenciesForGivenElectrode))]);
        set(h,'FontSize',7);
    
        CFs=NS512_FitWithMultiGauss(t,p);
        FitLine=zeros(1,length(t));
        for j=1:length(CFs)
            FitLine=FitLine+CFs{j}(t)';               
            h=text(360/t_divider,(0.9-(j-1)*0.27)*Ymax,['\tau=' num2str(CFs{j}.tau/20,'%8.2f')]);
            set(h,'FontSize',7);
            h=text(360/t_divider,(0.8-(j-1)*0.27)*Ymax,['\sigma=' num2str(CFs{j}.sigma/20,'%8.3f')]);
            set(h,'FontSize',7);
        
            DataToSave=[double(NeuronID) double( Electrode) CFs{j}.A CFs{j}.tau CFs{j}.sigma];
            GaussParameters=[GaussParameters' DataToSave']';
        end
        plot(t/t_divider,FitLine,'r-');
        h=gca;
        set(h,'XLim',[0 max(t)]/t_divider);
        set(h,'YLim',Yrange);
        set(h,'FontSize',7);
        if (i-1)*2==(NumberOfRows-1)*NumberOfColumns*2
            xlabel('Time [ms]');
            ylabel('N');
        end
    
        MoviesForGivenElectrode=Movies(EventsForGivenElectrode); 
        UniqueMovies=unique(MoviesForGivenElectrode);
        Eff=zeros(1,length(UniqueMovies));
        for j=1:length(UniqueMovies)
            Eff(j)=length(find(MoviesForGivenElectrode==UniqueMovies(j)));
        end
        subplot(NumberOfRows,NumberOfColumns*2,(i-1)*2+2);
        plot(1:length(UniqueMovies),Eff/108*100);
        h2=gca;
        set(h2,'FontSize',7);
        axis([0 18 0 100]);
        if (i-1)*2==(NumberOfRows-1)*NumberOfColumns*2
            xlabel('Amplitude');
            ylabel('Eff [%]');
        end
    end
    %FullImageName=['C:\pawel\nauka\analiza\slices\2010-09-14-0\data002minus009
    %paramSninya\2010-09-14-0\dane\images\Neuron' num2str(NeuronID) '.tif']; %
    %laptop
    if length(InterestingElectrodesFinal)
        FullImageName=['C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2014_12_07\histograms4\Neuron' num2str(NeuronID) '.tif']; % pokoj 109
        h=gcf;
        set(h,'PaperUnits','inches');
        set(h,'PaperSize',[8 4.5]);
        set(h,'PaperPosition',[0 0 8 4.5]); 
        print(h, '-dtiff', '-r240', FullImageName);
    end
end
%break
%FullName=['C:\pawel\nauka\analiza\slices\2010-09-14-0\data002minus009paramSninya\2010-09-14-0\dane\images\GaussParameters.bin']; %laptop
FullName=['C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2014_12_07\histograms4\GaussParameters.bin']; % pokoj 109
fid=fopen(FullName,'wb','ieee-le');                                    
fwrite(fid,GaussParameters,'double');
fclose(fid);