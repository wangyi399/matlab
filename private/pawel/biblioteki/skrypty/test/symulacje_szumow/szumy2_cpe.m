Rs=250e3;
%Rs=0;
Re=600e8;
Ce=1.5e-9;
%Ce=Ce*1000;

Cp=10e-12;
Rin=200e9;
omega_gr=1/(Cp*Rin);
f_gr=omega_gr/6.28
kT=1.38e-3*300; %o dwadziescia rzedow wielkosci za duzo!!!
 
f_step=0.1;
f=[0.5:f_step:200];
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

figure(1);
calk=Urin+Urs+Ure;
loglog(f,Urin,f,Urs,f,Ure,f,calk);
axis([min(f) max(f) 1 1e9])
grid on;
legend('Irin','Irs','Ire','calk.');
nap_Rin=sqrt(sum(Urin))/1e10*sqrt(f_step)  %/1e10 - bo przedtem zbyt duza wartosc kT!!
nap_Rs=sqrt(sum(Urs))/1e10*sqrt(f_step) 
nap_calk=sqrt(sum(calk))/1e10*sqrt(f_step) 
%sum(Ire)