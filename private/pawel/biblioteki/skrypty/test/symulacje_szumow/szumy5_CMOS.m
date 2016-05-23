%Szumy wzmacniacza CMOS s� modelowane dla tranzystor�w PMOS, proces AMS
%0.35 um. Tranzystory w parze r�nicowej pracuj�w s�abej inwersji
%(2014-01-12).

%sta�e fizyczne:     
kT=1.38e-3*300; %o dwadziescia rzedow wielkosci za duzo!!! 300 to temepratura w Kelvinach
Ut=26e-3;

%Og�lne sta�e dla AMS 0.35 um:
Cox=4.5e-3; %unit: farad/square_meter
Muon=370e-4; %square meter/(Volt*sec) 
Muop=126e-4;
Kappa=0.7;

%Wymiary i polaryzacja tranzystor�w:
W=50e-6;
L=18e-6;
Id=1e-6;

%Flicker noise constants:
% typical:
KF=1.191e-26;
AF=1.461;

% worst case:
%KF=1.827e-26;
%AF=1.405

% 1. Szumy CMOS
%a) szum termiczy pary r�nicowej
gmp=Kappa*Id/Ut
WhiteNoiseDensity=16/3*kT*(1e-20)/gmp; %dla dw�ch tranzystor�w wg Majidzadeh2011, wz�r 19
WhiteNoiseSigma=(WhiteNoiseDensity*1e4)^(1/2);

%b) szum 1/f pary r�nicowej
Flicker=KF/(Cox*W*L)*Id^AF/gmp^2*2; %the "*2" term comes from two transistors! Czy to prawda tak�e dla s�abej inwrsji??

%c) szum rezystancji obci��enia RL
RL=3000e3;
URL=4*kT*1e-20*RL/((gmp*RL/2)^2);

%d) parametry elektrody
Rs=100e3;
Re=6e12;
Ce=1e-9;

Cp=100e-12;
Rin=16e9;
omega_gr=1/(Cp*Rin);
f_gr=omega_gr/6.28
 
f_step=0.01;
%f=[0.1:f_step:10000];
f=[0.1:f_step:10000];
omega=2*pi*f;
Ugm=ones(1,length(f))*WhiteNoiseDensity*1e20;
UFlicker=Flicker./f*1e20;
Url=ones(1,length(f))*URL*1e20;

Zc=Re./(1+j*omega*Re*Ce)+1./(j*omega*Cp);

a=abs(Rs+Rin+Zc);
Ct=4*kT*1./(a.^2);
clear a; 

Irs=Ct*Rs;

a=abs(Rs+Zc);
Irin=Ct.*a.^2/Rin;
clear a;

a=abs(1+j*omega*Re*Ce);
Ire=Ct*Re./a.^2;

Urin=Irin*Rin^2;
Urs=Irs*Rin^2;
Ure=Ire*Rin^2;

figure(2);
calk=Urin+Urs+Ure+Ugm+UFlicker+Url;
loglog(f,Urin,f,Urs,f,Ure,f,Ugm,f,UFlicker);
axis([min(f) max(f) 1 1e9])
grid on;
legend('Urin','Urs','Ure','Ugm','Ufl');
nap_Rin=sqrt(sum(Urin))/1e10*sqrt(f_step)  %/1e10 - bo przedtem zbyt duza wartosc kT!!
nap_Rs=sqrt(sum(Urs))/1e10*sqrt(f_step) 
%nap_calk=sqrt(sum(calk))/1e10*sqrt(f_step)
nap_gm=sqrt(sum(Ugm))/1e10*sqrt(f_step)
nap_flick=sqrt(sum(UFlicker))/1e10*sqrt(f_step);
nap_RL=sqrt(sum(Url))/1e10*sqrt(f_step)
nap_calk=sqrt(sum(calk))/1e10*sqrt(f_step)
%sum(Ire)
K=gmp*RL;

% Matching:
Avt=15e-9;
V1=sqrt(2*Id/(Muop*Cox*W/L));
SigmaId=sqrt(4*Avt^2/(2*W*L*V1^2));
SigmaDC=SigmaId*Id*sqrt(2)*RL;

Vnonlin=5e-3;
gmp_nonlin=(2*Muop*Cox)^(1/2)*(W/L*(Id-gmp*Vnonlin))^(1/2);
GainChange=(gmp-gmp_nonlin)/gmp*100; %a jaka nieliniowosc RL dla takiej amplitudy?