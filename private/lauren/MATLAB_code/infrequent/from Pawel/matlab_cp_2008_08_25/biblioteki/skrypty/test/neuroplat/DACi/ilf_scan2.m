%Skrypt rysujacy rodzine charakterystyk neuroplata1.0.

cd /home/pawel/pliki/nauka/neuroplat;

figura1=1;
figura2=2;

a=importdata('pasmo_ch15_DAC_cal1_ilf20_ihf13_gainscan_Vpol50_restfloating.dat');
filename='pasmo2_ch28_DAC_cal1_ilfscan_ihf31_gain24_Vpol050_chip1.dat'
%filename='pasmo2_ch28_DAC_cal1_ilf20_ihf13_gainscan_Vpol050_plytka1.dat';
a=importdata(filename);

ilf=20;
ihf=13;
gain=24;
AWGclock=3.52;
AWGfile='CAL_SEQ.SEQ';
calib=1;
Vpol=0.5;


wzmoc=zeros(31,35);
for i=1:31
	wzmoc(i,:)=a(i*65+29,:);
	%wzmoc(i,:)=a(i*65+i+16,:);
	%wzmoc(i,:)=a(i*65+i+17,:);
end

wzmoc1=wzmoc(:,2:29)*1e6/135;
c=importdata('czest.dat')/2;
c1=c(1,1:length(c));

mnoznik=234/294; %z pomiaru:wysokosci piku oraz rzeczywistej amplitudy
wzmoc1=wzmoc1*mnoznik;

figure(figura1);
clf;

for i=1:31
	%if i~=8 & i~=61
		loglog(c1,wzmoc1(i,:));
		%plot(c1,wzmoc1(i,:));
		hold on;
	%end
end
hold off;

fontsize=18;
grid on;
axis([5 5000 50 1000]);
h=gca;
set(h,'FontSize',fontsize);
%legend('external sinus','external square','internal calibration');
xlabel('frequency');
ylabel('gain');

tekstx=30;
teksty=200;

tekst1=['data path: /home/pawel/pliki/nauka/neuroplat'];
tekst2=['data file: ' filename];
tekst3='matlab path: wfitj71e/home/pawel/pliki/matlab/tulboksy/biblioteki/skrypty/test/neuroplat';
tekst4='matlab file: ilf_scan2';
tekst5=['DACs: ilf=scan'   ' ihf=' num2str(ihf) ' gain=' num2str(gain) ' calib=' num2str(calib)];

opis=0;
if opis
for i=1:5
	switch i
	case 1
		tekst=tekst1;
	case 2
		tekst=tekst2;
	case 3
		tekst=tekst3;
	case 4
		tekst=tekst4;
	case 5
		tekst=tekst5;
	end
	ty=teksty*0.85^(i-1);
	a1=text(tekstx,ty,tekst);
	set(a1,'Interpreter','none');
	set(a1,'FontSize',12);
end
end

figure(figura2);
for i=1:64
	subplot(8,8,i);
	plot(a(65*27+i,:))
	axis([0 32 0 0.3]);
end


flow1=zeros(1,31);
fhigh1=zeros(1,31);

%dla kanalu 1 - ktory mierzony osobno (patrz importdata a1)
figure(3)
clf;
subplot(2,2,1);
for i=1:31
	max11=max(wzmoc1');
	max1=max11(i);
	s=wzmoc1(i,:);
	czest1=[7:0.5:4000];
	s=spline(c1,s,czest1);
	a=find(s>max1/sqrt(2));
	flow1(1,i)=czest1(min(a));
	fhigh1(1,i)=czest1(max(a));
	%subplot(8,8,i);
	%if i~=8	& i~=61 & i~=1
		loglog(czest1,s);
	%end
	hold on;
end
grid on;
axis([5 5000 50 1000]);
%axis([10 10000 50 1000]);
subplot(2,2,2);
plot(wzmoc1(:,18),'bd-');
axis([0 32 920 970]);
grid on;
xlabel('ilf DAC');
ylabel('gain');
subplot(2,2,3);
plot(flow1,'bd-');
axis([0 32 0 120]);
grid on;
xlabel('ilf DAC');
ylabel('flow');
subplot(2,2,4);
plot(fhigh1,'bd-');
axis([0 32 2300 2600]);
xlabel('ilf DAC');
ylabel('fhigh');
grid on;

figure(6);
plot(flow1,'bd-');
axis([0 32 0 120]);
h=gca;
set(h,'FontSize',fontsize);

xlabel('ilf DAC [LSB]');
ylabel('flow [Hz]');
grid on;

tabelka=zeros(3,16);
tabelka(1,:)=max11(1:2:31);
tabelka(2,:)=flow1(1:2:31);
tabelka(3,:)=fhigh1(1:2:31);

fid=fopen('ilf_scan.txt','w');
fprintf(fid,'%6.1f %6.2f %6.0f\n',tabelka);
fclose(fid);

dane=[c1' wzmoc1'];
f=fopen('ilf_scan_data.txt','w');
fprintf(f,'%8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f  %8.6f\n',dane);
%fwrite(f,dane,'double');
fclose(f);
q=importdata('ilf_scan_data.txt');
q
size(q)
size(dane)
