function [Traces,Artifact,e]=NS512_SubtractLocalArtifact(Traces,N);

%This function estimates the artifact shape and subtracts it from all the
%traces. For the function to work properly, the "Traces" should include at
%least "N" events with no spikes (artifacts only), however, if the number
%of "artifacts only is just slightly lower, the estimated artifact shape
%will be only slightly distorted.
%The function works as following:
%1) Average all the Traces and subtract the average from all Traces
%2) Find minimal value for each trace
%3) Sort all the traces from the point of view of the minimal value (most
%negative to most positive) - hopefully, the "artifact only" traces are now
%indexed by 1 to something. The sorting is done independently for each
%channel!
%4) Take N first traces, average and this is the estimated artifact
%N - how many traces are taken for estimation of the artifact shape

ST=size(Traces);
b=mean(Traces);

for i=1:ST(1)
    Traces(i,:,:)=Traces(i,:,:)-b;
end
c=min(Traces,[],3);
[~,e]=sort(c,1); %sort traces for each channel independently, from smallest
              % to largest maximum value to idnetify "artifact only" traces

Artifact=zeros(1,ST(2),ST(3));
for i=1:ST(2)
    Artifact(1,i,:)=mean(Traces(e(ST(1)-N:ST(1),i),i,:));
end

for i=1:ST(1)
    Traces(i,:,:)=Traces(i,:,:)-Artifact;
end