start=1000000;
dlugosc=250000;
figura=13;
cd /home2/pawel/oko/2000-12-12;
r=readcnst('Data009conv',206,65,[65],[(start) (start+dlugosc-1)]);
%r0=r-mean(r);
%r0=delconst(r0,1000,4000);
%b=delconst2(r,1000,2000,70);

figure(figura);
clf(figura);
plot(r);
%plot(r(1,5000000:5400000));

%for i=1:10
%    i;
%    start=(i+4)*1000+1;
%    a=mean(r(1,(start-4000):(start+4000)));
%    r0(1,(start:(start+1000)))=r(1,start:(start+1000))-a;
%end

%figure(3)
%clf(3)
%plot(r0);

%w=detekcja4(abs(r0),75,10);
%ilosc=length(w)
%n=min([length(w) 64]);
%st=100;
%il=36;
%o=shwpks(r0,w(1,:),[1 50],[st:(st+il-1)],4);