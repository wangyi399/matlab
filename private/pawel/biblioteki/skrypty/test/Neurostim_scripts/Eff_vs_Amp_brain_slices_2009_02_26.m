PatternNumber=6; %rec. at 60
movies50=[67:3:88];
eff50=[0 12 0 0 0 0 20 100];

movies100=[47:3:86];
eff100=[0 17 0 0 0 0 0 0 0 0 0 0 0 100];

PatternNumber=49; %rec. 53
movies50=[40:3:64];
eff50=[0 47 65 100 65 63 100 100 100];
movies100=[38:3:53];
eff100=[0 8 12 73 100 100]
%movies200=[48:
%eff200=[0 10 20 42 55 46 95 77 75 95 

PatternNumber=54;
movies50=[40:3:85];
eff50=[0 20 100 100 100 100 100 86 100 100 100 100 100 100 100 100];
movies100=[47:3:86];
eff100=[0 44 31 39 100 81 100 100 100 100 100 100 100 100];
movies200=[78:3:87];
eff200=[0 2 13 53];


PatterNumber=59; %rec. na 47
movies50=[28:3:49];
eff50=[0 68 100 100 100 0 54 100];
movies100=[26:3:47];
eff100=[0 11 100 93 100 40 0 100];
movies200=[45:3:66];
eff200=[0 22 60 42 5 33 80 100];


PreprocessedDataPath='C:\Users\pawel\analysis\2008-12-06-0\data005';
for i=1:length(movies50)
    Amps50(i)=NS_PulseAmplitude(PreprocessedDataPath,PatternNumber,PatternNumber,movies50(i));
end
for i=1:length(movies100)
    Amps100(i)=NS_PulseAmplitude(PreprocessedDataPath,PatternNumber,PatternNumber,movies100(i));
end
for i=1:length(movies200)
    Amps200(i)=NS_PulseAmplitude(PreprocessedDataPath,PatternNumber,PatternNumber,movies200(i));
end
Fsize=26;
figure(11)
h=plot(Amps50,eff50,'bd-',Amps100,eff100,'ro-',Amps200,eff200,'kx-');
set(h,'MarkerSize',20)
set(h,'LineWidth',2);
h=legend('50\mus','100\mus','200\mus');
set(h,'FontSize',Fsize);
h=gca;
set(h,'FontSize',Fsize);
h=xlabel('pulse amplitude [\muA]');
set(h,'FontSize',Fsize);
h=ylabel('stimulation efficacy [%]');
set(h,'FontSize',Fsize);
%plot(movies50,eff50','bd-',movies100,eff100,'rd-',movies200,eff200,'kd-');
grid on;

figure(12)
h=plot(Amps50*50/1000,eff50,'bd-',Amps100*100/1000,eff100,'ro-',Amps200*200/1000,eff200,'kx-');
set(h,'MarkerSize',20)
set(h,'LineWidth',2);
h=legend('50\mus','100\mus','200\mus');
set(h,'FontSize',Fsize);
h=gca;
set(h,'FontSize',Fsize);
h=xlabel('charge of the negative phase [nC]');
set(h,'FontSize',Fsize);
h=ylabel('stimulation efficacy [%]');
set(h,'FontSize',Fsize);
grid on;