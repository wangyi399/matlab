cd /mnt/data4/dane/2004/12maja/ForPawel/2003-09-19-0-002;

a=importdata('electrode193.txt');
p=find(a==min(a));
plot(a(p-100000:p+100000,1));
