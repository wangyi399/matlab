function [t,s,h]=plotPH(x,y,N,Style);
%h - pointer to the plot
t=zeros(1,2*length(x));
s=t;
N=100;

for i=1:length(x)-1
    t(2*i-1)=x(i);
    %t(2*i)=x(i+1)-0.00001*(x(i+1)-x(i));
    t(2*i)=(x(i)+x(i+1)*N)/(N+1);
    
    s(2*i-1)=y(i);
    s(2*i)=y(i);
end
t(length(t)-1)=max(x);
t(length(t))=max(x);
s(length(t)-1)=y(length(y));
s(length(t))=y(length(y));

h=plot(t,s,Style);