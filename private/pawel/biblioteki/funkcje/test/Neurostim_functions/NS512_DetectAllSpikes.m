function Spikes=NS512_DetectAllSpikes(DataTraces, Channels, Threshold1, Threshold2)

SDT=size(DataTraces);
Spikes=[];
SpikeIndex=0;
for Channel=Channels
    Channel
    ChannelData=reshape(DataTraces(:,Channel,:),SDT(1),SDT(3));
    %figure(11)
    %subplot(2,1,1);
    %plot(ChannelData'-Threshold1)
    %subplot(2,1,2);
    %plot(sign(ChannelData-Threshold1));
    Threshold1;
    Threshold2;
    [Threshold1TraceIndex,Threshold1SampleIndex]=find(diff(sign(ChannelData-Threshold1),1,2)==-2);
    [Threshold2TraceIndex,Threshold2SampleIndex]=find(diff(sign(ChannelData-Threshold2),1,2)==-2);    
    SuspectedTraces=unique(Threshold1TraceIndex);
    for st=1:length(SuspectedTraces)
        SuspectedTrace=SuspectedTraces(st);
        Threshold1CrossingForGivenTrace=[0 Threshold1SampleIndex(find(Threshold1TraceIndex==SuspectedTrace))'];
        Threshold2CrossingForGivenTrace=Threshold2SampleIndex(find(Threshold2TraceIndex==SuspectedTrace))';
        for SuspectedSpike=2:length(Threshold1CrossingForGivenTrace)
            if(find(Threshold2CrossingForGivenTrace<=Threshold1CrossingForGivenTrace(SuspectedSpike) & Threshold2CrossingForGivenTrace>=Threshold1CrossingForGivenTrace(SuspectedSpike-1)))
                SpikeIndex=SpikeIndex+1;
                Spikes(SpikeIndex,1)=Channel;
                Spikes(SpikeIndex,2)=SuspectedTrace;
                Spikes(SpikeIndex,3)=Threshold1CrossingForGivenTrace(SuspectedSpike);
            end
        end
    end        

end