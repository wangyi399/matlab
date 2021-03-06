%%
function figKeyPress(hObject, evt, handles)
cla;
act_max = 1;
act_min = 0;

handles = guidata(hObject);
datarun = handles.datarun;
neurons = handles.neurons;
off_parasol = handles.off_parasol;
responseCurves = handles.responseCurves;
currentIndex = handles.currentIndex;

if strcmpi(evt.Key, 'uparrow')
    currentIndex = currentIndex+1;
elseif strcmpi(evt.Key, 'downarrow')
    currentIndex = currentIndex-1;
end

handles.currentIndex = currentIndex;
guidata(hObject, handles);

responseProbs = responseCurves(:,:,currentIndex);

tmp = figure;
rgbVals = colormap(tmp,gray);
close(tmp);
for n = 1:1:size(handles.neurons,2)
    currentProb = responseProbs(n,:);
    [~,~,val] = find(currentProb);
    fit_color = 'k';
    if ~isempty(val)
        [rgbIndex, ind] = max(val);
        rgbIndex = round(rgbIndex * size(rgbVals,1));
        if rgbIndex<1; rgbIndex = 1; elseif rgbIndex>size(rgbVals,1); rgbIndex = size(rgbVals,1); end
        
        overlaps = [];
        if ismember(neurons(n), off_parasol)
            overlaps = getOverlappingNeurons(datarun, neurons(n), neurons);
            overlaps = overlaps(overlaps ~= 0);
        end
        if ~isempty(overlaps)
            for overlap = overlaps
                index = neurons == overlap;
                if abs(max(find(responseProbs(index,:))) - max(val)) < 0.1
                  fit_color = 'r';
                end
            end
        end
        
        plot_rf_summaries(datarun, neurons(n), 'clear', false, 'label', true, 'label_color', 'g', 'plot_fits', true, 'fit_color', fit_color,'fill_color',rgbVals(rgbIndex,:));
    else
        plot_rf_summaries(datarun, neurons(n), 'clear', false, 'label', true, 'label_color', 'g', 'plot_fits', true, 'fit_color', fit_color,'fill_color','k');
    end
    
end
axis image; axis off;
colorbar; colormap(rgbVals); caxis([act_min act_max]);
title('parasol response prob, single electrode stimulation');
end