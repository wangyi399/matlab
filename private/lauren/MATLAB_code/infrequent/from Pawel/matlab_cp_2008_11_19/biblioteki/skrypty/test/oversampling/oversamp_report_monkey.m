filtr_dl=20;
figura1=55;
figura2=56;
figura3=57;

channels=zeros(3,4);

cd K:\dane\2004\12maja\ForPawel\2003-08-06-0-016;
%cd /mnt/data4/dane/2004/12maja/ForPawel/2003-08-06-0-016

s1=importdata('electrode5.txt');
s1=s1-mean(s1);
channels(1,1)=9;
channels(2,1)=57; 
channels(3,1)=84;
s2=importdata('electrode399.txt');
s2=s2-mean(s2);
channels(1,2)=63;
channels(2,2)=100;
channels(3,2)=78;
cd K:\dane\2004\12maja\ForPawel\2003-09-19-0-002;
%cd /mnt/data4/dane/2004/12maja/ForPawel/2003-09-19-0-002;
s3=importdata('electrode203.txt');
s3=s3-mean(s3);
channels(1,3)=1;
channels(2,3)=57; 
channels(3,3)=78;
s4=importdata('electrode509.txt');
s4=s4-mean(s4);
channels(1,4)=77;
channels(2,4)=28;
channels(3,4)=4;

signals=[s1 s2 s3 s4]';
dl=length(s1);
clear s1 s2 s3 s4;
ts=[1:dl]/20; %czas w milisekundach
marg_left=15;
marg_right=20;
ts=[0:marg_right+marg_left-1]/20; %czas w milisekundach

%function y=oversamp_report(signals,spikes,thresholds,fltr_dl,figure,osie);
y=oversamp_report(signals,channels(2,:),8,filtr_dl,85,2);
break;

figure(figura1);
for i=1:4
    s=signals(i,:);
    y=blad_vs_energy(s,28);
    a=find(y(3,:)>8); %nie zmieniac progu!!
    la=length(a)
    wskazniki=y(1,a);
    
    signal=s(1:2:dl); 
    [y0,filtr]=oversampling(signal,2,filtr_dl,0.98);
    y1=y0(1,filtr_dl+1:filtr_dl+dl);
    roznica=y1-s;
    
    sp1_start=wskazniki(channels(1,i))-marg_left;
    sp1_stop=wskazniki(channels(1,i))+marg_right-1;
    spike_wspol=[sp1_start:sp1_stop];
    spike=s(spike_wspol);
    spike=spike-mean(spike);
    spike_y1=y1(spike_wspol)-mean(y1(spike_wspol))
    qwer=mean(spike_y1)
    subplot(3,4,i);
    plot(ts,spike,'b-',ts,spike_y1,'r-');
    axis([0 1.7 -200 200]);
    if i==1        
        xlabel('time [ms]');
        ylabel('signal level');
    end
    if i==2
	    legend('original signal','interpolated signal');
    end
    grid on;
    
    subplot(3,4,i+4);
    plot(ts,spike,'bd-',ts,spike_y1,'rd-');
    axis([0.4 1 -200 200]);
    if i==1        
        xlabel('time [ms]');
        ylabel('signal level');
        %legend('original signal','interpolated signal');
    end
    if i==2
	    legend('original signal','interpolated signal');
    end
    grid on;
    
    subplot(3,4,i+8);
    fs=fft(spike,500);
    f=[0:499]/500*20000;
    plot(f,abs(fs));
    if i==1
    	xlabel('frequecy [Hz]');
    	ylabel('Fourier coefficient');
    end
    grid on;
    axis([0 10000 0 1000]);
end

figure(figura2);
for i=1:4
    s=signals(i,:);
    y=blad_vs_energy(s,28);
    a=find(y(3,:)>8); %nie zmieniac progu!!
    la=length(a)
    wskazniki=y(1,a);
    
    signal=s(1:2:dl); 
    [y0,filtr]=oversampling(signal,2,filtr_dl,0.98);
    y1=y0(1,filtr_dl+1:filtr_dl+dl);
    roznica=y1-s;
    
    sp1_start=wskazniki(channels(2,i))-marg_left;
    sp1_stop=wskazniki(channels(2,i))+marg_right-1;
    spike_wspol=[sp1_start:sp1_stop];
    spike=s(spike_wspol);
    spike=spike-mean(spike);
    spike_y1=y1(spike_wspol)-mean(y1(spike_wspol));
    subplot(3,4,i);
    plot(ts,spike,'b-',ts,spike_y1,'r-');
    axis([0 1.7 -200 200]);
    if i==1        
        xlabel('time [ms]');
        ylabel('signal level');
        %legend('original signal','interpolated signal');
    end    
    if i==2
	    legend('original signal','interpolated signal');
    end
    grid on;
    
    subplot(3,4,i+4);
    plot(ts,spike,'bd-',ts,spike_y1,'rd-');
    axis([0.4 1 -200 200]);
    if i==1        
        xlabel('time [ms]');
        ylabel('signal level');
        %legend('original signal','interpolated signal');
    end   
    if i==2
	    legend('original signal','interpolated signal');
    end
    grid on;
    
    subplot(3,4,i+8);
    fs=fft(spike,500);
    f=[0:499]/500*20000;
    plot(f,abs(fs));
    if i==1
    	xlabel('frequecy [Hz]');
    	ylabel('Fourier coefficient');
    end
    grid on;
    axis([0 10000 0 1500]);
end

figure(figura3);
for i=1:4
    s=signals(i,:);
    y=blad_vs_energy(s,28);
    a=find(y(3,:)<5); %nie zmieniac progu!!
    la=length(a)
    wskazniki=y(1,a);
    
    signal=s(1:2:dl); 
    [y0,filtr]=oversampling(signal,2,filtr_dl,0.98);
    y1=y0(1,filtr_dl+1:filtr_dl+dl);
    roznica=y1-s;
    
    sp1_start=wskazniki(channels(3,i))-marg_left;
    sp1_stop=wskazniki(channels(3,i))+marg_right-1;
    spike_wspol=[sp1_start:sp1_stop];
    spike=s(spike_wspol);
    spike=spike-mean(spike);
     spike_y1=y1(spike_wspol)-mean(y1(spike_wspol));
    subplot(3,4,i);
    plot(ts,spike,'b-',ts,spike_y1,'r-');
    axis([0 1.7 -200 200]);
    if i==4
        axis([0 1.7 -500 300]);
    end
    if i==1        
        xlabel('time [ms]');
        ylabel('signal level');
        %legend('original signal','interpolated signal');
    end
    if i==2
	    legend('original signal','interpolated signal');
    end
    grid on;
    
    subplot(3,4,i+4);
    plot(ts,spike,'bd-',ts,spike_y1,'rd-');
    axis([0.4 1 -200 200]);
    if i==4
        axis([0.4 1 -500 300]);
    end
    if i==1        
        xlabel('time [ms]');
        ylabel('signal level');
        %legend('original signal','interpolated signal');
    end
    if i==2
	    legend('original signal','interpolated signal');
    end
    grid on;
    
    subplot(3,4,i+8);
    fs=fft(spike,500);
    f=[0:499]/500*20000;
    plot(f,abs(fs));
    if i==1
        xlabel('frequecy [Hz]');
        ylabel('Fourier coefficient');
    end
    grid on;
    axis([0 10000 0 1500]);
    if i==4
        axis([0 10000 0 4000]);
    end
end


