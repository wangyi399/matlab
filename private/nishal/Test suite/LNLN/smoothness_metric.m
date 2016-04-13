function [metric,metric_su] = smoothness_metric(u_spatial_log,mask2,spatial_scale)

w = @(x) normpdf(x,0,spatial_scale) - 0.5*normpdf(x,0,2*spatial_scale);
u_sp_norm = u_spatial_log./repelem(sqrt(sum(u_spatial_log.^2,1)),size(u_spatial_log,1),1);

%% make the shape of filters 2D

sta_dim1 = size(mask2,1);
sta_dim2 = size(mask2,2);
indexedframe = reshape(1:sta_dim1*sta_dim2,[sta_dim1,sta_dim2]);
masked_frame = indexedframe(logical(mask2));

metric_su=[];
figure;
for isu = 1:size(u_sp_norm,2)
    subplot(1,size(u_sp_norm,2),isu);
     u_spatial = reshape_vector(u_sp_norm(:,isu),masked_frame,indexedframe);
     u_spatial = u_spatial/max(abs(u_spatial(:)));
     imagesc(u_spatial);axis square;colormap gray;
     [r,c] = find(abs(u_spatial) == max(abs(u_spatial(:))));
     u_spatial = u_spatial *sign(u_spatial(r,c));
     
     sss=0;
     for ipix =1:sta_dim1
         for jpix =1:sta_dim2
         sss=sss+u_spatial(ipix,jpix)*w(norm([ipix,jpix]-[r,c]));
         end
     end
   metric_su=[metric_su;sss];  
end

metric = mean(metric_su);
end