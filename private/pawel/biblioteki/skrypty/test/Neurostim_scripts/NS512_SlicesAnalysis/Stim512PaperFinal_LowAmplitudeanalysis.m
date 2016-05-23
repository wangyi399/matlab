load C:\pawel\nauka\512paper\SpikesAnalysis\mysz\AllSpikes2 %AllSpikes2mouse
AllSpikes2mouse=AllSpikes2;
load C:\pawel\nauka\512paper\SpikesAnalysis\szczur\AllSpikes2 %AllSpikes2rat
AllSpikes2rat=AllSpikes2;

% 1. Mysz
Amplitude=1;
sp1=zeros(1,144);
sp1a=sp1;
sp1b=sp1;
sp2=sp1;
sp2a=sp1;
sp2b=sp1;
for i=1:144
    s1=reshape(AllSpikes2mouse(Amplitude,i,:),1,512);
    %if find(s1>5)
        % tutaj przypadki ktore przeszly test 
        sp1a(i)=length(find(s1>25));
        sp1b(i)=length(find(s1>40));
        
        sp2a(i)=length(find(abs(s1)>25));
        sp2b(i)=length(find(abs(s1)>40));
        
        %sp2(i)=length(find(abs(s1)>15));
    %end
end
sum(sp1)
sum(sp2)

Amplitude=1;
sp3=zeros(1,64);
sp3a=sp3;
sp3b=sp3;
sp4=sp3;
sp4a=sp3;
sp4b=sp3;
for i=1:64
    s1=reshape(AllSpikes2rat(Amplitude,i,:),1,512);
    %if find(s1>5)
        % tutaj przypadki ktore przeszly test 
        sp3a(i)=length(find(s1>25));
        sp3b(i)=length(find(s1>40));
        
        sp4a(i)=length(find(abs(s1)>25));
        sp4b(i)=length(find(abs(s1)>40));
        
        %sp2(i)=length(find(abs(s1)>15));
    %end
end
 plot(sp3a)