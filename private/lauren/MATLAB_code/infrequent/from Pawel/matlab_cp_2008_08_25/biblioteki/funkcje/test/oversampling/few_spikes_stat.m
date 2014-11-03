function y=few_spikes_stat(filenames,spikes,detect_param,filter_param,figura,margins);
%filenames - nazwy plikow z danymi (dowolna ilosc);
%spikes - ktore spiki sposrod znalezionych (patrz: parametry detekcji!) maja
%byc brane pod uwage, w pierwszym wierszu: numer pliku
%detect_param - jak zawsze
%figura - numer wykresu
%positions - rozmiar taki sam jak zmienna "spikes", okresla, w ktorej
%kolumnie maja byc rysowane krzywe dla danego kanalu
%N - calkowita ilosc kolumn (np. funkcja moze rysowac w 5 i 7 kolumnie
%sposrod 10)
figure(figura);
nr_of_files=length(filenames);
N=length(spikes);

marg_left=margins(1,1);
marg_right=margins(1,2);
ts=[0:marg_right+marg_left-1]/20; %czas w milisekundach

for j=1:nr_of_files %dla kazdego pliku:
    %1. wczytanie danych
    s=importdata(filenames{j})';
    s=s-mean(s);
    dl=length(s);
    %2. wyznaczenie bledow interpolacji
    %y=blad_vs_energy2(signal,detect_param,filter_param,margins);
    y=detect2(s,detect_param);
    
    %figure(111)
    %plot(y(1,:))
    signal=s(1:2:dl); %undersampling
    [y0,filtr]=oversampling(signal,filter_param.N,filter_param.order,filter_param.freq);        
    y1=y0(1,filter_param.order+1:filter_param.order+dl);
    clear y0;
    roznica=y1-s;
        
    %3. Rysujemy
    positions=find(spikes(:,1)==j)'
    ls=length(positions);   
        
    for i=1:ls         
        %spikes(positions(1,i),1)
        sp1_start=y(1,spikes(positions(1,i),2))-marg_left    
        sp1_stop=y(1,spikes(positions(1,i),2))+marg_right-1
        %break;
        spike_wspol=[sp1_start:sp1_stop];
        spike=s(spike_wspol);
        spike=spike-mean(spike);
        spike_y1=y1(spike_wspol)-mean(y1(spike_wspol));
        %spike_y2=y2(spike_wspol)-mean(y1(spike_wspol));
        %qwer=mean(spike_y1)
        subplot(4,N,positions(1,i));
        plot(ts,spike,'b-',ts,spike_y1,'r-');
        %axis([0 2.7 -200 200]);
        h=gca;
        set(h,'XLim',[0.5 3]);
        if positions(1,i)==1        
            xlabel('time [ms]');
            ylabel('signal level');
        end
        if positions(1,i)==6
            legend('original signal','interpolated signal');
        end
        grid on;

    
        subplot(4,N,positions(1,i)+N);
        plot(ts,spike,'bd-',ts,spike_y1,'rd-');
        %axis([0.4 1 -200 200]);
        h=gca;
        set(h,'XLim',[0.8 1.6]);
        if positions(1,i)==1        
            xlabel('time [ms]');
            ylabel('signal level');
        end
        if positions(1,i)==6        
            legend('original signal','interpolated signal');
        end
        grid on;
    
        subplot(4,N,positions(1,i)+2*N);       
        spike1=spike.*trapez_blackman(length(spike),15);
        fs=fft(spike1,500);
        f=[0:499]/500*20000;
        plot(f,abs(fs));
        h=gca;
        set(h,'XLim',[0 10000]);
        %axis([0 10000 0 1000]);
        grid on;
        if positions(1,i)==1
            xlabel('frequecy [Hz]');
            ylabel('Fourier coefficient');            
        end
        
        subplot(4,N,positions(1,i)+3*N);
        plot(ts,spike-spike_y1,'b-');
        %axis([0 2.7 -200 200]);
        h=gca;
        set(h,'XLim',[0.5 3]);
        if positions(1,i)==1        
            xlabel('time [ms]');
            ylabel('signal level');
        end       
        grid on;
        
        
    end             
end