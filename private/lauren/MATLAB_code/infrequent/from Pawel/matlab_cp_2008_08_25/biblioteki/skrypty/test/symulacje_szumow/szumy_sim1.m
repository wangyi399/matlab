Rs=2500e3;
%Rs=0;
Re=6e6;
Ce=1.5e-9;
%Ce=Ce*1000;

Cp=200e-12;
Rin=10e6;
fgorno=2;
fdolno=3000;

kT=1.38e-3*300; %o dwadziescia rzedow wielkosci za duzo!!!

step=0.5;
f=[1:step:50000];
omega=2*pi*f;

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

%filtrowanie
%a) gornoprzep.
filtr1=(1+(f./fdolno)).^(-2);
filtr2=(f./fgorno).^2.*(1+(f./fgorno)).^(-2);
filtr=filtr1.*filtr2;
Urin=Urin.*filtr;
Urs=Urs.*filtr;
Ure=Ure.*filtr;

figure(2);
calk=Urin+Urs+Ure;
loglog(f,Urin,f,Urs,f,Ure,f,calk);
axis([1 max(f) 1 1e9])
grid on;
legend('Irin','Irs','Ire','calk.');
nap_Rin=sqrt(sum(Urin)*step)/1e10  %/1e10 - bo przedtem zbyt duza wartosc kT!!
nap_Rs=sqrt(sum(Urs)*step)/1e10
nap_calk=sqrt(sum(calk)*step)/1e10
%sum(Ire)