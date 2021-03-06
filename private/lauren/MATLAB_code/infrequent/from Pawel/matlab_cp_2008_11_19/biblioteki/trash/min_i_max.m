function y=minim(filename,dlugosc,stim_channel);

start=1;

s=readconv(filename,206,65,stim_channel+1,[(start) (start+dlugosc-1)]);
sc=s-mean(s);
smin=max(max(abs(sc)));

detect=find(abs(sc)>smin*0.8);
poczatek=detect(1,1);

margines=poczatek;

for i=1:64;
	s=readconv(filename,206,65,i+1,[margines margines+1000]);
	y(1,i)=min(s);
end
