PiecePhotoPath='C:\pawel\nauka\512paper\photos for Pawel\2013-12-12-3-PH\DayOfRecording\DSCN9262.jpg';
ArrayPhotoPathPath='C:\pawel\nauka\512paper\photos for Pawel\2013-12-12-3-PH\DayOfRecording\onemark.jpg';

figure(1)
clf

z1=9
z2=6

a=imread(PiecePhotoPath);
image(a)
hold on
FullImageName=['C:\pawel\nauka\512paper\photos for Pawel\2013-12-12-3-PH\DayOfRecording\fig1.tif'];
h=gcf;
set(h,'PaperUnits','inches');
set(h,'PaperSize',[ z1 z2]);
set(h,'PaperPosition',[0 0 z1 z2]); 
print(h, '-dtiff', '-r120', FullImageName);
h = circlePH(1770,880,520)
h = circlePH(703,198,50)
set(h,'Color','r');
h = circlePH(375,895,50)
set(h,'Color','r');
FullImageName=['C:\pawel\nauka\512paper\photos for Pawel\2013-12-12-3-PH\DayOfRecording\fig2.tif'];
h=gcf;
set(h,'PaperUnits','inches');
set(h,'PaperSize',[z1 z2]);
set(h,'PaperPosition',[0 0 z1 z2]); 
print(h, '-dtiff', '-r120', FullImageName);

figure(2)
clf

b=imread(ArrayPhotoPathPath);
image(b)
hold on
%break
circlePH(600,300,520);
%ArrayPhotoPathPath2='C:\pawel\nauka\512paper\photos for Pawel\2013-12-12-3-PH\DayOfRecording\onemark_proc.jpg';
%h=getframe(gcf)

ArrayCorner1=[1183,400];
ArrayCorner1=[1313,1223];

c=imrotate(b,180);
figure(3)
clf
image(c)
FullImageName=['C:\pawel\nauka\512paper\photos for Pawel\2013-12-12-3-PH\DayOfRecording\fig3.tif'];
h=gcf;
set(h,'PaperUnits','inches');
set(h,'PaperSize',[ z1 z2]);
set(h,'PaperPosition',[0 0 z1 z2]); 
print(h, '-dtiff', '-r120', FullImageName);
%h = circlePH(1770,880,520)
hold on
circlePH(1448,1236,520);
FullImageName=['C:\pawel\nauka\512paper\photos for Pawel\2013-12-12-3-PH\DayOfRecording\fig4.tif'];
h=gcf;
set(h,'PaperUnits','inches');
set(h,'PaperSize',[ z1 z2]);
set(h,'PaperPosition',[0 0 z1 z2]); 
print(h, '-dtiff', '-r120', FullImageName);