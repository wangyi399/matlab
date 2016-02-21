addpath(genpath('../null_analyse/'));
addpath(genpath('../null_analyse/analyse_functions'));
%startup_null_analyse_tenessee
startup_null_analyse_bertha

%%
% Condition strings
nConditions=7;
condDuration=1200/6;
cond_str=cell(2,1);
cond_str{1}='Original';
cond_str{2}='Null ';

interestingConditions=[1,2];
%% Load Movies

rawMovFrames=1200/(6);
figure;
icnt=0;
% make pixel histogram
for imov=[1,2,3,4,6,8,5]
    [stim,height,width,header_size] = get_raw_movie(sprintf('/Volumes/Data/2015-08-17-6/visual/null/movies/%d.rawMovie',imov),rawMovFrames,1);
    subtract_movies{3}=mean(stim,1);
    subtract_movies{3}=mean(stim,1)*0+127.5;
    movie=stim-repmat(subtract_movies{3},[rawMovFrames,1,1]);
    movie=movie/255;
    
    icnt=icnt+1;
    
    subplot(2,4,icnt);
    qq=movie;
    hist(qq(:),20)
    title(sprintf('Movie pixel histogram %d',imov));
end

% make movies
interval=6;
condMov=cell(nConditions,1);
rawMovFrames=1200/(6);
icnt=0;
% make pixel histogram
for imov=[1,2,3,4,6,8,5]
    [stim,height,width,header_size] = get_raw_movie(sprintf('/Volumes/Data/2015-08-17-6/visual/null/movies/%d.rawMovie',imov),rawMovFrames,1);
    subtract_movies{3}=mean(stim,1);
    subtract_movies{3}=mean(stim,1)*0+127.5;
    movie=stim-repmat(subtract_movies{3},[rawMovFrames,1,1]);
    movie=movie/255;
    
    icnt=icnt+1;
    qq=permute(movie,[2,3,1]);
    ifcnt = 0;
    condMov{icnt}=zeros(size(qq,1),size(qq,2),size(qq,3)*interval);
    for iframe=1:size(qq,3)
        for irepeat=1:interval
            ifcnt=ifcnt+1;
            condMov{icnt}(:,:,ifcnt)=qq(:,:,iframe)+0.5; % cond mov is between 0 and 1 now!
        end
        
    end
    
end

% make contrast map
rawMovFrames=1200/(6);
figure;
icnt=0;
cMap = cell(7,1);
h=figure('Color','w');
for imov=[1,2,3,4,6,8,5]
    [stim,height,width,header_size] = get_raw_movie(sprintf('/Volumes/Data/2015-08-17-6/visual/null/movies/%d.rawMovie',imov),rawMovFrames,1);
    subtract_movies{3}=mean(stim,1);
    subtract_movies{3}=mean(stim,1)*0+127.5;
    movie=stim-repmat(subtract_movies{3},[rawMovFrames,1,1]);
    movie=movie/255;
    
    icnt=icnt+1;
    
    subplot(4,2,icnt);
    qq=movie;
    cMap{icnt}=contrastMap(qq);
    imagesc(cMap{icnt});
    caxis([3,6]);
    colorbar
    axis image
    title(sprintf('cMap: %d',imov));
end

s=hgexport('readstyle','cMap');
hgexport(h,sprintf('/Volumes/Lab/Users/bhaishahster/analyse_2015_08_17_6/cMap.eps'),s);


%% rasters


WN_datafile = '/Volumes/Analysis/2015-08-17-6/d02_20-norefit2/data002-from-data002_data003_data004_data005_data006_data007_data008_data009_data010_data011_data012_data013_data014_data015_data016_data017_data018_data019_data020/data002-from-data002_data003_data004_data005_data006_data007_data008_data009_data010_data011_data012_data013_data014_data015_data016_data017_data018_data019_data020';
%WN_mov='/Volumes/Analysis/stimuli/white-noise-xml/RGB-10-2-0.48-11111.xml';
imov=14;
%WN_datafile_full = '/Volumes/Analysis/2015-08-17-2/streamed/data003/';

datarun=load_data(WN_datafile)
datarun=load_params(datarun)

cellTypeId = 16;
InterestingCell_vis_id=datarun.cell_types{cellTypeId}.cell_ids; %[556,1278,1384,407,1516,2150,2401,3361,4066,4683,5611,6106,6005,7246,7562,3946];
cellTypeUsed=cellTypeId*ones(length(InterestingCell_vis_id),1);

condDuration=10;
nConditions=1;

cols='rkrkrkrkrkrkkrkrkrkr';
spkCondColl=cell(8,1);

