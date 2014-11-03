function ThresholdCurrent=NS_FindThresholdCurrent(Amplitudes,Efficacies,Threshold);
%The function gives the values of current for which the effiacy is 50%. It
%uses linear interpolation. If the Efficacy vs Amplitude curve is not
%monotonic, there may be more than one output value!

TC=diff(sign(Efficacies-Threshold));
a=find(TC==2);
if length(a)>0
    for i=1:length(a)
        ThresholdCurrents(i)=Amplitudes(a(i))+(Amplitudes(a(i)+1)-Amplitudes(a(i)))*(Threshold-Efficacies(a(i)))/(Efficacies(a(i)+1)-Efficacies(a(i)));
    end
    ThresholdCurrent=mean(ThresholdCurrents);
else
    a=find(TC==1);
    for i=1:length(a)
        ThresholdCurrent=Amplitudes(a(1)+1);
        %ThresholdCurrents(i)=Amplitudes(a(i))+(Amplitudes(a(i)+1)-Amplitudes(a(i)))*(Threshold-Efficacies(a(i)))/(Efficacies(a(i)+1)-Efficacies(a(i)));
    end
end