NS_GlobalConstants=NS_GenerateGlobalConstants(61);
electrodeMap=edu.ucsc.neurobiology.vision.electrodemap.ElectrodeMapFactory.getElectrodeMap(1);
for i=1:64
    ElectrodesCoordinates(i,1)=electrodeMap.getXPosition(i);
    ElectrodesCoordinates(i,2)=electrodeMap.getYPosition(i);
end

BoxLineWidth=2;
ElectrodeMap([1:6 16 7 8 10:11 18 12:15 17 27 19:24 26 28 29:36 37 38:44 45 46:50 51:54 55:56 60 58:59 61:64])=[1:61];

ClusterFilePath='E:\pawel\analysis\retina\2010-09-21-0\data003\ClusterFile_003_id';
NeuronsIDs=[76 227 256 271 391 406 541 616 691 736 856 901];
NeuronsIDs2=[1:12];
Electrodes=[1:8 10:24 26:56 58:64];
for i=1:26    
    [StimChannels,Amplitudes]=NS_StimulatedChannels('E:\pawel\analysis\retina\2010-09-21-0\data003',45,i,[1:64],NS_GlobalConstants);
    Amps(i)=Amplitudes;
end
StEl=[6 16 18 3 27 28 37 45 54 51 60 61];
%Colors=['b' 'k' 'g' 'r' 'c' 'm' 'y'];

ColorsRed = [0  1 0 0   0.5 0   0     0.5 0.5 0     0.5  1 1 0]
ColorsGreen=[0  0 1 0   0   0.5 0     0.5 0   0.5   0.5  1 0 1]
ColorsBlue =[0  0 0 1   0   0   0.5   0   0.5 0.5   0.5  0 1 1]

ColorsRed = [0  1 0 0   0 1 0 0  0 1 0 0];
ColorsGreen=[0  0 1 0   0 0 1 0  0 0 1 0];
ColorsBlue =[0  0 0 1   0 0 0 1  0 0 0 1];

figure(101)
clf
subplot('Position',[0.12 0.1 0.1 0.1]);
for i=1:length(NeuronsIDs)        
    h=plot(1,i,'bd-');
    set(h,'Color',[ColorsRed(i) ColorsGreen(i) ColorsBlue(i)]);
    %axis([1.1 2 0 1]);
    hold on;
end

EffEl=zeros(13,64);
duzo=30;
Thresholds100=ones(1,length(NeuronsIDs))*duzo;
Thresholds0=ones(length(NeuronsIDs),64)*duzo;

Colors={'k' 'r' 'b' 'g' 'k' 'r' 'b' 'g' 'k' 'r' 'b' 'g'};
Ms={'pentagram' 'pentagram' 'pentagram' 'pentagram' 'diamond' 'diamond' 'diamond' 'diamond' 'square' 'square' 'square' 'square'};
figure(200)
clf
subplot('Position',[0.07 0.18 0.78 0.75]);
ghj=[2 3 5:12];
for k=1:10    
    i=ghj(k);
    h2=plot([10:20]);
    set(h2,'LineStyle','none');
    hold on;
    set(h2,'Color',[ColorsRed(i) ColorsGreen(i) ColorsBlue(i)]);
    set(h2,'Marker',Ms{i});
    set(h2,'MarkerFaceColor',[ColorsRed(i) ColorsGreen(i) ColorsBlue(i)]);
    set(h2,'MarkerSize',14);
    leg{k}=['neuron ' num2str(k)];
end
hl=legend(leg);
p=get(hl,'Position');
p(1)=0.82;
p(4)=0.1;
set(hl,'Position',p);
set(hl,'Box','off');

h=gca;
set(h,'LineWidth',BoxLineWidth);

