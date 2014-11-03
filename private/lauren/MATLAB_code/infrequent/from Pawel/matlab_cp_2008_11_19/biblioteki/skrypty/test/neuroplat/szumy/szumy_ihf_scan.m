% Skrypt do analizy wynikow z pomiarow szumow. Pomiar za pomoca progqramu w Labview "noise2a", lub "noise2", z katalogu "listopad2003/testy" w "moich dokumentach na Windows. 
%Plik zawiera wyestymowana gestosc widmowa. Fp=20000. N=32768. Normalizacja: FFT, modul kwadrat, razy 4, podzielic przez N, razy fp, razy 1e6. Aby obliczyc sigme, trzeba wrocic do danych przed normalizacja, posumowac CALE widmo (a nie pol), spierwiastkowac, podzielic przez N.
%Z pliku mozna tez wyciagnac dane o offsecie. Gestosc widmowa - kolumny 2 do 65, offsety - kolumna 1, wiersze od 2 do 65.
%Ten skrypt obsluguje kilka plikow.

cd /home/pawel/pliki/nauka/neuroplat;
a1=importdata('szumy_i_offsety_DAC_ilf20_ihf08_gain24_Vpol035.dat');
a2=importdata('szumy_i_offsety_DAC_ilf20_ihf13_gain24_Vpol035.dat');
a3=importdata('szumy_i_offsety_DAC_ilf20_ihf31_gain24_Vpol035.dat');

fp=20000;
N=32768;
f=[1:16383]/N*fp;

figura1=1;
figura2=2;
figura3=4;

figure(figura1);
for i=1:64
	%figure(figura1);
	%subplot(8,8,i);
	%loglog(f,a(i+1,2:16384)*1e-6);
	%grid on;	
end

figure(figura3);
fontsize=14;

gain=900;
s1=a1(2,:)*1e-6/gain/gain;
s2=a2(2,:)*1e-6/gain/gain;
s3=a3(2,:)*1e-6/gain/gain;

si1=sqrt(sum(s1)/4*N*fp)/N;
si01=si1*1e6;

si2=sqrt(sum(s2)/4*N*fp)/N;
si02=si2*1e6;

si3=sqrt(sum(s3)/4*N*fp)/N;
si03=si3*1e6;


loglog(f,s1(1,2:16384),f,s2(1,2:16384),f,s3(1,2:16384));

h=legend(['ihfDAC=8 sigma=' sprintf('%4.2f',si01) 'uV'],['ihfDAC=13 sigma=' sprintf('%4.2f',si02) 'uV'],['ihfDAC=31 sigma=' sprintf('%4.2f',si03) 'uV']);

axis([5 10000 1e-16 1e-12])'
set(h,'FontSize',fontsize);
h=xlabel('frequency[Hz]');
set(h,'FontSize',fontsize);
h=ylabel('power spectrum density [V^{2}/Hz]');
set(h,'FontSize',fontsize);
h=title('noise vs ihf_DAC, ilf_DAC=20, ipre_DAC=24, Vpol=0.35V');
set(h,'FontSize',fontsize);
set(h,'Interpreter','none');
grid on;

figure(figura2);
plot(a(:,1))
grid on;