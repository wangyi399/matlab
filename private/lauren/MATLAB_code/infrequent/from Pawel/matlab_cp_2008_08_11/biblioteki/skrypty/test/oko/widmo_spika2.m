name='Data009';

nrchns=65;
channels=65;
dl=4000;
s1=150000;
samples=[s1 (s1+dl-1)];
read_param=struct('name',name,'header',206,'nrchns',nrchns,'channels',channels,'samples',samples);
s=readcnst(read_param);

dl=length(s);
t=[1:dl];

filtr_dl=16;

f=[0.4 0.5 0.6 0.7 0.8 0.9];
for i=1:6
   filtr=fir1_ph(filtr_dl,f(1,i));
   size(filtr)
   y=conv(s,filtr);
   size(y)
   y0=y(1,1+filtr_dl/2:dl+filtr_dl/2);
   %figure(3);
   %subplot(2,3,i);
   %plot(y);
   figure(1);
   subplot(2,3,i);
   plot(t,s,'bd-',t,y0,'gd-');
   axis([180 186 -1000 0]);
   grid on;
   figure(2);
   subplot(2,3,i);
   plot(t,s,'b-',t,y0,'g-');
   axis([100 300 -1200 800]);
   grid on;
   %plot(filtr)
end


