function y=symetria1(current,res,bits,osie);
%Funkcja rysuje stusunek pradu pos. do neg. jako funkcje wartosci DAC.
%Funkcja wymaga istnienia w katalogu biezacym
%dwoch plikow o nazwach typu: 1u_pos_20k.out, 1u_neg_20k.out,
%Wejscia:
%current - STRING, dla powyzszego przykladu '1u';
%res - STRING, dla powyzszego przykladu: '20k';
%bits - ilosc bitow, konieczna dla znormalizowania funkcji bledu i
%wyskalowania osi pionowej w LSB.

%1. czytanie danych z plikow
%a) dla pradu negatywnego (x - wartosci DACa, y - wartosci pradu)
filename=[current '_neg_' res '.out'];
a=importdata(filename);
x_neg=a(:,1);
y_neg=a(:,2);

%1b) dla pradu pozytywnego
filename=[current '_pos_' res '.out'];
a=importdata(filename);
x_pos=a(:,1);
y_pos=a(:,2);

sym=y_pos;
sym=-y_pos./y_neg;

value=x_pos/max(x_pos)*127;
a=plot(value,sym,'b-');
set(a,'LineWidth',2);
grid on;

%a=title([current 'A  R=' res]);
a=text(70,1.015,[current 'A']);
set(a,'FontSize',16);
%legend('neg. curr.','pos. curr.', 'input curr.');
if osie==1
    a=xlabel('DAC value [LSB]');
    set(a,'FontSize',16);
    a=ylabel('Ipos/Ineg');
    set(a,'FontSize',16);
end
y=a;
