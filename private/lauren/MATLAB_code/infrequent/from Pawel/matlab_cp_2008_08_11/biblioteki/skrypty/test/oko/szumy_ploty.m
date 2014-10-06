function w=szumy_ploty(f,Rin,Rs,Cin);
%Rin=1e7;
%Cin=150e-10;

%Rs=1e6;

k=1.38e-23;

T=300;

w=Vsin(k,T,Rin,Rs,Cin,f)+Vss(k,T,Rin,Rs,Cin,f);

%w=Vsin(k,T,Rin,Rs,Cin,f);
%w=Vss(k,T,Rin,Rs,Cin,f);



function w=Vsin(k,T,Rin,Rs,Cin,f); 
w=4*k*T*Rin*abs((1+2*pi*Rs*Cin*f)./(1+2*pi*(Rin+Rs)*Cin*f)).^2;

function w=Vss(k,T,Rin,Rs,Cin,f);
w=4*k*T*Rin^2*Rs*abs((2*pi*Cin*f)./(1+2*pi*(Rin+Rs)*Cin*f)).^2;
