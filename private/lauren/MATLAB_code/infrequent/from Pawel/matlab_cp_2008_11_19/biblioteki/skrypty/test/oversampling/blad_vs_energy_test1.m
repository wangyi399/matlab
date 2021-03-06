cd I:\dane\2004\12maja\ForPawel\2003-08-06-0-016;
cd I:\dane\2004\12maja\ForPawel\2003-09-19-0-002;
cd I:\dane\2004\26maja\2003-12-08-0-001;
%cd I:\dane\2004\26maja\2004-01-13-0-001;

filename='electrode5.txt';
filename='electrode78.txt';
filename='electrode203.txt';
filename='electrode399.txt';
filename='electrode509.txt';
filename='electrode45.txt';
%filename='electrode221.txt';
%filename='electrode362.txt';
%filename='electrode130.txt';
%filename='electrode337.txt';
s=importdata(filename)';
s=s-mean(s);
dl=length(s);
ts=[1:dl]/20; %czas w milisekundach
marg_left=15;
marg_right=40;

y=blad_vs_energy(s,28);
a=find(y(3,:)>5); %nie zmieniac progu!! "wieksze niz 8"
la=length(a)
wskazniki=y(1,a);

figure(35);
hold off;
clf;

for i=1:100
    subplot(10,10,i);
    plot(s(wskazniki(1,i)-marg_left:wskazniki(1,i)+marg_right));
    %hold on;
end

figure(36);
signal=s(1:2:dl); 
[y,filtr]=oversampling(signal,2,20,0.98);
y1=y(1,20+1:20+dl);
roznica=y1-s;
subplot(2,1,1);
t=[1:400]/20;
%dla electrode5:
    plot(t,s(1,1010401:1010800));
    %grid on;
    subplot(2,1,2);
    plot(t,roznica(1,1010401:1010800));
    %grid on;
%koniec dla electrode5

%* * * Wszystkie ponizsze numery spikow dotycza numeru sposrod spikow
%znalezionych przy narzucinym prog bledu rms - blad wiekszy od osmiu!!!

%cell body spikes:
%el5: spike84
%el79: spike32
%el203: spike78
%el399: spike78
%el509: spike4

%spiki z aksonow:
%electrode 5: 8,9,69
%electrode78: wskzanik 15, 27, 89 dla progu rms>8
%electrode399: 58,62,63
%electrode203 (z katalogu 09-19): 1,10,62
%electrode509 (z katalogu 09-19): 66, 67, 77


%spiki z dendrytow?!
%electrode 5: 57,58
%electrode399: 13,64,100
%electrode203: 19,32,57
%electrode509: 28,87,89

%axonal_spikes=wskazniki([8 ])
%ele

%* * * dla guinepig:
%cell body:
%el45: spike 8
%axonal
%el45: cell body - spike 11 (>5!!, marg_left=15, marg_right=40), axonal -
%spike 49 (>5), 
%el221: cell body - spike 11, axonal - spike 69 (>5!!);
%el362: cell body - spike 71 (>5!! marg_left=15, marg_right=40), axonal:
%35;
%el130: cell body - spike71 (>2!! ,marg_left=15, marg_right=40), axonal:
%spike 19

%


axonal_spikes=wskazniki([19 11 71])
figure(37);
for i=1:3
    sp_start=axonal_spikes(i)-marg_left+1;
    sp_stop=axonal_spikes(i)+marg_right-5;
    spike=[sp_start:sp_stop];
    subplot(2,3,i);
    plot(ts(spike),s(spike),'bd-',ts(spike),y1(spike),'gd-');
    subplot(2,3,i+3);
    f=fft(s(spike),500);
    plot(abs(f));
    grid on;
end

%wybor spikow z akonu: dla electrode5 - spike nr 9, electrode78: spike 89, electrode203
%(katalog 09-19): spike 62, electrode509 (09-19): spike 77

%z dendrytu: electrode203: spike 57, electrode509: spike 28
