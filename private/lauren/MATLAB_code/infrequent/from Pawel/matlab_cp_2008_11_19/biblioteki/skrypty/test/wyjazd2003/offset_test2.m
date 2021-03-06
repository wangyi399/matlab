cd /home2/pawel/oko/santa_cruz_2003;
filename='ch28_52uA_01ms_Vpol-11_waterconv';
%!copy filename filename2
%y=convert_data(filename,206,65,20000);

length=60000;

%y=offsets(10,64);

figura=1;
period=20000;
margines=5; 
zakres=2000;  % in miliseconds
stim_channel=28;


style1='bd- ';
style2='go- ';
style3='rx- ';
style4='k*- ';
style5='ch- ';

style6='bd--';
style7='go--';
style8='rx--';
style9='k*--';
style10='ch--';

styles=[style1' style2' style3' style4' style5' style6' style7' style8' style9' style10']';


cd 2003_10_20;
filename='ch28_11uA_01ms_Vpol-14_waterconv';
stim_channel=28;
y(1,:)=offsety(filename,length,stim_channel);
u(1,:)=minim(filename,length,stim_channel);
o(1,:)=maxim(filename,length,stim_channel);
cd ..;

cd 2003_10_24;
filename='ch15_11uA_01ms_water_Vpol-14Vconv';
stim_channel=15;
y(2,:)=offsety(filename,length,stim_channel);
u(2,:)=minim(filename,length,stim_channel);
o(2,:)=maxim(filename,length,stim_channel);


filename='ch54_11uA_01ms_water_Vpol-14Vconv';
stim_channel=54;
y(3,:)=offsety(filename,length,stim_channel);
u(3,:)=minim(filename,length,stim_channel);
o(3,:)=maxim(filename,length,stim_channel);

cd ..;

t=[1:64];
numery=[1 2 3];
figure(117);
clf;
subplot(3,1,3);
for i=1:3
	plot(t,y(numery(i),:),styles(i,:));
	styles(i,:)
	hold on;
end
grid on;
axis([1 64 -1200 1200]);
legend('1.1uA, channel 28','1.1uA, channel 15','1.1uA, channel 54');
ylabel('ADC units');
title('offset');
xlabel('channel number');


subplot(3,1,1);
for i=1:3
	plot(t,u(numery(i),:),styles(i,:));
	styles(i,:)
	hold on;
end
grid on;
axis([1 64 -1200 1200]);
legend('1.1uA, channel 28','1.1uA, channel 15','1.1uA, channel 54');
ylabel('ADC units');
title('amplitude of the negative part');
%xlabel('channel number');



subplot(3,1,2);
for i=1:3
	plot(t,o(numery(i),:),styles(i,:));
	styles(i,:)
	hold on;
end
grid on;
axis([1 64 -1200 1200]);
legend('1.1uA, channel 28','1.1uA, channel 15','1.1uA, channel 54');
ylabel('ADC units');
title('amplitude of the positive part');
%xlabel('channel number');
