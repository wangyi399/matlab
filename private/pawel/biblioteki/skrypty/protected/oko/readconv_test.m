start=1;
dlugosc=20000;
cd /home2/pawel/oko/2000-12-12;
r=readconv('Data012conv',206,65,[8 9 10 18 19],[(start) (start+dlugosc-1)]);

figure(2);
subplot(3,3,2);
plot(r(1,:));
%axis([0 dlugosc -400 400]);
subplot(3,3,4);
plot(r(2,:));
%axis([0 dlugosc -400 400]);
subplot(3,3,5);
plot(r(3,:));
%axis([0 dlugosc -400 400]);
subplot(3,3,6);
plot(r(4,:));
%axis([0 dlugosc -400 400]);
subplot(3,3,8);
plot(r(5,:));
%axis([0 dlugosc -400 400]);