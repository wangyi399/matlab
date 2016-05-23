MovieFilePath='D:\Home\Data\slices\2010-09-14-0\movie002';

NeuronID=6993;

fid=fopen(['C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2012_04_10\dane\ID=' num2str(NeuronID)],'r','ieee-le'); 
%[182 257 271 289 588 616 679 694 752 766 771 800

a=fread(fid,'int32');
l=length(a);
%dane=reshape(a,5,l/5); %MovieNumber,RepetitionNumber,PatternNumber,Latency,TimeRelativeToRepetitionBegin
dane=reshape(a,4,l/4); %MovieNumber,RepetitionNumber,PatternNumber,Latency,TimeRelativeToRepetitionBegin
fclose(fid);

FullName=['C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2012_04_10\histograms5\GaussParameters.bin']; % pokoj 109
fid=fopen(FullName,'r','ieee-le');
a=fread(fid,'double');
GaussParameters=reshape(a,length(a)/5,5); %NeuronID, interesting electrode, Amplitude, tau, sigma
Neurons=GaussParameters(:,1);
Electrodes=GaussParameters(:,2);

i12=find(Neurons==NeuronID)

Patterns=[339 371 409 395 463 491 32 64 47 30 45 356];

figure(11)
clf

LC=[0 0.33 0.66]+0.02;
BC=[0 0.17 0.66 0.83]+0.01;
LeftCoordinates=[LC(1) LC(2) LC(3) LC(1) LC(2) LC(3) LC(1) LC(2) LC(3) LC(1) LC(2) LC(3)];
BottomCoordinates=[BC(4) BC(4) BC(4) BC(3) BC(3) BC(3) BC(2) BC(2) BC(2) BC(1) BC(1) BC(1)];
SubplotWidth=0.28;
SubplotHeight=0.14;

for p=1:length(Patterns)
    WholeAreaCoordinates(1)=LeftCoordinates(p);
    WholeAreaCoordinates(2)=BottomCoordinates(p);
    WholeAreaCoordinates(3)=SubplotWidth;
    WholeAreaCoordinates(4)=SubplotHeight;
    
    %subplot('position',[0.05 0.05 0.56 0.92])
    Subsubplot(WholeAreaCoordinates,[0.01 0.01 0.98 0.46]);
    hold on;
    movieIDList = NS512_GetMoviesWithPatternIDNew(MovieFilePath,Patterns(p));
    NumberOfSpikes=zeros(1,length(movieIDList));
    AllSpikeTimes=[];
    for m=1:length(movieIDList)
        SpikesIDs=find(dane(1,:)==movieIDList(m) & dane(3,:)==Patterns(p));
        SpikeTimes=dane(4,SpikesIDs);  
        AllSpikeTimes=[AllSpikeTimes SpikeTimes];
        NumberOfSpikes(m)=length(SpikeTimes);
        for sp=1:length(SpikeTimes)
            h1=plot([SpikeTimes(sp)/20 SpikeTimes(sp)/20],[-m -m-0.5],'b-');
            set(h1,'LineWidth',1);
        end
        h1=gca;
        set(h1,'XLim',[0 30]);
    end    
    Subsubplot(WholeAreaCoordinates,[0.01,0.56,0.46,0.42]);
    plot(int32(NumberOfSpikes/102*100),'bd-')
    axis([0 20 0 120]);
    grid on
    h3=text(2,70,num2str(p));
    set(h3,'Color','r');
    
    Subsubplot(WholeAreaCoordinates,[0.5,0.56,0.46,0.42])
    LatenciesForGivenElectrode=AllSpikeTimes;
    p1=hist(LatenciesForGivenElectrode,[5:10:600]);
    hist(LatenciesForGivenElectrode,[5:10:600]);
    CFs=NS512_FitWithMultiGauss([1:60],p1);
    hold on
    Peak=zeros(60,1);
    for peak=1:length(CFs)
        FL=CFs{peak};
        Peak=Peak+FL([1:60]);        
    end
        h=plot([5:10:600],Peak,'r-');
        set(h,'LineWidth',2)
        h=gca;
        set(h,'XLim',[0 600]);
        xlabel('Time [ms]');
        ylabel('N');
        %text(450,40,['A=' num2str(CFs{1}.A,'%8.2f')]);
        text(20,35,['\tau = ' num2str(CFs{1}.tau*10/20,'%8.1f') ' ms']);
        text(20,30,['\sigma = ' num2str(CFs{1}.sigma*10/20,'%8.1f') ' ms']);                
    %end
    if p==11        
        figure(101);
        plot(int32(NumberOfSpikes/102*100),'bd-');
        h=gca;
        set(h,'FontSize',24);
        h=gcf;
        FullImageName=['C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2014_12_07\figures\figure1_eff.tif'];
        set(h,'PaperUnits','inches');
        set(h,'PaperSize',[8 5]*2);
        set(h,'PaperPosition',[0 0 8 5]*2); 
        %print(h, '-dtiff', '-r120', FullImageName);
        
        figure(102);
        hist(LatenciesForGivenElectrode,[5:10:600]);
        hold on;
        h=plot([5:10:600],Peak,'r-');
        set(h,'LineWidth',2)
        h=gca;
        set(h,'XLim',[0 600]);
        set(h,'FontSize',24);
        xlabel('Time [ms]');
        ylabel('N');
        %text(450,40,['A=' num2str(CFs{1}.A,'%8.2f')]);
        text(20,35,['\tau = ' num2str(CFs{1}.tau*10/20,'%8.1f') ' ms']);
        text(20,30,['\sigma = ' num2str(CFs{1}.sigma*10/20,'%8.1f') ' ms']);
        h=gcf
        FullImageName=['C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2014_12_07\figures\figure1_hist.tif'];
        set(h,'PaperUnits','inches');
        set(h,'PaperSize',[8 5]*2);
        set(h,'PaperPosition',[0 0 8 5]*2); 
        print(h, '-dtiff', '-r120', FullImageName);
        
        figure(11)
    end        
end

% Show spontaneous EI of the neuron
RawDataPath='D:\Home\Data\slices\2010-09-14-0\data002';
NeuronFilePath='C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2012_04_10\Vision_output\2010-09-14-0\data002\data002.neurons';
EI=NS512_SpontaneousEI(RawDataPath,NeuronFilePath,6993);
subplot('position',[0.15 0.39 0.7 0.22])
EI1=reshape(EI,512,80);
h=NS512_ShowEIAsCircles4(EI1/1.5,500,[1:512],[],Patterns,[-1000 1000],[-500 500]);

FullImageName=['C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2014_12_07\figures\figure2.tif'];
h=gcf;
set(h,'PaperUnits','inches');
set(h,'PaperSize',[10 12]);
set(h,'PaperPosition',[0 0 10 12]); 
print(h, '-dtiff', '-r240', FullImageName);