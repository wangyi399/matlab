Ut=26e-3;
Kappa=0.7;

Vt0=0.766;
Cox=4.5e-3; %unit: farad/square_meter
Muop=126e-4;
I0=((2*Muop*Cox*(Ut^2))/Kappa)*exp((-Kappa*Vt0)/Ut);

%I0=1e-16;
W=1e-6;
L=100e-6;

Vd=1.65;
Vs=[1.64:0.0001:1.66];
%Vd=[1.6:0.0001:1.7];

Vw=Vs;
Vg=Vd;

Vg=1.2795;

Id=I0*W/L*exp(Kappa*(Vw-Vg)/Ut).*(exp((Vs-Vw)/Ut)-exp((Vd-Vw)/Ut));
figure(3)
subplot(1,3,1)
plot(Id)
grid on
subplot(1,3,2)
plot(diff(Id)*1e4)
grid on
subplot(1,3,3)
plot(Id,Vs,'bd-');
grid on

Isig=[min(Id):abs(min(Id))/200:-min(Id)]
t_step=1e-3;
fs=10;
t=[t_step:t_step:10];

s=abs(min(Id))*sin(6.28*fs*t);
Vsig=spline(Id,Vs,s);

df=1/max(t)
f=[0:df:1/t_step-df]

figure(4)
subplot(2,2,1)
plot(t,s,'bd-')
subplot(2,2,2)
plot(t,Vsig,'bd-')
subplot(2,2,3)
semilogy(f,abs(fft(s)))
h=gca
set(h,'XLim',[0 max(f)/2])
grid on
subplot(2,2,4)
widmo=abs(fft(Vsig))
plot(f,widmo/max(widmo(4:length(widmo))))
grid on
h=gca
set(h,'XLim',[0 max(f)/2])


%slin=