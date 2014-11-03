function slider = make_loop_slider_list(start_index, index_min, index_max, callback)
% GUI slider for loop over plot for manual inspection
%
%    start_index=1; index_min=1; index_max=10;
%    mat=rand(100,index_max);
%    
%    sliderFig = figure;
%    slider = make_loop_slider_list(start_index, index_min, index_max, [callback]);
%    while ishandle(sliderFig)
%       k = round(get(slider,'Value'));
%       plot(mat(:,k));
%       uiwait;
%    end
%
% 2009 greschner
% 2009-06  gauthier, simplified for no buttons
% 2010-01  phli, added callback arg (defaults to the old 'uiresume')
%

if nargin < 4
    callback = 'uiresume';
end

% Switch to Metal Look and Feel if running on Mac OS > 10.6
nativelaf = javax.swing.UIManager.getLookAndFeel();
if aftersnowleopard()
    javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.metal.MetalLookAndFeel');
end

slider = uicontrol(gcf,...
    'Style'     , 'slider',                        ...
    'Min'       , index_min,                       ...
    'Max'       , index_max,                       ...
    'Units'     , 'normalized',                    ...
    'Position'  , [0,0,0.96,.04],                  ...
    'Value'     , start_index,                     ...
    'SliderStep', 1/(index_max-index_min) * [1 1], ...
    'CallBack'  , callback                         ...
);
drawnow;
javax.swing.UIManager.setLookAndFeel(nativelaf);

set(gcf,'Toolbar','figure');