figure(300);
kolorki=jet(1500);
clf;
for i=[2 3 5:12]    
    ClusterFileName=[ClusterFilePath num2str(NeuronsIDs(i))]
    for Pattern=Electrodes%[2 3 5:12]        
        %Pattern=StEl(R);
        for Movie=1:26
            WaveformTypes=NS_ReadClusterFile(ClusterFileName,Movie,Pattern,50);
            Eff(Movie)=length(find(WaveformTypes==2))/length(WaveformTypes)*100;
        end
        
        if StEl(i)==Pattern %jesli ten pattern odpowiada primary electrode dla tego neuronu...
            il=find(Eff==100);
            if length(il)>0
                Thresholds100(1,i)=il(1);
            end            
        else
            il=find(Eff>0);
            if length(il)>0
                Thresholds0(i,Pattern)=il(1);
            end
        end
    end
            
    figure(200);
    hold on;
    T0=Thresholds0(i,:);
    S1=find(T0<duzo)
    h1=plot(ElectrodeMap(S1),Amps(T0(S1)));
    set(h1,'Color',[ColorsRed(i) ColorsGreen(i) ColorsBlue(i)]);
    [ColorsRed(i) ColorsGreen(i) ColorsBlue(i)]
    set(h1,'Marker',Ms{i});
    set(h1,'MarkerSize',14);
    Ms{i}
    set(h1,'LineStyle','none');
    set(h1,'LineWidth',2)
    
    h2=plot(ElectrodeMap(StEl(i)),Amps(Thresholds100(i)));
    set(h2,'Color',[ColorsRed(i) ColorsGreen(i) ColorsBlue(i)]);
    set(h2,'Marker',Ms{i});
    set(h2,'MarkerFaceColor',[ColorsRed(i) ColorsGreen(i) ColorsBlue(i)]);
    set(h2,'MarkerSize',14);   
    
    h3=gca;
    axis([0 62 0 1.7])
    grid on;
    set(h3,'XTick',sort(ElectrodeMap(StEl([2 3 5:12]))))
    set(h3,'FontSize',20);
    xlabel('Electrode number');
    ylabel('Threshold currents [\muA]');
    
    figure(300);
    hold on;
    nr_iteracji=find(ghj==i);
    for j=1:length(S1)
        h4=plot(S1(j),nr_iteracji,'bo');
        %set(h4,'MarkerSize',round(Amps(T0(S1(j)))*10));
        set(h4,'MarkerSize',14);
        set(h4,'MarkerFaceColor',kolorki(1700-round(Amps(T0(S1(j)))*1000),:))
    end    
    
    h5=plot(StEl(i),nr_iteracji,'bd');
    set(h5,'MarkerSize',14);
    set(h5,'MarkerFaceColor',kolorki(1700-round(Amps(Thresholds100(i))*1000),:));
    %set(h5,'MarkerSize',round(Amps(Thresholds100(i))*10))
    %h6=gca;
    %grid on;
    %set(h6,'XTick',sort(StEl([2 3 5:12])));
    %et(h6,'YTick',[1:1:length(ghj)]);
    
    leg{i}=['ID=' num2str(NeuronsIDs2(i))];
end     
figure(300);
h6=gca;
grid on;
set(h6,'XTick',sort(StEl([2 3 5:12])));
set(h6,'YTick',[1:1:length(ghj)]);

%subplot('Position',[0.12 0.8 0.01 0.1]);
%for i=1:length(NeuronsIDs)        
%    h=plot(1,i,'bd-');
%   set(h,'Color',[ColorsRed(i) ColorsGreen(i) ColorsBlue(i)]);
%   axis([1.1 2 0 1]);
%   hold on;
%nd
%legend(leg)
%break;
figure(200)
FullName=['C:\home\pawel\nauka\Stimchip_paper\obrazki\map1.tif'];     
h=gcf;
set(h,'PaperUnits','inches');
set(h,'PaperSize',[13.78 3.7]);
set(h,'PaperPosition',[0 0 13.78 3.7]); 
print(h, '-dtiff', '-r400', FullName);