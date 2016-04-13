%% Linear cells, LN stimulation model

%%
addpath(genpath('../Test suite/'));
%%
% make on and off parasol mosaic
spatial_extent=64;
on = model_population_stas('coneLatticeOrientation',0/3,'gridsz',spatial_extent);
off = model_population_stas('coneLatticeOrientation',pi/6,'gridsz',spatial_extent);

% plot cells
n=100;
angle = 0:2*pi/n:2*pi;            % vector of angles at which points are drawn
R = 2*on.coneGaussSd;                         % Unit radius
x = R*cos(angle);  y = R*sin(angle);   % Coordinates of the circle

figure;
%plot(on.conesX,on.conesY,'r*');
hold on;

for icone=1:on.nCones
    plot(x+on.conesX(icone),y+on.conesY(icone),'r');                      % Plot the circle 
    axis equal;
    grid on;
end
hold on;

R = 2*off.coneGaussSd;                         % Unit radius
x = R*cos(angle);  y = R*sin(angle);   % Coordinates of the circle

%plot(off.conesX,off.conesY,'b*');
hold on;
n=100;
for icone=1:off.nCones
    plot(x+off.conesX(icone),y+off.conesY(icone),'b');                      % Plot the circle 
    axis equal;
    grid on;
end

%% electrode map 

elecSpacing=5%6;
arrSz=round(spatial_extent*1.7/elecSpacing);
elecLatticeOrientation = pi/6;
elecs = getElectrodes_simulation(elecSpacing,arrSz,elecLatticeOrientation,spatial_extent)
nElecs = length(elecs.x);


hold on;
plot(elecs.x,elecs.y,'.')

on = map_population_electrodes(on,elecs);
off = map_population_electrodes(off,elecs);
plot_cells_elecs(on,elecs,15)


% figure;
% for icell=1:30
% subplot(6,5,icell)
% plot_cells_elecs(on,elecs,icell)
% set(gca,'xTick',[]);set(gca,'yTick',[]);
% end

%% Experimentation

gridSzX =  on.gridSzX;
gridSzY = on.gridSzY;

stas_on = on.stas; 
stas_off = off.stas;
stas = [stas_on;-stas_off];
stas_inv = pinv(stas);
nCells = size(stas,1);


weight_elecs = [on.elecs.weight_elecs;off.elecs.weight_elecs];
nl_ec = @(x) 1./(1+exp(-x));
nl_ec_deri = @(x) (exp(-x)./(1+exp(-x)).^2);
figure;plot([-3:0.1:3],nl_ec([-3:0.1:3]));hold on;
plot([-3:0.1:3],nl_ec_deri([-3:0.1:3]));
%% Input image
img = imread('~/Downloads/SIPI database/misc/4.2.03.tiff'); 
img = double(img(:,:,1))/255 - 0.5;
%img = double(img(200:199+gridSzX,200:199+gridSzY));
img = imresize(img,[gridSzX,gridSzY]);
img_flat= img(:);

cell_resp= stas*img_flat;
a = min(cell_resp);
normalized_cell_resp = cell_resp-a;
b = max(normalized_cell_resp);
normalized_cell_resp = normalized_cell_resp/b;
current_old = zeros(nElecs,1);
obj_log=[];

figure;
for iter=1:20
    iter
cvx_begin quiet
variables obj cell_r_norm(nCells) current(nElecs)
minimize ((sum_square(stas_inv*(cell_r_norm*b+a) - img_flat)) + 0.1*sum_square(current-current_old)+0.001*sum(abs(current)))

subject to 
   nl_ec(weight_elecs*current_old) + nl_ec_deri(weight_elecs*current_old).*(weight_elecs*(current-current_old))== cell_r_norm
   cell_r_norm<=1
   cell_r_norm>=0
cvx_end
current_old=current;
obj_log=[obj_log;((sum_square(stas_inv*(cell_r_norm*b+a) - img_flat)))];
hold on;plot(current);
end

figure;
plot(obj_log);

cell_r_norm = nl_ec(weight_elecs*current);
stim_img = stas_inv*(cell_r_norm*b+a);
stim_img =reshape(stim_img,gridSzX,gridSzY);

figure;
hold on;
scatter(elecs.x,elecs.y,40*abs((current)+1),zeros(nElecs,1));
axis equal
hold on;
imagesc(reshape(img_flat,gridSzX,gridSzY));colormap gray
for icell=1:on.nCones
    hold on;
    pos = [on.conesX(icell)-2*on.coneGaussSd,on.conesY(icell)-2*on.coneGaussSd,4*on.coneGaussSd,4*on.coneGaussSd];
    rectangle('Position',pos,'Curvature',[1 1],'FaceColor',[1,1,1]*cell_r_norm(icell))
    axis equal
end
%hold on;
%plot(on.conesX,on.conesY,'r*');
hold on;
scatter(elecs.x,elecs.y,40*abs((current)+1),2*sign(current),'filled');colormap cool
hold on;
scatter(elecs.x,elecs.y,40*abs((current)+1),zeros(nElecs,1));
axis equal


figure;
%hold on;
%scatter(elecs.x,elecs.y,40*abs((current)+1),zeros(nElecs,1));
%axis equal
%hold on;
%imagesc(reshape(img_flat,gridSzX,gridSzY));colormap gray
for icell=1:off.nCones
    hold on;
    pos = [off.conesX(icell)-2*off.coneGaussSd,off.conesY(icell)-2*off.coneGaussSd,4*off.coneGaussSd,4*off.coneGaussSd];
    rectangle('Position',pos,'Curvature',[1 1],'FaceColor',[1,1,1]*cell_r_norm(icell+on.nCones))
    axis equal
end
%hold on;
%plot(on.conesX,on.conesY,'r*');
hold on;
scatter(elecs.x,elecs.y,40*abs((current)+1),2*sign(current),'filled');colormap cool
hold on;
scatter(elecs.x,elecs.y,40*abs((current)+1),zeros(nElecs,1));
axis equal


%% Show reconstruction
figure;

subplot(1,4,1);
imagesc(reshape(img_flat,gridSzX,gridSzY));axis image;colormap gray
title('Input image');

subplot(1,4,2);
imagesc(stim_img);axis image;
title('Achieved Stimulation');
colormap gray

% Perfect stimulation
subplot(1,4,3);
perfect_cell_resp = stas*(img_flat);
stim_img_perfect = stas_inv*(perfect_cell_resp);
stim_img_perfect =reshape(stim_img_perfect,gridSzX,gridSzY);
imagesc(stim_img_perfect);axis image
colormap gray;
title('Perfect stimulation');

% stimulation 
elec_sta_inp = elecs.stas*(img_flat);
current_inp = elec_sta_inp; % ??
cell_r_norm_pros = nl_ec(weight_elecs*current_inp);
stim_img_pros = stas_inv*(cell_r_norm_pros*b+a);
stim_img_pros =reshape(stim_img_pros,gridSzX,gridSzY);
subplot(1,4,4);
imagesc(stim_img_pros);axis image
colormap gray;
title('Current Prosthesis');