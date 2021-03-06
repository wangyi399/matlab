function [y,filtr]=oversampling(x,N,filtr_dl,filtr_gr);
%x-wektor danych
%N-wspolczynnik nadprobkowania
%filtr_dl - ilosc wspol. filtra
%filtr gr. - czest. gr. filtra, od 0 do 1

z=zeros(1,length(x)+(length(x)-1)*(N-1));
z(1,1:N:length(z))=x;

filtr=fir1(filtr_dl*N,filtr_gr/N);
y=N*conv(z,filtr);
