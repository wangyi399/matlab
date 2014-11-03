function [b1,list,list2] = loop_slider_list(k,kmin,kmax,list,list2)
% GUI slider for loop over plot for manual inspection
%
%    k=1; kmin=1; kmax=10;
%    mat=rand(100,kmax);
%
%    list=[]; list2=[]; 
%    [ha list list2]=loop_slider_list(k,kmin,kmax,list,list2);
%    while k
%       k=round(get(ha,'Value'));
%       plot(mat(:,k));
%       uiwait;
%    end
%
%greschner


b1= uicontrol(gcf,...
    'Style','slider',...
    'Min' ,kmin,'Max',kmax, ...
    'Units','normalized', ...
    'Position',[0,0,.6,.04], ...
    'Value', k,...
    'SliderStep',[1/(kmax-kmin) 1/(kmax-kmin)],...
    'CallBack', 'uiresume;');

b2 = uicontrol('Style','pushbutton', ...
    'Units','normalized', ...
    'Position',[0.61 0 .05 .04], ...
    'String','',...
    'Callback','list=[list k]; uiresume;');

if ~exist('list','var');
    b2 = uicontrol('Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[0.67 0 .05 .04], ...
        'String','',...
        'Callback','list=[list k]; uiresume;');
end


if ~exist('list2','var');
    b2 = uicontrol('Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[0.67 0 .05 .04], ...
        'String','',...
        'Callback','list2=[list2 k]; uiresume;');
end