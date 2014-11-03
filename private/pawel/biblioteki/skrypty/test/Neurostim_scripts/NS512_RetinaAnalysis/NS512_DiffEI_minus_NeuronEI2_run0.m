EventNumbers=[12 74 82 87 94 111 121 147 150 207];
UpsamplingFactor=5;

HalfAmplitudesWidths=zeros(length(EventNumbers),10*UpsamplingFactor+3);
NegativeAmplitudes=zeros(length(EventNumbers),10*UpsamplingFactor+3);

for i1=[6 10]%1:1%length(EventNumbers)
    DelaySpike=1;
    %i1
    EventNumber=EventNumbers(i1);
    NS512_DiffEI_minus_NeuronEI7;
    %HalfAmplitudesWidths(i1,:)=HalfAmplitudeWidth/UpsamplingFactor/20;
    %NegativeAmplitudes(i1,:)=NegAmplitude;
end
break
figure(101);
clf
%hold on
t=[0:10*UpsamplingFactor]/UpsamplingFactor/20;
Colors={'bd-' 'gd-' 'rd-' 'md-' 'kd-' 'bo-' 'go-' 'ro-' 'mo-' 'ko-'}
for i=1:length(EventNumbers)
    subplot(2,5,i)
    a=HalfAmplitudesWidths(i,3:10*UpsamplingFactor+3)
    b=NegativeAmplitudes(i,3:10*UpsamplingFactor+3)
    plot(a,b,'b-');
    hold on
    h=plot(HalfAmplitudesWidths(i,length(HalfAmplitudesWidths)),NegativeAmplitudes(i,length(HalfAmplitudesWidths)),'bd');
    set(h,'MarkerSize',10);
    set(h,'MarkerFaceColor','b');    
    h=plot(HalfAmplitudesWidths(i,1),NegativeAmplitudes(i,1),'gd');
    set(h,'MarkerSize',10);
    set(h,'MarkerFaceColor','g');
    h=plot(HalfAmplitudesWidths(i,2),NegativeAmplitudes(i,2),'rd');
    set(h,'MarkerSize',10);
    set(h,'MarkerFaceColor','r');    
    axis([0 0.6 -300 0]);
    grid on;
    
    text(0.04,-20,['e' num2str(EventNumbers(i))]);
    if i==6
        xlabel('Half-amplitude width [ms]');
        ylabel('EI amplitude [mV]');
    end
end