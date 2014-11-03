%f=[10:10:100 200:100:1000 2000:1000:10000];

clear f;
for i=1:31
	f(1,i)=1*sqrt(2)^(i-1);
end

Rin=[1e7 5e7];
Rs=[0 1e6 5e6 1e5];
Cin=150e-10;

f1=szumy_filtr(3000,60,f);
full=[f(1,1):1:f(1,i)];

s01=szumy_ploty(f,Rin(1,1),Rs(1,1),Cin).*f1;
s02=szumy_ploty(f,Rin(1,2),Rs(1,1),Cin).*f1;
s1=szumy_ploty(f,Rin(1,1),Rs(1,2),Cin).*f1;
s2=szumy_ploty(f,Rin(1,2),Rs(1,2),Cin).*f1;
s3=szumy_ploty(f,Rin(1,1),Rs(1,3),Cin).*f1;
s4=szumy_ploty(f,Rin(1,2),Rs(1,3),Cin).*f1;
s5=szumy_ploty(f,Rin(1,1),Rs(1,4),Cin).*f1;
s6=szumy_ploty(f,Rin(1,2),Rs(1,4),Cin).*f1;


c01=sqrt(sum(interp1(f,s01,ffull)))
c02=sqrt(sum(interp1(f,s02,ffull)))
c1=sqrt(sum(interp1(f,s1,ffull)))
c2=sqrt(sum(interp1(f,s2,ffull)))
c3=sqrt(sum(interp1(f,s3,ffull)))
c4=sqrt(sum(interp1(f,s4,ffull)))
c5=sqrt(sum(interp1(f,s5,ffull)))
c6=sqrt(sum(interp1(f,s6,ffull)))



loglog(f,s01,'k--s',f,s02,'k--.',f,s1,'k*-',f,s2,'ko-',f,s3,'k^-',f,s4,'k+-');%,f,s5,'kh-',f,s6,'k>:');
axis([1 30000 1e-20 1e-12]);
legend(['Rin=10M  Rs=0  V=' num2str(c01,2)],  ['Rin=50M  Rs=0  V=' num2str(c02,2)],  ['Rin=10M  Rs=1M  V=' num2str(c1,2)],  ['Rin=50M  Rs=1M  V=' num2str(c2,2)],  ['Rin=10M  Rs=5M  V=' num2str(c3,2)],  ['Rin=50M  Rs=5M  V=' num2str(c4,2)]);
xlabel('frequency [Hz]');
ylabel('V^2/Hz');

grid on;
