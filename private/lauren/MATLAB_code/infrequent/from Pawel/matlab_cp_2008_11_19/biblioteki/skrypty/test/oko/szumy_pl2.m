%f=[10:10:100 200:100:1000 2000:1000:10000];

clear f;
for i=1:35
	f(1,i)=1*sqrt(2)^(i-1);
end

Rin=[1e7 5e7];
Rs=[0 1e5 1e6 5e6];
Cin=150e-10;

f1=szumy_filtr(14000,12,f)
%f1=ones(1,length(f));
ffull=[f(1,1):1:f(1,i)];

s01=szumy_ploty(f,Rin(1,1),Rs(1,1),Cin).*f1;
s02=szumy_ploty(f,Rin(1,2),Rs(1,1),Cin).*f1;
s1=szumy_ploty(f,Rin(1,1),Rs(1,2),Cin).*f1;
s2=szumy_ploty(f,Rin(1,2),Rs(1,2),Cin).*f1;
s3=szumy_ploty(f,Rin(1,1),Rs(1,3),Cin).*f1;
s4=szumy_ploty(f,Rin(1,2),Rs(1,3),Cin).*f1;
s5=szumy_ploty(f,Rin(1,1),Rs(1,4),Cin).*f1;
s6=szumy_ploty(f,Rin(1,2),Rs(1,4),Cin).*f1;


c01=sqrt(sum(interp1(f,s01,ffull)))*1e6
c02=sqrt(sum(interp1(f,s02,ffull)))*1e6
c1=sqrt(sum(interp1(f,s1,ffull)))*1e6
c2=sqrt(sum(interp1(f,s2,ffull)))*1e6
c3=sqrt(sum(interp1(f,s3,ffull)))*1e6
c4=sqrt(sum(interp1(f,s4,ffull)))*1e6
c5=sqrt(sum(interp1(f,s5,ffull)))*1e6
c6=sqrt(sum(interp1(f,s6,ffull)))*1e6


%a0=importdata('nop04.dat');
%b0=importdata('nop09.dat');
%c0=importdata('nop60.dat');
%freq=importdata('freq.dat');

%a1=interp1(freq,a0,ffull);
%b1=interp1(freq,b0,ffull);
%c1=interp1(freq,c0,ffull);


%ax=axes;

%set(ax,'FontSize',12);

%a=loglog(f,s01,'ko-',f,s02,'k+-',f,s1,'ro-',f,s2,'r+-',f,s3,'bo-',f,s4,'b+-',f,s5,'mo-',f,s6,'m+-',ffull,a1,'c-',ffull,b1,'c-', ffull,c1,'c-');


a=loglog(f,s01,'ko-',f,s02,'k+-',f,s1,'ro-',f,s2,'r+-',f,s3,'bo-',f,s4,'b+-',f,s5,'mo-',f,s6,'m+-');
axis([1 100000 1e-20 1e-12]);
leg=legend(['Rin=10M  Rs=0  noise=' num2str(c01,2) 'uV'],  ['Rin=50M  Rs=0  noise=' num2str(c02,2) 'uV'],  ['Rin=10M  Rs=100k  noise=' num2str(c1,2) 'uV'],  ['Rin=50M  Rs=100k  noise=' num2str(c2,2) 'uV'],  ['Rin=10M  Rs=1M  noise=' num2str(c3,2) 'uV'],  ['Rin=50M  Rs=1M  noise=' num2str(c4,2) 'uV'],  ['Rin=10M  Rs=5M  noise=' num2str(c5,2) 'uV'],  ['Rin=50M  Rs=5M  noise=' num2str(c6,2) 'uV'] );


%leg=legend('Rin=10M  Rs=0' ,  'Rin=50M  Rs=0', 'Rin=10M  Rs=100k', 'Rin=50M  Rs=100k','Rin=10M  Rs=1M', 'Rin=50M  Rs=1M', 'Rin=10M  Rs=5M', 'Rin=50M  Rs=5M', 'preamp noise, Id=7uA', 'preamp noise, Id=24uA', 'preamp noise, Id=150uA');


%leg=legend('Rin=10M  Rs=0' ,  'Rin=50M  Rs=0', 'Rin=10M  Rs=100k', 'Rin=50M  Rs=100k','Rin=10M  Rs=1M', 'Rin=50M  Rs=1M', 'Rin=10M  Rs=5M', 'Rin=50M  Rs=5M');


ax=gca
set(ax,'FontSize',12);

set(leg,'FontSize',12);

tit=title('C_{c}=15nF');
set(tit,'FontSize',15);

set(a(1,1),'LineWidth',2);
set(a(1,1),'MarkerSize',8);

set(a(2,1),'LineWidth',2);
set(a(2,1),'MarkerSize',10)

set(a(3,1),'LineWidth',2);
set(a(3,1),'MarkerSize',8)
i
set(a(4,1),'LineWidth',2);
set(a(4,1),'MarkerSize',10)

set(a(5,1),'LineWidth',2);
set(a(5,1),'MarkerSize',8)

set(a(6,1),'LineWidth',2);
set(a(6,1),'MarkerSize',10)

set(a(7,1),'LineWidth',2);
set(a(7,1),'MarkerSize',8)

set(a(8,1),'LineWidth',2);
set(a(8,1),'MarkerSize',10);

%set(a(9,1),'LineWidth',2);
%set(a(9,1),'MarkerSize',10)
%set(a(9,1),'Color',[0.6 0 0]);

%set(a(10,1),'LineWidth',2);
%set(a(10,1),'MarkerSize',8)
%set(a(10,1),'Color',[0 0.6 0]);


%set(a(11,1),'LineWidth',2);
%set(a(11,1),'MarkerSize',10);
%set(a(11,1),'Color',[0 0 0.6]);



xl=xlabel('frequency [Hz]');
yl=ylabel('V^2/Hz');


set(xl,'FontSize',12);
set(yl,'FontSize',12);

figure(2);
af=loglog(f,f1,'ko-');
set(af,'LineWidth',2);
set(af,'MarkerSize',8);

xl=xlabel('frequency [Hz]');
yl=ylabel('gain');

set(xl,'FontSize',12);
set(yl,'FontSize',12);

aft=title('Filter response');
set(aft,'FontSize',15);

fa=gca;
set(fa,'FontSize',12);
axis([1 1e5 1e-5 1]);

grid on;
