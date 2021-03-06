%function WaveformTypes=NS512_LocalResponses(Traces,SpikeThreshold,Responsesthreshold,N);
%DataPath,PatternNumber,Movies,GoodChannels,TracesNumberLimit,EventNumber,ClusterFileName,NS_GlobalConstants);
DataPath='E:\pawel\analysis\retina\2009-11-27-0\data001';
[Traces,ArtifactDataTraces,Channels]=NS_ReadPreprocessedData(DataPath,DataPath,0,4,51,0,0);
N=20;

ST=size(Traces);
b=mean(Traces);

%subtract average of all traces:
for i=1:ST(1)
    Traces(i,:,:)=Traces(i,:,:)-b;
end
c=min(min(Traces,[],3),[],2);
[d,e]=sort(c); 

Artifact=mean(Traces(e(1:N),:,:));
%subtract the artifact estimate based on N traces with largest minimum
%value:
for i=1:ST(1)
    Traces(i,:,:)=Traces(i,:,:)-Artifact;
end
