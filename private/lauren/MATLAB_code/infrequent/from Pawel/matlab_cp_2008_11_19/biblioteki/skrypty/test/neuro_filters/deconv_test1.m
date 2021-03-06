%10:13 dla cell body
%1,2,3,5 dla axonal
system=2; %windows
figura1=5;
figura2=6;
figura3=105;
figura4=106;
figura5=205;
figura7=305;

fft_marg=10; % wartosc marginesu dla funkcji fft_blackman 
N_fft=400;
fp=20000;

ktore_spiki=[1:16];
%ktore_spiki=[10:13];
ktore_spiki=[1 4 5 15];
%[p,filenames,spikes,detect_param]=spiki_malpa(1,ktore_spiki,system);
[p,filenames,spikes,detect_param]=spiki_gunpg(1,ktore_spiki,system);

dl=400;
[y1,y2]=inveyefilter_hayes(dl,58,40,3300,20000);

%
[y1a,y2a]=inveyefilter_hayes(dl,18,20,8300,20000);

margins=[15 50];
t=[0:margins(1)+margins(2)]/20;
a1=2;
a2=2; % ile wykresow - wpsolrzedne dla subplot

%figure(5);
for j=1:length(filenames)
    if find(spikes(:,1)==j)'
        s=importdata(filenames{j})';
        s=s-mean(s);
    
        sy=conv(s,y2);
        sy=sy(dl+1:length(s)+dl);
        sy=sy-mean(sy);
        
        sa=conv(sy,y1a);
        sa=sa(dl+1:length(s)+dl);

        positions=find(spikes(:,1)==j)'; %numery dobrych spikow w tym pliku    
        %coordinates(positions)=y(1,spikes(positions,2)); 

        for i=1:length(positions)
            figure(figura1);
	        subplot(a1,a2,positions(i));
	        strt=spikes(positions(i),2)-margins(1)
	        stp=spikes(positions(i),2)+margins(2)

		spike1=s(strt:stp)-mean(s(strt:stp));
		spike2=sy(strt:stp)-mean(sy(strt:stp));
		spike3=sa(strt:stp)-mean(sa(strt:stp));
		
	        plot(t,spike1,'b-',t,spike2,'r-',t,spike3,'g-');
	        grid on
		if positions(i)==1
			legend('raw signal','deconvoluted sig.','fg=5kHz (sim.)');
		end
		h=gca;
		set(h,'XLim',[0 3]);
		xlabel('time [ms]');

            
            figure(figura3);
	        subplot(a1,a2,positions(i));
            [s1,f1]=fft_blackman(spike1,fft_marg,N_fft);
            [s2,f2]=fft_blackman(spike2,fft_marg,N_fft);
            [s3,f3]=fft_blackman(spike3,fft_marg,N_fft);
            freq=[0:N_fft-1]/N_fft*fp;
	        semilogx(freq,abs(f1),'b-',freq,abs(f2),'r-',freq,abs(f3),'g-');
            h=gca;
            set(h,'XLim',[50 10000]);
	        grid on
            
            figure(figura5);
	        subplot(a1,a2,positions(i));
            plot(t,s1,'b-',t,s2,'r-',t,s3,'g-');
            grid on
            
            figure(figura7);
            subplot(a1,a2,positions(i));
            semilogx(freq,angle(f1),'b-',freq,angle(f2),'r-',freq,angle(f3),'g-');
            h=gca;
            set(h,'XLim',[50 10000]);
	        grid on
        end
    end    
end

%break;

ktore_spiki=[1 2 3 5];
ktore_spiki=[1:16];
ktore_piki=[2 3 5 12];
[p,filenames,spikes,detect_param]=spiki_malpa(2,ktore_spiki,system);

%dl=200;
[y1,y2]=inveyefilter_hayes(dl,58,40,3300,20000);

margins=[15 50];
t=[0:margins(1)+margins(2)]/20;

figure(6);
for j=1:length(filenames)
    if find(spikes(:,1)==j)'
        s=importdata(filenames{j})';
        s=s-mean(s);
    
        sy=conv(s,y2);
        sy=sy(dl+1:length(s)+dl);
        sy=sy-mean(sy);
        
        sa=conv(sy,y1a);
        sa=sa(dl+1:length(s)+dl);

        positions=find(spikes(:,1)==j)' %numery dobrych spikow w tym pliku    
        %coordinates(positions)=y(1,spikes(positions,2)); 

        for i=1:length(positions)
	    subplot(a1,a2,positions(i));
	    strt=spikes(positions(i),2)-margins(1)
	    stp=spikes(positions(i),2)+margins(2)
		
	    spike1=s(strt:stp)-mean(s(strt:stp));
	    spike2=sy(strt:stp)-mean(sy(strt:stp));
	    spike3=sa(strt:stp)-mean(sa(strt:stp));
	    
	    plot(t,spike1,'b-',t,spike2,'r-',t,spike3,'g-');
	    grid on
	    if positions(i)==1
			legend('raw signal','deconvoluted sig.','fg=5kHz (sim.)');
		end
		h=gca;
		set(h,'XLim',[0 3]);
		xlabel('time [ms]');

        end
    end    
end

