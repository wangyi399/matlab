cd /home/pawel/pliki/nauka/neuroplat;

a=importdata('pasmo_ch02_DAC1.dat');
b=a(4,:);
c=importdata('czest.dat');
c1=c(1,1:length(c));
b1=b(1,2:29)*1e6/135;

% 1. Pomiar z zewnetrznym generatorem:
% a) czestotliwosci - wg kolejnosci pomiaru:
f=[19 57 95 38 114 190 76 228 380 156 468 780 306 918 1530 612 1836 3060 1220 3660 6100 2440 7320 11 33 55];

% b) wspolczynniki wg pomiaru sinusem:
g1=[196 251 256 241 258 258 255 259 258 258 256 249 258 246 225 255 214 169 237 151 102 190 87 133 235 251]/1000;

% c) wspolczynniki wg pomiaru prostokatem:
g2=[184 229 235 233 247 249 250 256 255 256 254 248 257 244 224 252 213 168 235 150 101 190 86 125 217 231]/1000;

dane0=[f' g1' g2']';
dane=sort(dane0,2);

[f0,i]=sort(f);
g10=g1(i)*1e6/234;
g20=g2(i)*1e6/234;

mnoznik=234/294; %z pomiaru:wysokosci piku oraz rzeczywistej amplitudy
g10=g10*mnoznik;
g20=g20*mnoznik;
b1=b1*mnoznik;

figure(5);
loglog(f0,g10,'bd-',f0,g20,'r*-',c1,b1,'k+-');

%loglog(c1,b1,'bd-',f,g,'r*-');
grid on;
axis([10 10000 200 1000]);
legend('external sinus','external square','internal calibration');
xlabel('frequency');
ylabel('gain');
