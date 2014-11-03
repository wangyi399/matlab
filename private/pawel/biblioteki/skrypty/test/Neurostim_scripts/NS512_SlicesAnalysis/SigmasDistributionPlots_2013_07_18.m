FullName=['C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2012_04_10\histograms5\GaussParameters.bin']; % pokoj 109
fid=fopen(FullName,'r','ieee-le');
a=fread(fid,'double');
GaussParameters=reshape(a,length(a)/5,5); %NeuronID, electrode, Amplitude, tau, sigma

neurons=GaussParameters(:,1);
uniqueneurons=unique(neurons);
NeuronID=4666
Events=find(neurons==NeuronID);
%sigmas(Events)

delays=GaussParameters(:,4);
sigmas=GaussParameters(:,5);
figure(100)
hist(sigmas/20,[1:2:130]/20);
h=xlabel('\sigma [ms]');
set(h,'FontSize',10)
h=ylabel('N');
set(h,'FontSize',10)
grid on
h=gca
set(h,'FontSize',10)
FullImageName=['C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2013_07_18\other_plots\sigmas_histogram.tif'];
h=gcf;
set(h,'PaperUnits','inches');
set(h,'PaperSize',[4 3]);
set(h,'PaperPosition',[0 0 4 3]); 
print(h, '-dtiff', '-r240', FullImageName);

figure(101);
h=plot(delays/20,sigmas/20,'bd');
set(h,'MarkerSize',3)
set(h,'MarkerFaceColor','b')
h=xlabel('Latency [ms]');
set(h,'FontSize',10)
ylabel('\sigma [ms]');
set(h,'FontSize',10)
grid on
h=gca
set(h,'FontSize',10)
set(h,'XLim',[0 30])
FullImageName=['C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2013_07_18\other_plots\latency_vs_sigma.tif'];
h=gcf;
set(h,'PaperUnits','inches');
set(h,'PaperSize',[4 3]);
set(h,'PaperPosition',[0 0 4 3]); 
print(h, '-dtiff', '-r240', FullImageName);

Neurons=GaussParameters(:,1);
Electrodes=GaussParameters(:,2);
NeuronFile = edu.ucsc.neurobiology.vision.io.NeuronFile('C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2012_04_10\Vision_output\2010-09-14-0\data002\data002.neurons');
electrodeMap=edu.ucsc.neurobiology.vision.electrodemap.ElectrodeMapFactory.getElectrodeMap(500);
figure(100);
clf
hold on;
for i=1:length(Neurons)
    SeedEl(i) = NeuronFile.getNeuronIDElectrode(Neurons(i));
    XSeed(i)=electrodeMap.getXPosition(SeedEl(i));
    YSeed(i)=electrodeMap.getYPosition(SeedEl(i));
    XStim(i)=electrodeMap.getXPosition(Electrodes(i));
    YStim(i)=electrodeMap.getYPosition(Electrodes(i));
    %h15=plot([XStim(i) XSeed(i)]-XStim(i),[YStim(i) YSeed(i)]-YStim(i),'bd-');
    h15=plot([XStim(i) XSeed(i)],[YStim(i) YSeed(i)],'b-');
    if sigmas(i)<7
        set(h15,'Color','r');
    end
    h16=plot([XSeed(i)],[YSeed(i)],'gd');
    set(h16,'MarkerFaceColor','g')
    set(h16,'MarkerSize',20)
    Distances(i)=sqrt((XSeed(i)-XStim(i))^2+((YSeed(i)-YStim(i))^2));
end
grid on
axis([-1000 1000 -500 500]);

figure(102);
h=plot(Distances,delays/20,'bd');
set(h,'MarkerSize',3)
set(h,'MarkerFaceColor','b');
hold on;
DirectStimulation=find(sigmas<7);
InDirectStimulation=find(sigmas>6);

