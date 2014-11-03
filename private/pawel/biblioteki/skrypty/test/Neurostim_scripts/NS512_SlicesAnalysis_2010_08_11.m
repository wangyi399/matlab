numbers=[126 197 356 324 441];
names={'Pattern_126_processed' 'Pattern_197_processed' 'Pattern_356_processed' 'Pattern_324_processed' 'Pattern_441_processed'};

Distances=[];
Delays=[];
Thresholds=[];
for i=5 %length(names)
    f=fopen(names{i},'r');
    j=fread(f,'float');
    h=reshape(j,length(j)/3,3)    
    fclose(f);
    
    sa=size(h)
    Pairs=ones(sa(1),2)*numbers(i);
    Pairs(:,2)=h(:,1);
       
    Dl=h(:,3);
    Delays=[Delays' Dl']';
    
    Dst=NS512_ElectrodesDistance(numbers(i),h(:,1),500)';
    Distances=[Distances' Dst']';
    
    figure(i)
    y=NS512_PlotGraphWithVelocities(Pairs,ArrayID,Dst./Dl/200);     
    
    h=gcf;
    FullName=['C:\home\pawel\2010\analysis\07_2010_Cultures\SpikesInStimData2\Processed\' 'p' num2str(numbers(i))]; 
    set(h,'PaperUnits','inches');
    set(h,'PaperSize',[18 9]);
    set(h,'PaperPosition',[0 0 18 9]); 
    print(h, '-dtiff', '-r80', FullName);
end

%figure(8)
%plot(Distances,Delays-0.3,'bd')
%axis([0 1500 0 7])