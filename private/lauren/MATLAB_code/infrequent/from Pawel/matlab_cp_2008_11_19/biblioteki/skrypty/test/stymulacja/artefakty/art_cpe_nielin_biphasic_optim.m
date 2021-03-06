clear

Y=1e-8;
beta=0.8;
Rs=260000;
I0=1e-10;
alfa=0.5;
N=2;

model_nielin=struct('Y',Y,'beta',beta,'Rs',Rs,'I0',I0,'alfa',alfa,'N',N);

A1=1e-6;
A2=-A1;
A3=0;

t1=1e-4;
t2=t1;
t3=t1;

T=5e-3;
dt=2e-6;

td=[0 2e-4];
for i=1:0  
  tdisch=td(1,i);
  %[V1,Icpe,Ire]=art_cpe_nielin_sym2(model_nielin,A1,t1,A2,t2,T,dt,0);
  [V1,Icpe,Ire]=art_cpe_nielin_disch(model_nielin,A1,t1,A2,t2,A3,1e-5,tdisch,T,dt);
  V(i,:)=V1;
end

A=2e-6;
c1=0.6;
A1=c1*A
A2=-A
A3=-A2-A1
for i=1:7
    c1=0.4+i*0.05;
    A1=c1*A;
    A2=-A;
    A3=-A2-A1;
    [Vcourse,Icpe,Ire]=art_cpe_nielin_disch(model_nielin,A1,t1,A2,t2,A3,t3,0,T,dt);
    V1(i,:)=Vcourse;
end

t=[0:dt:T-dt];
figure(1);
plot(t,V1(1,:),t,V1(2,:),t,V1(3,:),t,V1(4,:),t,V1(5,:),t,V1(6,:),t,V1(7,:))

figure(2)
t=[0:dt:T-dt];
%plot(t,V(1,:),t,V(2,:),t,V(3,:),t,V(4,:),t,Vcourse);
grid on;
