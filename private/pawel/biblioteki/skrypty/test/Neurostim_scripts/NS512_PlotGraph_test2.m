Pairs(:,1)=[461 433 393 493 467 496 393 482 467 419 393 421 385 433 433 467 379 385 393 418 385 418 467 482 433 385 452 496 461 452 452];
Pairs(:,2)=[453 482 387 455 484 397 397 489 493 429 394 463 405 497 466 434 403 403 403 499 404 500 504 505 505 414 414 414 411 415 444];
NeuronIDs=[1 5 6 7 11 13 14 16 17 18 20 25 30 31 32 34 36 37 38 41 44 45 48 51 52 54 55 56 61 62 65];
Patterns=[2 7 9 10 15 18 18 19 20 20 21 26 34 35 37 39 41 41 41 43 45 47 48 51 51 54 54 54 57 58 63];
Movies=[47 53 50 38 50 43 48 47 41 49 50 55 35 26 26 43 32 41 42 38 53 39 37 34 39 31 40 43 52 45 54];
Latencies=[0.5 1.5 0.7 1.6 0.6 2.4 1.1 1.1 0.7 0.6 0.45  1.6 1.2 1.6 1.05 1.3 1.5 1.25 0.7 3.2 1.0 3.5 1.7 0.9 1.8 1.15 1.45 2 2.8 1.7 0.5];

figure(3)
y=NS512_PlotGraph(Pairs,500);
axis([400 1000 -500 500]);
h=gca;
set(h,'FontSize',14);
h=xlabel('microns');
set(h,'FontSize',14);
h=ylabel('microns');
set(h,'FontSize',14);

figure(4)
Angles=NS512_ConnectivityAngle(Pairs,500);
y=NS512_PlotGraphWithCommonCenter(Pairs,500);
h=gca;
set(h,'FontSize',14);
h=xlabel('microns');
set(h,'FontSize',14);
h=ylabel('microns');
set(h,'FontSize',14);

electrodeMap=edu.ucsc.neurobiology.vision.electrodemap.ElectrodeMapFactory.getElectrodeMap(500);
for i=1:length(Pairs)
    x1=electrodeMap.getXPosition(Pairs(i,1));
    y1=electrodeMap.getYPosition(Pairs(i,1));
    x2=electrodeMap.getXPosition(Pairs(i,2));
    y2=electrodeMap.getYPosition(Pairs(i,2));
    Distances(i)=sqrt((x1-x2)^2+(y1-y2)^2);
end
p=polyfit(Distances,Latencies,1);
l=[0:800];
y=polyval(p,l);
figure(2);
plot(l,y,'k-',Distances,Latencies,'bd');
grid on;
h=gca;
set(h,'FontSize',16);
xlabel('distance [microns]');
ylabel('latency [ms]');
h=text(30,3.2,'latency=0.0037*distance+0.29');
set(h,'FontSize',16);
h=text(30,2.7,'velocity: 0.27 m/s');
set(h,'FontSize',16);

%break;
RecEl=Pairs(:,1);
g=histc(RecEl,[1:512]);
k=find(g>0); %all the electrodes that show some signals
figure(2)
for i=1:length(Distances)
    NeuronID=find(k==RecEl(i))
    h=text(Distances(i)+4,Latencies(i),num2str(NeuronID));
    set(h,'FontSize',14);
end