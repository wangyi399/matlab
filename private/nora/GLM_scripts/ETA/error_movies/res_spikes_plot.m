function res_spikes_plot(testmovie, res)

default_colors = get(gca,'ColorOrder');
frames = length(testmovie);
writerObj = VideoWriter('/Volumes/Lab/Users/Nora/res_Spikes.avi');
writerObj.FrameRate = 20;
open(writerObj);

n_cells = length(res.centers);
colors = zeros(n_cells,3);

for i_frame = 1:frames
    disp(i_frame)
    imagesc(testmovie(:,:,i_frame)')
    axis image
    colormap gray
    axis off
    hold on
    idx = (i_frame-1)*10+(1:10);
    response = sum(res.spikes(:,idx),2);
    
    neg = sum(response<0);
    pos = sum(response>0) ;
    
    colors(response<0,:) = repmat(default_colors(1,:), neg, 1); 
    colors(response>0,:) = repmat(default_colors(2,:), pos, 1); 
    
    scatter(res.centers(:,2), res.centers(:,1), 1+0.1*abs(response), colors, 'filled');
    
    title('Red: more spikes, Blue: less spikes recorded than predicted')
    F = getframe;
    writeVideo(writerObj, F);
    clf
end

close(writerObj)

end