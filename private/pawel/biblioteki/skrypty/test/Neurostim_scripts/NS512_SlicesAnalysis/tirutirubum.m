clear
fid=fopen('D:\Home\Pawel\analysis\slices\2013\2010-09-14-0\data002_Matlab\SpikeTimesCombined\ID=6992c','r','ieee-le'); 
a=fread(fid,'int32');
fclose(fid);
l=length(a);
b1=reshape(a,5,l/5);

%p0=dane(3,:);
%pu0=unique(p0);

p1=b1(3,:);
pu1=unique(p1);

%for i=2:length(unique(p0))
%    ns0(i)=length(find(dane(3,:)==pu0(i)));
%end

for i=2:length(unique(p1))
    ns1(i)=length(find(b1(3,:)==pu1(i)));
end

figure(1)
clf
%subplot(1,2,1)
%plot([1:length(unique(p0))],ns0,[1:length(unique(p1))],ns1)

NeuronFilePath = 'D:\Home\Pawel\analysis\slices\2013\2010-09-14-0\data002\data002.neurons';
DuplicatesFilePath='D:\Home\Pawel\analysis\slices\2013\2010-09-14-0\data002_duplicates.txt';
PrimaryNeurons=NS512_IdentifyPrimaryNeurons_v2(NeuronFilePath,DuplicatesFilePath);

%ciekawe przypadki: 232, 
for n=201%1:length(PrimaryNeurons)
    fid=fopen(['D:\Home\Pawel\analysis\slices\2013\2010-09-14-0\data002_Matlab\SpikeTimesCombined\ID=' num2str(PrimaryNeurons(n)) 'c'],'r','ieee-le'); 
    a=fread(fid,'int32');
    fclose(fid);
    l=length(a);
    b0=reshape(a,5,l/5);
    pst=b0(4,:);
    b=b0(:,find(pst>20));
    %b=b0;
        
    p1=b(3,:);
    PatternsStim=unique(p1);
    for i=2:length(unique(p1))
        ns2(i)=length(find(b(3,:)==PatternsStim(i)));
        subplot(4,4,i)
        hist(b(4,find(b(3,:)==PatternsStim(i))))
    end
    length(b)/64
    plot(ns2)
    ile(n)=length(find(ns2>=50));
end