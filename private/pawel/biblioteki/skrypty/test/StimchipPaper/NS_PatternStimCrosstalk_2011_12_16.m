clear

full_path='K:\2010-09-21-0\data002\'; %define path to raw data file
rawFile=edu.ucsc.neurobiology.vision.io.RawDataFile(full_path); 
paramsFile=edu.ucsc.neurobiology.vision.io.ParametersFile('C:\home\Pawel\nauka\StimchipPaper\2012grudzien\dyskusje\data002_old\data002000\data002000.params');
neuronFile = edu.ucsc.neurobiology.vision.io.NeuronFile('C:\home\Pawel\nauka\StimchipPaper\2012grudzien\dyskusje\data002_old\data002000\data002000.neurons');
idList = neuronFile.getIDList(); %this imports list of neurons IDs from the file that is defined above as 'neuronFile';

electrodeMap=edu.ucsc.neurobiology.vision.electrodemap.ElectrodeMapFactory.getElectrodeMap(1);

NeuronsIDs=[76 227 256 271 901 226 646 721 32 107 346 466 752 811 77 392 407 706 813 902];
StimElectrodes=[60 27 37 45 54 51 16 3 6 18 28 61];
StimElectrodes=zeros(21,64);
StimElectrodes(1,[60])=1;
StimElectrodes(2,[16 60])=1;
StimElectrodes(3,[18 60])=1;
StimElectrodes(4,[19 60])=1;
StimElectrodes(5,[3])=1;
StimElectrodes(7,[54])=1;
StimElectrodes(8,[54])=1;
StimElectrodes(13,[51])=1;
StimElectrodes(14,[60])=1;
StimElectrodes(16,[27])=1;
StimElectrodes(18,[51])=1;
StimElectrodes(19,[60 51])=1;

Channels=[1:8 10:24 26:56 58:64];
N=500;
L=40;
spikes=zeros(length(Channels),L);

figure(1)
clf
LineWidth=2;
for i=1:length(NeuronsIDs)
    NeuronID=NeuronsIDs(i)
    spikeTimes = neuronFile.getSpikeTimes(NeuronID)';
    
    for j=1:N
        t=spikeTimes(j+100);
        d0=rawFile.getData(t-8,L)';
        d1=d0(Channels+1,:); % add 1, since the first channel in the raw data is the TTL channel and not electrode 1
        spikes(:,:)=spikes(:,:)+double(d1);       
    end
    spikes=spikes/N;
    subplot(4,5,i);
    %subplot('position',[0.003,0.95-i*0.145,0.09,0.12]);    
    for j=1:length(Channels)
        spikes(j,:)=spikes(j,:)-mean(spikes(j,1:2));
    end
    % Normalization:
    spikes=spikes/max(max(abs(spikes)))*120;
    h=NS512_ShowEIAsCircles2(spikes,1,Channels,find(StimElectrodes(i,:)==1),[60 27 37 45 54 51 16 3 6 18 28 61],[-305 305],[-305 305]);    
    h=NS_AddFrameForArrayLayout(1,LineWidth);
    h=gca;
    set(h,'Visible','off');
end
break;
FullName=['C:\home\Pawel\nauka\StimchipPaper\2012grudzien\dyskusje\figure1.tif'];            
h=gcf;
set(h,'PaperUnits','inches');
set(h,'PaperSize',[20 14]);
set(h,'PaperPosition',[0 0 20 14]); 
%set(h,'PaperPosition',[0 0 10.7 13.5]); 
print(h, '-dtiff', '-r200', FullName);