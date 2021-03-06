function y=NS512_PlotGraphWithCommonCenter(Pairs,ArrayID);

electrodeMap=edu.ucsc.neurobiology.vision.electrodemap.ElectrodeMapFactory.getElectrodeMap(ArrayID);
    
SP=size(Pairs);
for i=1:SP(1)
    x(1)=0;
    y(1)=0;
    x(2)=electrodeMap.getXPosition(Pairs(i,1))-electrodeMap.getXPosition(Pairs(i,2));
    y(2)=electrodeMap.getYPosition(Pairs(i,1))-electrodeMap.getYPosition(Pairs(i,2));
               
    h=plot(x,y);
    set(h,'LineWidth',1);    
    
    h=plot(x(2),y(2),'bo');
    set(h,'MarkerSize',12);
    
    hold on;    
end 