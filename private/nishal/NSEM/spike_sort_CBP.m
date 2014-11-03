waveforms=cell(9,1);
spike_times=cell(9,1);
spike_amps=cell(9,1);
recon_snippets=cell(9,1);
no_cells=input('Number of cells');
noise=input('Noise Thresold');
imov=5;
data=allElecData{imov};
dt=1/20000;
samplingRate=20000;
close all
save('/Volumes/Analysis/nishal/nsem_data.mat','data','dt');
cd '../CBPSpikesortDemo-master/spikesort_demo/'
[waveforms{imov},spike_times{imov},spike_amps{imov},recon_snippets{imov}]=nsemSpikeSort('nsem_data',no_cells,noise); % need to give number of potential cells and noise amount .. 
% Store spike sorting result ? 
cd ('../../NSEM');
save(sprintf('/Volumes/Analysis/nishal/NSEM_cell%d_long.mat',vision_id),'waveforms','spike_times','spike_amps','recon_snippets','trialStartIndices');
save(sprintf('/Volumes/Analysis/nishal/NSEM_cell%d_long2.mat',vision_id),'-v7.3');