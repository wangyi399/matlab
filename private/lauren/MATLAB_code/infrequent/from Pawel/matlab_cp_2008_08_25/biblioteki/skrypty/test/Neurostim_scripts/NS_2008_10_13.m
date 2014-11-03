NS_GlobalConstants=NS_GenerateGlobalConstants(61);


DataPath='D:\analysis\2008-08-27-4\data005';
FileName=[DataPath '\clusters005'];
CenterChannel=49;
Angles=[270 210 330 150 90 30]-210;
for i=1:length(Angles);
    if Angles(i)<0
        Angles(i)=Angles(i)+360;
    end
end
P1Start=293;
Patterns1=[P1Start:P1Start+5];
P1Start=305;
Patterns2=[P1Start:P1Start+5];
Pattern0=317;

Movies0=[63:5:98];
Movies1=[44:5:109];
Movies2=[44:5:109];
FigureProperties=struct('FigureNumber',17,'Subplot',[2 3 3],'TimeRange',[0 50],'AmplitudeRange',[-2 2],'FontSize',16,'Colors',['k' 'r' 'b' 'm' 'g' 'c' 'y'],'LineWidth',1,'YLabel','current [\muA]');
ThresholdsSorted=NS_PlotThresholdVsAngle_2008_10_13(DataPath,FileName,CenterChannel,Pattern0,Patterns1,Patterns2,Angles,Movies0,Movies1,Movies2,FigureProperties,NS_GlobalConstants);

P1Start=245;
Patterns1=[P1Start:P1Start+5];
P1Start=257;
Patterns2=[P1Start:P1Start+5];
Pattern0=317;

Movies0=[63:5:98];
Movies1=[42:5:107];
Movies2=[42:5:107];
FigureProperties=struct('FigureNumber',18,'Subplot',[2 3 3],'TimeRange',[0 50],'AmplitudeRange',[-2 2],'FontSize',16,'Colors',['k' 'r' 'b' 'm' 'g' 'c' 'y'],'LineWidth',1,'YLabel','current [\muA]');
ThresholdsSorted=NS_PlotThresholdVsAngle_2008_10_13(DataPath,FileName,CenterChannel,Pattern0,Patterns1,Patterns2,Angles,Movies0,Movies1,Movies2,FigureProperties,NS_GlobalConstants);

%FileName='D:\analysis\2008-08-26-0\data008_proba4\clusters008';
DataPath='E:\analysis\2008-08-26-0\data008_proba4';
FileName=[DataPath '\clusters008'];
CenterChannel=44;
P1Start=293;
Patterns1=[P1Start:P1Start+5];
P1Start=305;
Patterns2=[P1Start:P1Start+5];
Pattern0=317;

Angles=[330 270 210 150 30 90]-30;

Movies0=[58:5:108];
Movies=[69:5:104];
FigureProperties=struct('FigureNumber',13,'Subplot',[2 3 3],'TimeRange',[0 50],'AmplitudeRange',[-2 2],'FontSize',16,'Colors',['k' 'r' 'b' 'm' 'g' 'c' 'y'],'LineWidth',1,'YLabel','current [\muA]');
ThresholdsSorted=NS_PlotThresholdVsAngle_2008_10_13(DataPath,FileName,CenterChannel,Pattern0,Patterns1,Patterns2,Angles,Movies0,Movies,Movies,FigureProperties,NS_GlobalConstants);

CenterChannel=3;
P1Start=73;
Patterns1=[P1Start:P1Start+5];
P1Start=85;
Patterns2=[P1Start:P1Start+5];
Pattern0=97;

Angles=[210 90 30 270 330 150]-30;

Movies0=[58:5:98];
Movies1=[59:5:89];
Movies2=[59:5:99];
FigureProperties=struct('FigureNumber',14,'Subplot',[2 3 3],'TimeRange',[0 50],'AmplitudeRange',[-2 2],'FontSize',16,'Colors',['k' 'r' 'b' 'm' 'g' 'c' 'y'],'LineWidth',1,'YLabel','current [\muA]');
ThresholdsSorted=NS_PlotThresholdVsAngle_2008_10_13(DataPath,FileName,CenterChannel,Pattern0,Patterns1,Patterns2,Angles,Movies0,Movies1,Movies2,FigureProperties,NS_GlobalConstants);

FileName=[DataPath '\clusters008_el41'];
Movies0=[93:5:108];
Movies1=[74:5:124];
Movies2=[74:5:124];
FigureProperties=struct('FigureNumber',15,'Subplot',[2 3 3],'TimeRange',[0 50],'AmplitudeRange',[-2 2],'FontSize',16,'Colors',['k' 'r' 'b' 'm' 'g' 'c' 'y'],'LineWidth',1,'YLabel','current [\muA]');
ThresholdsSorted=NS_PlotThresholdVsAngle_2008_10_13(DataPath,FileName,CenterChannel,Pattern0,Patterns1,Patterns2,Angles,Movies0,Movies1,Movies2,FigureProperties,NS_GlobalConstants);

FileName=[DataPath '\clusters008'];
CenterChannel=18;
Angles=[90 30 150 330 270 210]-30;
P1Start=183;
Patterns1=[P1Start:P1Start+5];
P1Start=195;
Patterns2=[P1Start:P1Start+5];
Pattern0=207;

Movies0=[3:5:63];
Movies1=[4:5:64];
Movies2=[4:5:64];
FigureProperties=struct('FigureNumber',16,'Subplot',[2 3 3],'TimeRange',[0 50],'AmplitudeRange',[-2 2],'FontSize',16,'Colors',['k' 'r' 'b' 'm' 'g' 'c' 'y'],'LineWidth',1,'YLabel','current [\muA]');
ThresholdsSorted=NS_PlotThresholdVsAngle_2008_10_13(DataPath,FileName,CenterChannel,Pattern0,Patterns1,Patterns2,Angles,Movies0,Movies1,Movies2,FigureProperties,NS_GlobalConstants);