h=plot(Distances(DirectStimulation),delays(DirectStimulation)/20,'rd');
set(h,'MarkerSize',3)
set(h,'MarkerFaceColor','r');
h=xlabel('Distance [\mum]');
set(h,'FontSize',10)
h=ylabel('Latency [ms]');
set(h,'FontSize',10)
grid on
h=gca
set(h,'FontSize',10)
set(h,'YLim',[0 30])
FullImageName=['C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2013_07_18\other_plots\distance_vs_latency.tif'];
h=gcf;
set(h,'PaperUnits','inches');
set(h,'PaperSize',[4 3]);
set(h,'PaperPosition',[0 0 4 3]); 
print(h, '-dtiff', '-r240', FullImageName);
   
figure(103);
h=plot(Distances,sigmas/20,'bd');
set(h,'MarkerSize',3)
set(h,'MarkerFaceColor','b');
hold on;
h=plot(Distances(DirectStimulation),sigmas(DirectStimulation)/20,'rd');
set(h,'MarkerSize',3)
set(h,'MarkerFaceColor','r');
h=xlabel('Distance [\mum]');
set(h,'FontSize',10)
h=ylabel('\sigma [ms]');
set(h,'FontSize',10)
grid on
h=gca
set(h,'FontSize',10)
%set(h,'YLim',[0 30])
FullImageName=['C:\home\Pawel\nauka\analiza\SlicesTTX\2010-09-14-0\analysis_2013_07_18\other_plots\distance_vs_sigma.tif'];
h=gcf;
set(h,'PaperUnits','inches');
set(h,'PaperSize',[4 3]);
set(h,'PaperPosition',[0 0 4 3]); 
print(h, '-dtiff', '-r240', FullImageName);

figure(104);
clf
hold on
for i=1:length(DirectStimulation)
    h16=plot([XStim(DirectStimulation(i)) XSeed(DirectStimulation(i))],[YStim(DirectStimulation(i)) YSeed(DirectStimulation(i))]);
    plot(XSeed(DirectStimulation(i)),YSeed(DirectStimulation(i)),'bd')
end
grid on
axis([-1000 1000 -500 500]);

figure(105);
clf
hold on
for i=1:length(DirectStimulation)
    h16=plot([XStim(InDirectStimulation(i)) XSeed(InDirectStimulation(i))],[YStim(InDirectStimulation(i)) YSeed(InDirectStimulation(i))],'bd-');
end
grid on
axis([-1000 1000 -500 500]);

ElectrodesToAnalyze=setdiff(Electrodes,SeedEl);
figure(106)
clf
hold on
for i=1:length(Neurons)
    if find(ElectrodesToAnalyze==Electrodes(i))
        h15=plot([XStim(i) XSeed(i)],[YStim(i) YSeed(i)],'b-');
        if sigmas(i)<7
            set(h15,'Color','r');
        end
        h16=plot([XSeed(i)],[YSeed(i)],'gd');
        set(h16,'MarkerFaceColor','g')
        set(h16,'MarkerSize',20)
        text([XSeed(i)],[YSeed(i)],num2str(Neurons(i)));
    end
end

figure(107);

g1=hist(neurons,[1:8000]);
NeuronWithManyStimulations=find(g1>6);
for i=24%1:length(NeuronWithManyStimulations)
    Events=find(neurons==NeuronWithManyStimulations(i));
    S1=sigmas(Events);
    DirectivityIndex(i)=length(find(S1<7))/length(S1);    
    
    clf;
    hold on;
    for j=1:length(Events)
        h15=plot([XStim(Events(j)) XSeed(Events(j))],[YStim(Events(j)) YSeed(Events(j))],'b-');
        text(XStim(Events(j)),YStim(Events(j)),num2str(j));
        if sigmas(Events(j))<40 %7
            set(h15,'Color','r');
        end        
    end
    axis([-1000 1000 -500 500]);
end

figure(108)
hist(DirectivityIndex,100)

NeuronID=5566
Events=find(neurons==NeuronID);
sigmas(Events)