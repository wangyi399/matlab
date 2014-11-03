function PlotMultiElectrodes(TracesWithoutArtifact,ChannelsPlot,WaveformTypes,TimeCorelSpikes,MeanSpike);

%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    N = length(ChannelsPlot);
    SCT=size(TracesWithoutArtifact);
    figure(111);
    
    artifactsIndex = find(WaveformTypes == 0);      %Wskazniki, ktore przebiegi sa artefaktami
    spikeIndex = find(WaveformTypes == 1); 
    
    for i = 1:length(ChannelsPlot)
        if ChannelsPlot(i) 
            ChannelTraces = TracesWithoutArtifact(:,ChannelsPlot(i),:); %przebiegi na elektrodzie o numerze Channel lub sasiadach
            ChannelTraces2D = reshape(ChannelTraces,SCT(1),SCT(3));
            %Plotting Traces and artifacts
            subplot(5,N,i), h= plot(ChannelTraces2D');  
            text(20,-80,num2str(ChannelsPlot(i)),'Fontsize',16);
            set(h(artifactsIndex),'Color','Black');
            set(h(spikeIndex),'Color','Red');
            axis([0 40 -100 50]);
            grid on;
            h23=gca;
            set(h23, 'XTick', [0:5:40]);
            set(h23, 'YTick', [-100:20:40]);
           
            %Plotting Traces, artifacts and traces deselected due to timing constraints;
            subplot(5,N,i+N), ddd = plot(ChannelTraces2D');
            set(ddd(find(TimeCorelSpikes==0)),'Color','Black');
            set(ddd(find(TimeCorelSpikes==1)),'Color','Red');
            set(ddd(find(TimeCorelSpikes==2)),'Color','Blue');
            axis([0 40 -100 50]);
            h23=gca;
            set(h23, 'XTick', [0:5:40]);
            set(h23, 'YTick', [-100:20:40]);
            grid on;
            
            UniSpikesIndic = FindUnifiedSpikes_PR(ChannelTraces2D,-25); %Wektor wskaznikow (numery probek dla ktorych nastapilo przekroczenie progu)       
            g1=find(TimeCorelSpikes==1);         
            if length(g1)>0 % jesli sa jakies spiki z niewielkim jitterem
                g2=min(UniSpikesIndic(g1));
                if g2>4
                    UniSpikesIndic(g1)=UniSpikesIndic(g1)-4;
                else
                    UniSpikesIndic(g1)=UniSpikesIndic(g1)-g2+1;
                end
            end     
            %Wyznaczanie macierzy spikow uporzadkowanych czasowo oraz spiku usrednionego
            %[SpikeUnif, MeanSpike] = SpikeUnif_PR(ChannelTraces2D, UniSpikesIndic, TimeCorelSpikes); 
            
            %Plotting time correlated traces (correct spikes only)
            subplot(5,N,i+2*N), f = plot(SpikeUnif');
            text(20,-80,sprintf('%0.3g',MeanTracesRMS),'Fontsize',16);
            set(f,'Color','Red');
            axis([0 40 -100 50]);
            grid on;
            h23=gca;
            set(h23, 'XTick', [0:5:40]);
            set(h23, 'YTick', [-100:20:40]);
            
            %Plotting mean spike
            subplot(5,N,i+3*N), g = plot(MeanSpike');
            text(20,-80,strcat(sprintf('%0.4g',RMSPercentOfMeanSpike),'%'),'Fontsize',16);
            set(g,'Color','Blue');
            axis([0 40 -100 50]);
            grid on;
            h23=gca;
            set(h23, 'XTick', [0:5:40]);
            set(h23, 'YTick', [-100:20:40]);
        end
    end

end