for ref_cell_number=1:length(InterestingCell_vis_id); %11
    close all
    
    %data005
    Null_datafile = '/Volumes/Analysis/2015-08-17-6/d02_20-norefit2/data005-from-data002_data003_data004_data005_data006_data007_data008_data009_data010_data011_data012_data013_data014_data015_data016_data017_data018_data019_data020';
    neuronPath = [Null_datafile,sprintf('/data005-from-data002_data003_data004_data005_data006_data007_data008_data009_data010_data011_data012_data013_data014_data015_data016_data017_data018_data019_data020.neurons')];
    cellID=InterestingCell_vis_id(ref_cell_number);
    [spkColl,spkCondColl{1},h]=plot_raster_script_pc2015_08_17_2_light(cellID,nConditions,condDuration,cond_str,neuronPath);
   
     %data006
    Null_datafile = '/Volumes/Analysis/2015-08-17-6/d02_20-norefit2/data006-from-data002_data003_data004_data005_data006_data007_data008_data009_data010_data011_data012_data013_data014_data015_data016_data017_data018_data019_data020';
    neuronPath = [Null_datafile,sprintf('/data006-from-data002_data003_data004_data005_data006_data007_data008_data009_data010_data011_data012_data013_data014_data015_data016_data017_data018_data019_data020.neurons')];
    cellID=InterestingCell_vis_id(ref_cell_number);
    [spkColl,spkCondColl{2},h]=plot_raster_script_pc2015_08_17_2_light(cellID,nConditions,condDuration,cond_str,neuronPath);
   
    
    %data007
    Null_datafile = '/Volumes/Analysis/2015-08-17-6/d02_20-norefit2/data007-from-data002_data003_data004_data005_data006_data007_data008_data009_data010_data011_data012_data013_data014_data015_data016_data017_data018_data019_data020';
    neuronPath = [Null_datafile,sprintf('/data007-from-data002_data003_data004_data005_data006_data007_data008_data009_data010_data011_data012_data013_data014_data015_data016_data017_data018_data019_data020.neurons')];
    cellID=InterestingCell_vis_id(ref_cell_number);
    [spkColl,spkCondColl{3},h]=plot_raster_script_pc2015_08_17_2_light(cellID,nConditions,condDuration,cond_str,neuronPath);
   
    
    
     %data008
    Null_datafile = '/Volumes/Analysis/2015-08-17-6/d02_20-norefit2/data008-from-data002_data003_data004_data005_data006_data007_data008_data009_data010_data011_data012_data013_data014_data015_data016_data017_data018_data019_data020';
    neuronPath = [Null_datafile,sprintf('/data008-from-data002_data003_data004_data005_data006_data007_data008_data009_data010_data011_data012_data013_data014_data015_data016_data017_data018_data019_data020.neurons')];
   cellID=InterestingCell_vis_id(ref_cell_number);
    [spkColl,spkCondColl{4},h]=plot_raster_script_pc2015_08_17_2_light(cellID,nConditions,condDuration,cond_str,neuronPath);
   
    
    
   %data009
    Null_datafile = '/Volumes/Analysis/2015-08-17-6/d02_20-norefit2/data009-from-data002_data003_data004_data005_data006_data007_data008_data009_data010_data011_data012_data013_data014_data015_data016_data017_data018_data019_data020';
    neuronPath = [Null_datafile,sprintf('/data009-from-data002_data003_data004_data005_data006_data007_data008_data009_data010_data011_data012_data013_data014_data015_data016_data017_data018_data019_data020.neurons')];
     cellID=InterestingCell_vis_id(ref_cell_number);
    [spkColl,spkCondColl{5},h]=plot_raster_script_pc2015_08_17_2_light(cellID,nConditions,condDuration,cond_str,neuronPath);
   
   %data010
    Null_datafile = '/Volumes/Analysis/2015-08-17-6/d02_20-norefit2/data010-from-data002_data003_data004_data005_data006_data007_data008_data009_data010_data011_data012_data013_data014_data015_data016_data017_data018_data019_data020';
    neuronPath = [Null_datafile,sprintf('/data010-from-data002_data003_data004_data005_data006_data007_data008_data009_data010_data011_data012_data013_data014_data015_data016_data017_data018_data019_data020.neurons')];
     cellID=InterestingCell_vis_id(ref_cell_number);
    [spkColl,spkCondColl{6},h]=plot_raster_script_pc2015_08_17_2_light(cellID,nConditions,condDuration,cond_str,neuronPath);
   
    
    %data011
    Null_datafile = '/Volumes/Analysis/2015-08-17-6/d02_20-norefit2/data011-from-data002_data003_data004_data005_data006_data007_data008_data009_data010_data011_data012_data013_data014_data015_data016_data017_data018_data019_data020';
    neuronPath = [Null_datafile,sprintf('/data011-from-data002_data003_data004_data005_data006_data007_data008_data009_data010_data011_data012_data013_data014_data015_data016_data017_data018_data019_data020.neurons')];
    cellID=InterestingCell_vis_id(ref_cell_number);
    [spkColl,spkCondColl{7},h]=plot_raster_script_pc2015_08_17_2_light(cellID,nConditions,condDuration,cond_str,neuronPath);
   
    
   
    h=figure;
    for irun = 1:7
    plot(spkCondColl{irun}.xPoints/20000,spkCondColl{irun}.yPoints - (irun-1)*30,cols(irun));
    hold on;
    end
    set(gca,'yTick',[]);
    ylim([-6*30,30]);
    InterestingCell_vis_id(ref_cell_number)
    
    if(~isdir(sprintf('/Volumes/Lab/Users/bhaishahster/analyse_2015_08_17_6/CellType_%s',datarun.cell_types{cellTypeId}.name)))
        mkdir(sprintf('/Volumes/Lab/Users/bhaishahster/analyse_2015_08_17_6/CellType_%s',datarun.cell_types{cellTypeId}.name));
    end
   s=hgexport('readstyle','ras_mos4');
   hgexport(h,sprintf('/Volumes/Lab/Users/bhaishahster/analyse_2015_08_17_6/CellType_%s/CellID_%d.eps',datarun.cell_types{cellTypeId}.name,InterestingCell_vis_id(ref_cell_number)),s);
end

