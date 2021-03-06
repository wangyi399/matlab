cd /home2/pawel/oko/2000-12-12;

nrchns=65;
s1=2239700;
dl=4000000;
samples=[s1 (s1+dl-1)];
channels=65;
%channels=31;
name='Data009';
read_param=struct('name',name,'header',206,'nrchns',nrchns,'channels',channels,'samples',samples);
s=readcnst(read_param);
time=[1:dl];
figure(1);
plot(s);
%axis([0 time(dl) -1100 700]);
grid on;

detect_param=struct('prog',600,'histereza',50,'znak',-1);
wynik=detect_f(read_param,detect_param);
size(wynik)

[odl,wys]=ampl_vs_opozn(read_param,detect_param);
figure(2);
plot(odl,wys,'bd');
grid on;

marg_left=10;
marg_right=69;
figure(3);
for i=1:36
	subplot(6,6,i);
	start=wynik(1,i)-marg_left;
	stop=wynik(2,i)+marg_right;
	plot(s(start:stop),'bd-');
	axis([1 20 -1500 500]);
end

figure(4);
hold off;
clf;
spikes=zeros(marg_left+marg_right+1);

nadpr=4;
prog=560;

for i=1:length(wynik);
	start=wynik(1,i)-marg_left;
	stop=wynik(1,i)+marg_right;
	spike=s(start:stop);
	spikes(1,:)=spike;
	[spike0,filtr]=oversampling(spike,nadpr,11,0.9);
	szczyt=find(abs(spike0)==max(abs(spike0)));
	a=find(abs(spike0)>prog);
	punkt0=a(1,1);
	szczyt=punkt0;
	spike1=spike0(1,szczyt-50:szczyt+269);
	widmo1=abs(fft(spike));
	plot(widmo1);
	hold on;
end
grid on;
