OutputPath='C:\home\Pawel\nauka\512stim_paper\NeuronAnalysis\2010-09-14-0\data002\SpikeTimesCombined';
GaussesFilesPath='C:\home\Pawel\nauka\512stim_paper\NeuronAnalysis\2010-09-14-0\data002\GaussesFiles\';

s1=sign(AllGaussesStat(:,1)-1.2*AllGaussesStat(:,2))
s2=sign(AllGaussesStat(:,1)-1.2*AllGaussesStat(:,3))
s3=s1+s2
break
AllGaussesStat=[];
for n=1:length(PrimaryNeurons) % dla danego neuronu...
    % 1) Wczytaj spike times, w?aczaj?c informacj? o ostatniej i
    % przedostatniej elektrodzie
    PrimaryNeurons(n)
    fid=fopen([OutputPath '\ID=' num2str(PrimaryNeurons(n)) 'c'],'r','ieee-le'); 
    a=fread(fid,'int32');
    fclose(fid);
    l=length(a);
    b0=reshape(a,6,l/6);
    pst=b0(4,:);
    b=b0(:,find(pst>20));
    
    %p1=b(3,:);
    %PatternsStim=unique(p1);
    
    % 2) Wczytaj informacje o Gaussach    
    fid=fopen([GaussesFilesPath 'AllGausses_n' num2str(PrimaryNeurons(n))],'r','ieee-le'); 
    a=fread(fid,'double');
    fclose(fid);
    g0=reshape(a,length(a)/6,6); % pattern, neuron, A, tau, sigma, blad
    
    g=g0(find(g0(:,6)<0.1),:);
    
    sg=size(g);
    for ig=1:sg(1)
        GaussData=g(ig,:);
        TimeToCheck0=round([GaussData(4)-3*GaussData(5):GaussData(4)+3*GaussData(5)]);
        TimeToCheck=TimeToCheck0(find(TimeToCheck0>20));
                        
        FindSpikes0=find(b(4,:)>=min(TimeToCheck));
        FindSpikes1=find(b(4,:)<=max(TimeToCheck));
        FindSpikesForTime=intersect(FindSpikes0,FindSpikes1);
        
        PatternForGauss=GaussData(1);
        FindAllSpikesForLastPattern=find(b(3,:)==PatternForGauss);                
        FindSpikesForLastPattern=intersect(FindSpikesForTime,FindAllSpikesForLastPattern);
        a1=length(FindSpikesForLastPattern);
        
        % Tutaj znajdumey obydwa poprzedzaj?ce patterny dla danego patternu
        PreviousPatterns=unique(b(6,FindAllSpikesForLastPattern));
        FindAllSpikesForPreviousPattern1=find(b(6,:)==PreviousPatterns(1));   
        FindSpikesForPreviousPattern1=intersect(FindSpikesForTime,FindAllSpikesForPreviousPattern1);
        a2=length(FindSpikesForPreviousPattern1);
        
        if length(PreviousPatterns)==2
            FindAllSpikesForPreviousPattern2=find(b(6,:)==PreviousPatterns(2));   
            FindSpikesForPreviousPattern2=intersect(FindSpikesForTime,FindAllSpikesForPreviousPattern2);
            a3=length(FindSpikesForPreviousPattern2);
        else
            a3=0;
        end
        
        %[a1 a2 a3]
        AllGaussesStat=[AllGaussesStat' [a1 a2 a3]']';
        %hist(b(4,FindSpikesForLastPattern))
        %refresh
        %pause(1)s1
    end
    
    %for i=1:min(length(unique(p1)),64)            
end
AllGaussesStat