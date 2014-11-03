TimeShiftInMs=25;
InterPulseLatencyInMs=500;

TimeShift=TimeShiftInMs*20;
InterPulseLatency=InterPulseLatencyInMs*20;

NumberOfSamples=10000;
electrodes=[1:512];

Chunks=[];
RowsIndexes=[1:2:16];
ColumnsIndexes=[17:2:32];
Electrodes=NS512_PatternsForRectangularAreaStimulation(RowsIndexes,ColumnsIndexes);

Array=zeros(1,512);
Array(Electrodes)=1;

Patterns=ones(1,1);
Times=[TimeShift:InterPulseLatency:TimeShift+3*InterPulseLatency];
Chunk1=NS_MovieChunkGenerationForExperiment(Times,NumberOfSamples,Patterns);

MovieChunksFile=[1 Chunk1]; %only one movie

break;
cd C:\home\pawel\2010\stim_files; 

fid = fopen('512_Area_el','wb')
fwrite(fid,electrodes,'int32');
fclose(fid);

fid = fopen('512_Area_pt','wb','ieee-le.l64')
fwrite(fid,Array','double');
fclose(fid);

fid = fopen('512_Area_mv','wb','ieee-le.l64')
fwrite(fid,MovieChunksFile,'int32');
fclose(fid); 