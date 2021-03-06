function slope=dac_lin2(dac,dane);

[p,s] = POLYFIT(dac,dane,1);
y = POLYVAL(p,dac);
figure(1)
plot(dac,dane);
grid on
figure(2)
plot(dac,y-dane);
grid on;

aa=[dane./dac];                 %aa - tablica wspolczynnikow nachylenia dla wszystkich wartosci
aa1=[aa(1,1:127) aa(1,129:255)];
a1=min(abs(aa1));               %a1 - najmniejszy wspolczynnik nachylenia
a2=max(abs(aa1));               %a2 - najwiekszy wspolczynnik nachylenia

N=500;
step=(a2-a1)/N;

glob_emax=10;                   %glob_emax - najwieksza wartosc bledu maksymelnego dla najlepiej dopasowanego wspolczynnika nachylenia

for i=1:N
    c=a1+i*step; 
    y=c*dac;        
    err=abs(y-dane);    
    emax=max(err);              %emax - najwiekszy blad dla danego wspolczynnika nachylenia
    if (emax < glob_emax)
        glob_emax=emax;
        a_bestfit=i;            %a_bestfit - numer najlepiej dopasowanego wsp. nachylenia
    end
    
 end 
 
c=a1+a_bestfit*step;

slope=c;