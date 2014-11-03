cd /home/pawel/pliki/nauka/neuroplat;

ilf=20;
ihf=13;
igain=24;

a=importdata('pasmo_ch15_DAC_cal1_ilfscan_ihf13_gain24_Vpol050_restfloating.dat');
a=importdata('pasmo_ch25_DAC_cal1_ilfscan_ihf31_gain24_Vpol050.dat');
a=importdata(' pasmo2_ch28_DAC_cal1_ilfscan_ihf31_gain24_Vpol050.dat');
wzmoc=zeros(31,35);
for i=1:31
	wzmoc(i,:)=a(i*65+30,:);
	%wzmoc(i,:)=a(i*65+i+16,:);
	%wzmoc(i,:)=a(i*65+i+17,:);
end

wzmoc1=wzmoc(:,2:29)*1e6/135;
c=importdata('czest.dat')/2;
c1=c(1,1:length(c));

mnoznik=234/294; %z pomiaru:wysokosci piku oraz rzeczywistej amplitudy
wzmoc1=wzmoc1*mnoznik;

figure(1);
clf;

for i=1:31
	%if i~=2 & i~=31 & i~=27 & i~=17
		loglog(c1,wzmoc1(i,:));
		hold on;
	%end
end
hold off;

grid on;
axis([5 5000 50 1000]);
%legend('external sinus','external square','internal calibration');
xlabel('frequency');
ylabel('gain');

figure(2);
for i=1:64
	subplot(8,8,i);
	plot(a(65*27+i,:))
	axis([0 32 0 0.3]);
end