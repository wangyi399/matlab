function [mov_orig,mov_new]=null_project_spatial(stas,mov)

stas_sp=cell(length(stas),1);
for icell=1:length(stas)
    stas_sp{icell}=stas{icell}(:,:,1,4)
end

% Make A
Filt_dim1=size(stas_sp{1},1);
Filt_dim2=size(stas_sp{2},2);
ncells=length(stas);

A=zeros(ncells,Filt_dim1*Filt_dim2);
for icell=1:length(stas_sp)
A(icell,:)=stas_sp{icell}(:)';
end

% Null each frame of movie
mov_new=0*mov;
for iframe=1:size(mov,3)
    if(mod(iframe,100)==1)
        iframe
    end
    
mov_fr=mov(:,:,iframe);
mov_fr=mov_fr(:);
mov_null=mov_fr-A'*(A'\(A\(A*mov_fr)));
mov_new(:,:,iframe)=reshape(mov_null,[Filt_dim1,Filt_dim2]);
end

mov_orig=mov;

end