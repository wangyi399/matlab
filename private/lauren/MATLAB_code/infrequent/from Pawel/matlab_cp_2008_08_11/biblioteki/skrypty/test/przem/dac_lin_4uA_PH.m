clear
cd H:/pliki/nauka/stymulacja/chip/testy/2006_03_10/
dane1=importdata('16uA_5k_b4_c1.dat')';
dane2=importdata('16uA_18k_b4_c1.dat')';
dane3=importdata('16uA_75k_b4_c1.dat')';

%dane=importdata('1ua_76k_probabi.dat')';
figure(1);
clf;

Rsc=1e7;

R1=4800;
R2=19100;
R3=74500;
R1=R1*Rsc/(R1+Rsc);
R2=R2*Rsc/(R2+Rsc);
R3=R3*Rsc/(R3+Rsc);
%R4=4684e3;

dac=[-127:127];

fit=1;
if fit==1
    [slope1,lin_err1,dane1,offset1]=dac_lin5(dac,dane1);
    [slope2,lin_err2,dane2,offset2]=dac_lin5(dac,dane2);
    [slope3,lin_err3,dane3,offset3]=dac_lin5(dac,dane3);
    %[slope4,lin_err4,dane4,offset4]=dac_lin5(dac,dane4);
else
    [slope1,lin_err1,dane1,offset1]=dac_lin5_abs_sum(dac,dane1);
    [slope2,lin_err2,dane2,offset2]=dac_lin5_abs_sum(dac,dane2);
    [slope3,lin_err3,dane3,offset3]=dac_lin5_abs_sum(dac,dane3);
    %[slope4,lin_err4,dane4,offset4]=dac_lin5_abs_sum(dac,dane4);
end

slope=slope1/R1
slope=slope2/R2
slope=slope3/R3
%slope=slope4/R4
5265*127
osie1=[-140 140 -1.2 1.2];
osie2=[-140 140 -2 2];
dane=dane2;
lin_err=lin_err2;
R=R2;
fs=20;

%subplot(3,2,1)
figure(1)
plot(dac,dane/R*1e6,'bd-');
axis(osie1)
grid on;
h=gca;
set(h,'FontSize',fs);
a=xlabel('DAC setting');
set(a,'FontSize',fs);
a=ylabel('output current [ \muA]');
set(a,'FontSize',fs);
%subplot(3,2,2)
figure(4)
plot(dac,lin_err,'bd-');
axis(osie2)
grid on;
h=gca;
set(h,'FontSize',fs);
a=xlabel('DAC setting');
set(a,'FontSize',fs);
a=ylabel('linearity error [LSB]');
set(a,'FontSize',fs);